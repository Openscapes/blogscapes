# blogscapes (development version)

* All package errors, warnings, and messages now use {cli} for clearer,
  more consistent formatting (#27).
* `google_doc_to_qmd()` now resolves authors' names and ORCIDs from the
  Openscapes team's authors/ORCID Google Sheet instead of a CSV bundled in
  the package, so new authors can be added without a package rebuild. A new
  `authors_sheet` argument lets this be overridden (#20).
* `google_doc_to_qmd()`'s `Authors:` field now accepts either an author's
  short alias or their full name, matching whichever is on file in the
  authors sheet (#43).
