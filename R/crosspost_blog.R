#' Crosspost a blog post directory to one or more other repositories
#'
#' Copies only the post's source content into each destination -- its
#' `.qmd`/`.Rmd` file, the images it references (per
#' [verify_post_images()]'s rules), and `references.bib` if present. A
#' post folder that's been rendered locally (e.g. via Quarto's Render
#' button) may also contain render output like `index.html`,
#' `index_files/`, `.quarto/`, or `site_libs/` -- none of that is copied,
#' since destination repos only need the post's source.
#'
#' @param post Path to the blog post folder to copy. Defaults to the current
#'   working directory, i.e. run this from inside the blog post's own folder.
#' @param destinations A named character vector/list of destination
#'   directories, one per target repo, e.g.
#'   c(nasa = "NASA-Openscapes.github.io/news",
#'     nmfs = "nmfs-openscapes.github.io/blog").
#'   The post folder is copied *into* each of these directories, keeping its
#'   original folder name. Entries can be relative (resolved against `root`)
#'   or absolute paths (used as-is, e.g. a repo cloned somewhere else).
#' @param root Optional common parent folder that all repos live under, e.g.
#'   "~/github/repos/openscapes". Relative entries in `destinations` are
#'   resolved against this. Ignored for destinations that are already
#'   absolute paths.
#' @param overwrite If FALSE (default), errors when a destination already has
#'   a folder for this post. If TRUE, replaces it.
#'
#' @return Invisibly, the full paths the post was copied to.
#'
#' @examples
#' \dontrun{
#' # All repos as siblings under one common folder (e.g. github/repos/openscapes/):
#' # only relative subpaths need to be given, resolved against `root`.
#' crosspost_blog(
#'   post = "website-new/blog/2026-09-09-openscapes_esip_summer_2026",
#'   root = "~/Documents/repos/github/openscapes/crossposting",
#'   destinations = c(
#'     nasa = "NASA-Openscapes.github.io/news",
#'     nmfs = "nmfs-openscapes.github.io/blog"
#'   )
#' )
#'
#' # A destination cloned somewhere else entirely can be given as an absolute
#' # path, bypassing `root`:
#' crosspost_blog(
#'   post = "website-new/blog/2026-09-09-openscapes_esip_summer_2026",
#'   root = "~/Documents/repos/github/openscapes/crossposting",
#'   destinations = c(
#'     nasa = "NASA-Openscapes.github.io/news",
#'     nmfs = "/some/other/place/nmfs-openscapes.github.io/blog"
#'   )
#' )
#' }
#' @export
crosspost_blog <- function(
  post = getwd(),
  destinations,
  root = NULL,
  overwrite = FALSE
) {
  post <- fs::path_abs(post)

  if (!fs::dir_exists(post)) {
    cli::cli_abort("Source blog post folder does not exist: {.path {post}}")
  }

  verify_post_images(post)

  destinations <- unlist(destinations)
  if (!is.null(root)) {
    root <- fs::path_abs(root)
    is_relative <- !fs::is_absolute_path(destinations)
    destinations[is_relative] <- fs::path(root, destinations[is_relative])
  }

  post_name <- fs::path_file(post)
  targets <- fs::path(destinations, post_name)

  existing <- targets[fs::dir_exists(targets)]
  if (length(existing) > 0 && !overwrite) {
    n <- length(existing)
    cli::cli_abort(c(
      "{n} destination{?s} already exist{?s/}: {.path {existing}}",
      "i" = "Use {.arg overwrite = TRUE} to replace {cli::qty(n)}{?it/them}."
    ))
  }

  for (i in seq_along(targets)) {
    copy_post_contents(post, targets[i], overwrite = overwrite)
    cli::cli_inform("Copied {.val {post_name}} -> {.path {targets[i]}}")
  }

  invisible(targets)
}

#' Copy only a post's source content -- its .qmd/.Rmd, referenced images,
#' and references.bib if present
#'
#' Unlike `fs::dir_copy()`, this does not copy the post folder wholesale.
#' A rendered post folder can contain Quarto render output (`.html`,
#' `*_files/`, `.quarto/`, `site_libs/`, etc.) that has no place in a
#' crossposted copy -- rather than trying to list and exclude every kind
#' of render artifact, this copies only the files a post actually needs:
#' its source file, the images [post_image_refs()] finds referenced in
#' it, and `references.bib` if the post has one. Anything else present in
#' `post` is left behind.
#'
#' @param post Path to the source post folder.
#' @param target Path to create and copy into.
#' @param overwrite Passed to [fs::file_copy()] for each copied file.
#' @noRd
copy_post_contents <- function(post, target, overwrite) {
  source_file <- fs::dir_ls(post, regexp = "\\.(qmd|Rmd)$")
  image_refs <- post_image_refs(post)
  bib <- fs::path(post, "references.bib")

  files <- c(source_file, fs::path(post, image_refs))
  if (fs::file_exists(bib)) {
    files <- c(files, bib)
  }
  files <- unique(files)

  fs::dir_create(target)
  for (file in files) {
    rel <- fs::path_rel(file, start = post)
    fs::dir_create(fs::path_dir(fs::path(target, rel)))
    fs::file_copy(file, fs::path(target, rel), overwrite = overwrite)
  }
}
