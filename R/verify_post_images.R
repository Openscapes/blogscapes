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

  resolved <- fs::path_abs(fs::path(post, image_refs))
  outside <- !fs::path_has_parent(resolved, post)

  if (any(outside)) {
    stop(
      "Post references images outside its own folder:\n",
      paste(" -", image_refs[outside], collapse = "\n")
    )
  }

  missing <- !fs::file_exists(resolved)
  if (any(missing)) {
    stop(
      "Post references images that do not exist:\n",
      paste(" -", image_refs[missing], collapse = "\n")
    )
  }

  invisible(TRUE)
}
