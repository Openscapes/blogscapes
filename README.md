# blogscapes <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/Openscapes/blogscapes/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Openscapes/blogscapes/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

blogscapes provides tools for crossposting Openscapes blog content
between Openscapes repositories: pulling a draft from a
Google Doc, verifying a post's images are self-contained, copying the
post folder into one or more destination repos, and opening a pull
request for each copy.

## Status

⚠️ blogscapes is under active development. The core workflow is in place
but still evolving based on team feedback, so expect changes to
function interfaces before the first stable release.

## Installation

You can install the development version of blogscapes from
[GitHub](https://github.com/Openscapes/blogscapes/) with:

``` r
# install.packages("pak")
pak::pak("Openscapes/blogscapes")
```

## Example

A typical crossposting session, run with your working directory set to
your local clone of the `website-new` repo (e.g. an RStudio project
rooted there). All paths below are relative to that repo's root --
adjust them if your working directory is somewhere else, e.g. prefix
with `website-new/` if you're running from its parent folder instead.

``` r
library(blogscapes)

# Pull a Google Doc draft into a new post folder as index.qmd
google_doc_to_qmd(
  doc = "https://docs.google.com/document/d/FILE_ID/edit",
  post_name = "2026-10-12-my-title",
  blog_dir = "blog",
  base_url = "https://openscapes.org/blog/"
)

# Check the post's images are self-contained before copying it anywhere
verify_post_images("blog/2026-10-12-my-title")

# Copy the post folder into one or more destination repos
targets <- crosspost_blog(
  post = "blog/2026-10-12-my-title",
  root = "~/Documents/repos/github/openscapes/crossposting",
  destinations = c(
    nasa = "NASA-Openscapes.github.io/news",
    nmfs = "nmfs-openscapes.github.io/blog"
  )
)

# Branch, commit, push, and open a PR in the source repo (website-new)
# and in each destination repo
open_crosspost_prs(targets)
```

### A note on sparse-checkout destination repos

`open_crosspost_prs()` uses [gert](https://docs.ropensci.org/gert/) (libgit2)
to branch, stage, commit, and push. If a destination repo is a partial clone
(e.g. cloned with `git clone --filter=blob:none --sparse`) with
sparse-checkout active, this currently fails with an error like:

```
Error in libgit2::git_index_add_all :
object not found - cannot read header for <hash>
```

This happens because libgit2 tries to validate index entries for blobs
outside the sparse-checkout scope that were never downloaded locally,
rather than lazily fetching them the way the `git` CLI does. If you hit
this, either avoid using a partial/sparse clone as a crosspost
destination, or run the `git add`/`git commit`/`git push` steps for that
repo manually outside the package. See
[#53](https://github.com/Openscapes/blogscapes/issues/53) for details.
