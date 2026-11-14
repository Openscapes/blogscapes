# blogscapes (development version)

* All package errors, warnings, and messages now use {cli} for clearer,
  more consistent formatting (#27).
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
* `verify_post_images()` now reports success with a message naming how
  many images were checked, instead of returning silently (#46).
