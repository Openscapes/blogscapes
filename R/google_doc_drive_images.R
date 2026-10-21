#' Download images from a Google Doc's parent Drive folder
#'
#' Blog posts are authored as a Google Doc sitting in a Drive folder
#' alongside its image files. This looks up the doc's parent folder, and
#' downloads each file in `image_names` that's found there into `post_dir`.
#' [google_doc_to_qmd()] calls this automatically with the filenames it
#' finds in the doc; call it directly to re-download images without
#' regenerating the whole post (e.g. after replacing an image file in
#' Drive).
#'
#' A filename in `image_names` but not found in the folder is skipped with
#' a message, not an error -- [verify_post_images()] still catches a
#' missing image at crosspost time.
#'
#' @param doc A Google Drive file, as anything [googledrive::as_id()]
#'   accepts -- typically the full share URL copied from the browser.
#' @param image_names Character vector of image filenames to look for in
#'   the doc's parent folder, e.g. `c("cover.jpg", "data_cubes.png")`.
#' @param post_dir Path to the post folder to download images into.
#'
#' @return Invisibly, the character vector of filenames actually
#'   downloaded (a subset of `image_names`).
#'
#' @examples
#' \dontrun{
#' download_doc_images(
#'   doc = "https://docs.google.com/document/d/1QY_OrDsVcWy25eP8JmYAaRCegSsjprr9Jwz_fbAbUBw/edit",
#'   image_names = c("cover.jpg", "data_cubes.png"),
#'   post_dir = "website-new/blog/2026-09-09-openscapes_esip_summer_2026"
#' )
#' }
#' @export
download_doc_images <- function(doc, image_names, post_dir) {
  image_names <- unique(image_names)
  if (length(image_names) == 0) {
    return(invisible(character(0)))
  }

  folder_id <- googledrive::drive_reveal(
    googledrive::as_id(doc),
    what = "parent"
  )$id_parent
  available <- googledrive::drive_ls(path = googledrive::as_id(folder_id))

  found <- image_names[image_names %in% available$name]
  missing <- setdiff(image_names, found)
  if (length(missing) > 0) {
    message(
      "Image(s) referenced in the doc were not found in its Drive ",
      "folder, skipping: ", paste(missing, collapse = ", ")
    )
  }

  for (name in found) {
    googledrive::drive_download(
      file = googledrive::as_id(available$id[available$name == name][1]),
      path = fs::path(post_dir, name),
      overwrite = TRUE
    )
  }

  invisible(found)
}
