# Download images from a Google Doc's parent Drive folder

Blog posts are authored as a Google Doc sitting in a Drive folder
alongside its image files. This looks up the doc's parent folder, and
downloads each file in \`image_names\` that's found there into
\`post_dir\`. \[google_doc_to_qmd()\] calls this automatically with the
filenames it finds in the doc; call it directly to re-download images
without regenerating the whole post (e.g. after replacing an image file
in Drive).

## Usage

``` r
download_doc_images(doc, image_names, post_dir)
```

## Arguments

- doc:

  A Google Drive file, as anything \[googledrive::as_id()\] accepts –
  typically the full share URL copied from the browser.

- image_names:

  Character vector of image filenames to look for in the doc's parent
  folder, e.g. \`c("cover.jpg", "data_cubes.png")\`.

- post_dir:

  Path to the post folder to download images into.

## Value

Invisibly, the character vector of filenames actually downloaded (a
subset of \`image_names\`).

## Details

A filename in \`image_names\` but not found in the folder is skipped
with a message, not an error – \[verify_post_images()\] still catches a
missing image at crosspost time.

## Examples

``` r
if (FALSE) { # \dontrun{
download_doc_images(
  doc = "https://docs.google.com/document/d/1QY_OrDsVcWy25eP8JmYAaRCegSsjprr9Jwz_fbAbUBw/edit",
  image_names = c("cover.jpg", "data_cubes.png"),
  post_dir = "website-new/blog/2026-09-09-openscapes_esip_summer_2026"
)
} # }
```
