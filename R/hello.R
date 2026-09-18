#' Crosspost a blog post directory to one or more other repositories
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
crosspost_blog <- function(post = getwd(), destinations, root = NULL, overwrite = FALSE) {
  post <- fs::path_abs(post)

  if (!fs::dir_exists(post)) {
    stop("Source blog post folder does not exist: ", post)
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
    stop(
      "Destination already exists (use overwrite = TRUE to replace):\n",
      paste(" -", existing, collapse = "\n")
    )
  }

  for (i in seq_along(targets)) {
    fs::dir_create(fs::path_dir(targets[i]))
    fs::dir_copy(path = post, new_path = targets[i], overwrite = overwrite)
    message("Copied ", post_name, " -> ", targets[i])
  }

  invisible(targets)
}
