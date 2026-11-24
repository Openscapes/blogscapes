#' Verify a blog post's images are self-contained
#'
#' Scans a post's `.qmd`/`.Rmd` file for every image reference (YAML front
#' matter `image:` field and body `![]()` syntax) and checks that each one
#' resolves to a file inside the post's own folder, and that the file
#' actually exists there. `crosspost_blog()` copies the post folder as-is, so
#' a reference pointing outside of it would silently produce a broken image
#' in the destination repo.
#'
#' @param post Path to the blog post folder to check. Defaults to the current
#'   working directory, i.e. run this from inside the blog post's own folder.
#'
#' @return Invisibly, `TRUE` if all image references resolve to existing
#'   files inside `post`. Errors otherwise.
#'
#' @examples
#' \dontrun{
#' verify_post_images("website-new/blog/2026-09-09-openscapes_esip_summer_2026")
#' }
#' @export
verify_post_images <- function(post = getwd()) {
  post <- fs::path_abs(post)
  image_refs <- post_image_refs(post)

  resolved <- fs::path_abs(fs::path(post, image_refs))
  outside <- !fs::path_has_parent(resolved, post)

  if (any(outside)) {
    cli::cli_abort(c(
      "Post references {cli::qty(sum(outside))} image{?s} outside its own folder:",
      "x" = "{.path {image_refs[outside]}}"
    ))
  }

  missing <- !fs::file_exists(resolved)
  if (any(missing)) {
    cli::cli_abort(c(
      "Post references {cli::qty(sum(missing))} image{?s} that {?doesn't/don't} exist:",
      "x" = "{.path {image_refs[missing]}}"
    ))
  }

  n <- length(image_refs)
  cli::cli_inform(c(
    "v" = "{n} image{?s} {cli::qty(n)}{?is/are} self-contained in {.path {post}}."
  ))

  invisible(TRUE)
}

#' Find a post's image references
#'
#' Scans a post's `.qmd`/`.Rmd` file for every image reference (YAML front
#' matter `image:` field and body `![]()` syntax), excluding remote URLs.
#' An image referenced more than once (e.g. used as both the cover image
#' and an inline figure) is only returned once -- references are
#' normalized (a leading `./` is stripped) before deduplicating, since
#' `"./cover.jpg"` and `"cover.jpg"` name the same file but wouldn't
#' otherwise compare as equal strings. Shared by [verify_post_images()]
#' (which checks each reference resolves) and [crosspost_blog()] (which
#' only copies the files a post actually needs).
#'
#' @param post Path to the blog post folder.
#'
#' @return Character vector of unique, normalized image reference paths
#'   (relative to `post`, not yet resolved or checked for existence).
#' @noRd
post_image_refs <- function(post) {
  source_file <- fs::dir_ls(post, regexp = "\\.(qmd|Rmd)$")
  content <- readLines(source_file, warn = FALSE)

  body_refs <- unlist(regmatches(
    content,
    gregexpr("(?<=\\]\\()[^)]+", content, perl = TRUE)
  ))
  front_matter_refs <- sub(
    "^image:\\s*",
    "",
    grep("^image:\\s*\\S+", content, value = TRUE)
  )

  image_refs <- c(body_refs, front_matter_refs)
  image_refs <- image_refs[!grepl("^https?://", image_refs)]
  unique(sub("^\\./", "", image_refs))
}
