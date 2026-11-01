# blogscapes

blogscapes provides tools for crossposting Openscapes blog content
between Openscapes repositories: pulling a draft from a Google Doc,
verifying a post’s images are self-contained, copying the post folder
into one or more destination repos, and opening a pull request for each
copy.

## Status

⚠️ blogscapes is under active development. The core workflow is in place
but still evolving based on team feedback, so expect changes to function
interfaces before the first stable release.

## Installation

You can install the development version of blogscapes from
[GitHub](https://github.com/Openscapes/blogscapes/) with:

``` r

# install.packages("pak")
pak::pak("Openscapes/blogscapes")
```

## Example

A typical crossposting session:

``` r

library(blogscapes)

# Pull a Google Doc draft into a new post folder as index.qmd
google_doc_to_qmd(
  doc = "https://docs.google.com/document/d/FILE_ID/edit",
  post_name = "2026-10-12-my-title",
  blog_dir = "website-new/blog"
)

# Check the post's images are self-contained before copying it anywhere
verify_post_images("website-new/blog/2026-10-12-my-title")

# Copy the post folder into one or more destination repos
targets <- crosspost_blog(
  post = "website-new/blog/2026-10-12-my-title",
  root = "~/Documents/repos/github/openscapes/crossposting",
  destinations = c(
    nasa = "NASA-Openscapes.github.io/news",
    nmfs = "nmfs-openscapes.github.io/blog"
  )
)

# Branch, commit, push, and open a PR in each destination repo
open_crosspost_prs(targets, branch = "crosspost-2026-10-12-my-title")
```
