# blogscapes (development version)

* `google_doc_to_qmd()` now resolves authors' names and ORCIDs from the
  Openscapes team's authors/ORCID Google Sheet instead of a CSV bundled in
  the package, so new authors can be added without a package rebuild. A new
  `authors_sheet` argument lets this be overridden (#20).
