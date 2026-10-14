#' Download a Google Doc as a new blog post .qmd
#'
#' Downloads a Google Doc as Markdown and saves it as `index.qmd` inside a
#' new post folder, matching the post-folder layout [crosspost_blog()] and
#' [verify_post_images()] expect.
#'
#' @param doc A Google Drive file, as anything [googledrive::as_id()]
#'   accepts -- typically the full share URL copied from the browser.
#' @param post_name Name of the post folder to create, e.g.
#'   "2026-10-12-my-title".
#' @param blog_dir Path to the blog's root folder that `post_name` will be
#'   created under, e.g. "website-new/blog".
#' @param overwrite If FALSE (default), errors when the post folder already
#'   exists. If TRUE, replaces the `index.qmd` inside it.
#'
#' @return Invisibly, the path to the created `index.qmd`.
#'
#' @examples
#' \dontrun{
#' google_doc_to_qmd(
#'   doc = "https://docs.google.com/document/d/1QY_OrDsVcWy25eP8JmYAaRCegSsjprr9Jwz_fbAbUBw/edit",
#'   post_name = "2026-10-12-my-title",
#'   blog_dir = "website-new/blog"
#' )
#' }
#' @export
google_doc_to_qmd <- function(doc, post_name, blog_dir, overwrite = FALSE) {
  blog_dir <- fs::path_abs(blog_dir)
  post_dir <- fs::path(blog_dir, post_name)
  target <- fs::path(post_dir, "index.qmd")

  if (fs::file_exists(target) && !overwrite) {
    stop(
      "Post already has an index.qmd (use overwrite = TRUE to replace): ",
      target
    )
  }

  fs::dir_create(post_dir)

  md_path <- fs::path(post_dir, "index.md")
  googledrive::drive_download(
    file = googledrive::as_id(doc),
    path = md_path,
    type = "text/markdown",
    overwrite = overwrite
  )

  fs::file_move(md_path, target)

  invisible(target)
}
