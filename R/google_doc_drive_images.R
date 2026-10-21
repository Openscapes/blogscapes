#' Download referenced images from a Google Doc's parent Drive folder
#'
#' Blog posts are authored as a Google Doc sitting in a Drive folder
#' alongside its image files. This looks up the doc's parent folder, and
#' downloads each file in `image_names` that's found there into `post_dir`.
#'
#' A filename referenced in the doc but not found in the folder is skipped
#' with a message, not an error -- [verify_post_images()] still catches a
#' missing image at crosspost time.
#'
#' @param doc A Google Drive file, as anything [googledrive::as_id()]
#'   accepts.
#' @param image_names Character vector of image filenames to look for in
#'   the doc's parent folder (e.g. from [render_image_blocks()] and the
#'   YAML header's `Image:` field).
#' @param post_dir Path to the post folder to download images into.
#'
#' @return Invisibly, the character vector of filenames actually
#'   downloaded (a subset of `image_names`).
#' @noRd
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
