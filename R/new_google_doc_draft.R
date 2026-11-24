#' Create a blank blog post draft in Google Drive
#'
#' Creates a new Google Doc, pre-filled with the header fields and image
#' placeholder syntax [google_doc_to_qmd()] expects, so a new author can
#' start writing without first reading the package source. Each header
#' field is bolded using the `**Field:**` convention [parse_doc_header()]
#' recognizes, and the body includes an example of the
#' `image_name:`/`caption_text:`/`alt_text:` block [render_image_blocks()]
#' looks for. The template lives at
#' `system.file("extdata", "google_doc_draft_template.md", package =
#' "blogscapes")`.
#'
#' @param name Name for the new Google Doc, e.g. "2026-11-13-my-title".
#' @param path Destination folder in Drive, as anything
#'   [googledrive::as_id()] accepts -- defaults to the current user's "My
#'   Drive" root. Pass the doc's intended parent folder here if images
#'   will be added alongside it, since [download_doc_images()] looks for
#'   images in the doc's own parent folder.
#' @param browse If TRUE (default), opens the new doc in the browser via
#'   [googledrive::drive_browse()].
#'
#' @return Invisibly, a `dribble` describing the new Google Doc (as
#'   returned by [googledrive::drive_upload()]).
#'
#' @examples
#' \dontrun{
#' new_google_doc_draft("2026-11-13-my-title")
#' }
#' @export
new_google_doc_draft <- function(name, path = NULL, browse = TRUE) {
  template_path <- system.file(
    "extdata",
    "google_doc_draft_template.md",
    package = "blogscapes"
  )

  doc <- googledrive::drive_upload(
    media = template_path,
    path = path,
    name = name,
    type = "document"
  )

  if (browse) {
    googledrive::drive_browse(doc)
  }

  invisible(doc)
}
