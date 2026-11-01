# Download a Google Doc as a new blog post .qmd

Downloads a Google Doc as Markdown, converts its metadata block (Blog
Title, Publish date, Authors, etc.) into Quarto YAML front matter, and
saves the result as \`index.qmd\` inside a new post folder, matching the
post-folder layout \[crosspost_blog()\] and \[verify_post_images()\]
expect. Image files referenced by the doc's \`Image:\` field and any
body \`image_name:\` blocks are downloaded from the doc's own parent
Drive folder into the post folder – the doc and its images are expected
to live together in one Drive folder per post. See
\[download_doc_images()\] for details.

## Usage

``` r
google_doc_to_qmd(doc, post_name, blog_dir, base_url, overwrite = FALSE)
```

## Arguments

- doc:

  A Google Drive file, as anything \[googledrive::as_id()\] accepts –
  typically the full share URL copied from the browser.

- post_name:

  Name of the post folder to create, e.g. "2026-09-09-my-title". Must
  start with a \`YYYY-MM-DD\` date (\`-\` or \`\_\` separated), used as
  the post's \`date\` and as part of \`citation.url\` when the doc
  doesn't specify its own.

- blog_dir:

  Path to the blog's root folder that \`post_name\` will be created
  under, e.g. "website-new/blog".

- base_url:

  Base URL the post is published under, e.g.
  "https://openscapes.org/blog/". Used to build \`citation.url\` as
  \`\<base_url\>\<post_name\>\`.

- overwrite:

  If FALSE (default), errors when the post folder already exists. If
  TRUE, replaces the \`index.qmd\` inside it.

## Value

Invisibly, the path to the created \`index.qmd\`.

## Details

The Google Doc is expected to start with a metadata block of plain-text
lines, one field per line, e.g.:

“\` Blog Title: My post title Publish date: Location:
openscapes.org/blog, cross-post: URL: Authors: Ronny, Julie Image: A
description of the cover image Categories: blog, NASA “\`

Recognized fields are consumed into YAML front matter; everything from
the first unrecognized line onward is kept as the post body, except for
image placeholder blocks. See \[parse_doc_header()\] and
\[build_qmd_front_matter()\] for the header parsing rules.

Anywhere in the body, three consecutive lines of the form:

“\` image_name: cover.jpg caption_text: A caption describing the image
alt_text: A longer accessible description of the image “\`

are replaced with a centered Quarto figure div referencing
\`./\<image_name\>\`. The image file itself must already exist in the
post folder – this function does not create or move it. See
\[render_image_blocks()\] for details.

## Examples

``` r
if (FALSE) { # \dontrun{
google_doc_to_qmd(
  doc = "https://docs.google.com/document/d/1QY_OrDsVcWy25eP8JmYAaRCegSsjprr9Jwz_fbAbUBw/edit",
  post_name = "2026-09-09-openscapes_esip_summer_2026",
  blog_dir = "website-new/blog",
  base_url = "https://openscapes.org/blog/"
)
} # }
```
