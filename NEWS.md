# blogscapes (development version)

* All package errors, warnings, and messages now use {cli} for clearer,
  more consistent formatting (#27).
* `crosspost_blog()`'s returned `targets` now also includes the post's
  source repo (named `"source"`), not just its destination copies, so
  [open_crosspost_prs()] also branches/commits/pushes/opens a PR there --
  the post is new in its source repo too and needs the same treatment
  (#55).
* `crosspost_blog()` now copies only a post's source content -- its
  `.qmd`/`.Rmd`, referenced images, and `references.bib` if present --
  instead of the whole post folder, so Quarto render output left behind
  from a local preview (`.html`, `*_files/`, `.quarto/`, `site_libs/`)
  is no longer crossposted (#50).
* `google_doc_to_qmd()` now resolves authors' names and ORCIDs from the
  Openscapes team's authors/ORCID Google Sheet instead of a CSV bundled in
  the package, so new authors can be added without a package rebuild. A new
  `authors_sheet` argument lets this be overridden (#20).
* `google_doc_to_qmd()`'s `Authors:` field now accepts either an author's
  short alias or their full name, matching whichever is on file in the
  authors sheet (#43).
* `google_doc_to_qmd()` now recognizes a `Description:` field in the Doc's
  metadata block, written to the YAML front matter as `description` (commonly
  used as the post's subtitle). Omitted from the YAML if left blank (#60).
* `google_doc_to_qmd()` now strips base64 `data:` URI images from the post
  body (e.g. emoji pasted from Slack, which Google Docs exports as inline
  images), replacing them with their plain alt text instead of carrying
  the embedded image data into the generated `.qmd` (#49).
* `open_crosspost_prs()`'s `branch` argument is now optional, defaulting to
  `"crosspost-<post folder name>"` derived from `targets` instead of
  requiring it to be retyped (and kept in sync) by hand (#52).
* `open_crosspost_prs()` no longer fails to stage a target's files when a
  path component resolves through a symlink (e.g. `/var` -> `/private/var`
  on macOS), which previously produced a "No staged files to commit" error
  (#52).
* `open_crosspost_prs()` now attempts every target independently instead
  of stopping at the first failure -- a problem with one destination repo
  no longer prevents branches/PRs from being created for the others. If
  any targets fail, one error lists all of them after every target has
  been attempted (#54).
* `verify_post_images()` and `crosspost_blog()` no longer double-count or
  double-copy an image that's referenced more than once in a post (e.g.
  used as both the cover image and an inline figure) -- previously this
  made `crosspost_blog()` fail with an `EEXIST` error trying to copy the
  same file twice (#61).
* `verify_post_images()` now reports success with a message naming how
  many images were checked, instead of returning silently (#46).
