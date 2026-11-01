# Writing a post from a Google Doc

``` r

library(blogscapes)
```

Openscapes blog posts are drafted as a Google Doc, not directly as a
Quarto `.qmd` file. This lets non-technical contributors write a post
without touching Quarto syntax at all.
[`google_doc_to_qmd()`](../reference/google_doc_to_qmd.md) turns that
doc into a ready-to-review `index.qmd`, including YAML front matter and
in-body figures.

## One Drive folder per post

Create one Google Drive folder per post. It should contain:

- The Google Doc itself.
- Every image file the post references, as plain image files
  (`.png`/`.jpg`/etc.) sitting in that same folder – **not** pasted or
  embedded directly into the Doc (see “Don’t paste images into the Doc”
  below).

[`google_doc_to_qmd()`](../reference/google_doc_to_qmd.md) only needs
the link to the Doc; it looks up the Doc’s own parent folder to find the
images automatically.

## The Doc’s metadata block

At the very top of the Doc, add a block of plain-text `Field: value`
lines, one per line:

    Blog Title: Collaboration and visioning at the 2026 ESIP Summer Meeting
    Publish date:
    Location: openscapes.org/blog, cross-post:
    URL:
    Authors: Ronny, Julie, Ileana
    Image: cover.jpg
    Categories: blog, ESIP, NASA, NOAA

Only `Blog Title` is required. Here’s what happens to each field:

| Field | What it becomes |
|----|----|
| `Blog Title` | `title` in the YAML front matter. |
| `Publish date` | `date`. If left blank, derived from the leading `YYYY-MM-DD` in the post’s folder name instead. |
| `Location` | Not used in the output – informational only. |
| `URL` | **Ignored.** `citation.url` is always built from `base_url` (an argument you pass to [`google_doc_to_qmd()`](../reference/google_doc_to_qmd.md)) and the post’s folder name, since Google auto-converts a typed URL into a Markdown link that isn’t usable as a plain string. Leave this blank. |
| `Authors` | Comma-separated first names (e.g. “Ronny, Julie”), matched against the package’s author table (`inst/extdata/authors.csv`) to produce full names and ORCID IDs in the YAML. An unrecognized name errors – add new teammates to that table first. |
| `Image` | The cover image’s filename (e.g. `cover.jpg`). Written to the YAML as `image: cover.jpg`, and downloaded from the Doc’s Drive folder along with any in-body images. |
| `Categories` | Comma-separated tags, written as `categories: [blog, ESIP, ...]`. Omitted from the YAML if left blank. |

## In-body images

Anywhere in the body of the post, mark where an image belongs with three
consecutive plain-text lines:

    image_name: data_cubes.png
    caption_text: Slide from Luis Lopez' talk illustrating how virtualizing data enables people to stream data rather than downloading using current non-ARCO file structures, with the ultimate goal of AI-Ready Data Cubes
    alt_text: Left-to-right workflow showing fragmented NetCDF, HDF5, and GRIB files progressing through DGGS, Zarr, VirtualiZarr, Icechunk, STAC and earthaccess, and zarr-datafusion. These technologies provide spatially consistent grids, cloud-native chunking, zero-copy access, versioning, data discovery, and efficient querying, culminating in AI-ready data cubes that require minimal preprocessing.

`image_name` must match a real image file in the Doc’s Drive folder.
[`google_doc_to_qmd()`](../reference/google_doc_to_qmd.md) replaces this
three-line block with a centered Quarto figure:

    ::: {style="text-align:center;"}
    ![Slide from Luis Lopez' talk illustrating how virtualizing data enables people to stream data rather than downloading using current non-ARCO file structures, with the ultimate goal of AI-Ready Data Cubes](./data_cubes.png){fig-alt="Left-to-right workflow showing fragmented NetCDF, HDF5, and GRIB files progressing through DGGS, Zarr, VirtualiZarr, Icechunk, STAC and earthaccess, and zarr-datafusion. These technologies provide spatially consistent grids, cloud-native chunking, zero-copy access, versioning, data discovery, and efficient querying, culminating in AI-ready data cubes that require minimal preprocessing." fig-align="center" width="60%"}
    :::

and downloads `data_cubes.png` from the Drive folder into the post
folder, so the figure reference actually resolves.

You can have as many of these blocks as the post needs. If a block is
missing `caption_text` or `alt_text`, or the lines aren’t consecutive,
[`google_doc_to_qmd()`](../reference/google_doc_to_qmd.md) leaves it as
plain text and prints a message rather than failing the whole post.

### Don’t paste images into the Doc

If you paste or insert an image directly into the Google Doc (instead of
describing it with an `image_name:` block), Google’s export embeds the
whole image as base64 text, producing a multi-hundred-KB unreadable
`.qmd`. Always use an `image_name:` block and a real image file in the
Drive folder instead.

## Generating the post

``` r

google_doc_to_qmd(
  doc = "https://docs.google.com/document/d/1QY_OrDsVcWy25eP8JmYAaRCegSsjprr9Jwz_fbAbUBw/edit",
  post_name = "2026-09-09-openscapes_esip_summer_2026",
  blog_dir = "website-new/blog",
  base_url = "https://openscapes.org/blog/"
)
```

This downloads the Doc, builds the YAML front matter, converts any
`image_name:` blocks, downloads the referenced images from the Doc’s
Drive folder, and writes everything to
`website-new/blog/2026-09-09-openscapes_esip_summer_2026/index.qmd`.

`post_name` must start with a `YYYY-MM-DD` date (`-` or `_` separated) –
it’s used both as the post’s folder name and, if the Doc’s
`Publish date` was left blank, as the source of the YAML `date`.

### Re-downloading images only

If you replace an image file in the Drive folder after already running
[`google_doc_to_qmd()`](../reference/google_doc_to_qmd.md), you don’t
need to regenerate the whole post –
[`download_doc_images()`](../reference/download_doc_images.md) fetches
just the images:

``` r

download_doc_images(
  doc = "https://docs.google.com/document/d/1QY_OrDsVcWy25eP8JmYAaRCegSsjprr9Jwz_fbAbUBw/edit",
  image_names = c("cover.jpg", "data_cubes.png"),
  post_dir = "website-new/blog/2026-09-09-openscapes_esip_summer_2026"
)
```

## Before crossposting

Once the `.qmd` looks right, review it like any other pull request. Then
use [`verify_post_images()`](crossposting-a-post.md) and
[`crosspost_blog()`](crossposting-a-post.md) to copy it into other
Openscapes-affiliated repositories – see the “Crossposting a post”
vignette.
