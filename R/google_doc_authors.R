#' Default Openscapes authors/ORCID Google Sheet
#'
#' The team-maintained sheet mapping each author's short alias (as used in
#' a Google Doc's `Authors:` field) to their full name and ORCID. Anyone on
#' the team can add or update a row without requiring a package rebuild.
#' @noRd
default_authors_sheet <- "1AgmOtwHgePl1-eavGal_D_ZT3znIwbRCoeFSgY-vrJY"

#' Look up authors' full names and ORCID IDs
#'
#' Matches comma-separated aliases (e.g. first names, as used in the
#' Google Doc's `Authors:` field) against the `alias` column of the team's
#' authors/ORCID Google Sheet, read live via [googlesheets4::read_sheet()].
#'
#' @param authors_field The raw `Authors:` field value, e.g. "Ronny, Julie".
#' @param authors_sheet A Google Sheet, as anything
#'   [googlesheets4::read_sheet()] accepts -- defaults to the Openscapes
#'   team's authors/ORCID sheet. This sheet is public (anyone with the
#'   link can view), so it's read unauthenticated via
#'   [googlesheets4::gs4_deauth()] rather than requiring the caller's
#'   Google credentials.
#'
#' @return A character vector of YAML lines, one or two per author
#'   (`- name: ...` and, when known, `  orcid: ...`), ready to nest under
#'   an `author:` key.
#' @noRd
lookup_authors <- function(
  authors_field,
  authors_sheet = default_authors_sheet
) {
  aliases <- trimws(strsplit(authors_field, ",")[[1]])

  googlesheets4::gs4_deauth()
  authors_table <- googlesheets4::read_sheet(authors_sheet)

  unknown <- setdiff(aliases, authors_table$alias)
  if (length(unknown) > 0) {
    stop(
      "No entry for author(s): ",
      paste(unknown, collapse = ", "),
      "\nAdd them to the authors sheet: ",
      "https://docs.google.com/spreadsheets/d/",
      authors_sheet
    )
  }

  matched <- authors_table[match(aliases, authors_table$alias), ]

  missing_orcid <- matched$author_name[is.na(matched$orcid)]
  if (length(missing_orcid) > 0) {
    warning(
      "No ORCID on file for author(s): ",
      paste(missing_orcid, collapse = ", "),
      " -- omitting orcid from their entry."
    )
  }

  unname(unlist(Map(
    function(name, orcid) {
      c(
        paste0("  - name: ", name),
        if (!is.na(orcid)) paste0("    orcid: ", orcid)
      )
    },
    matched$author_name,
    matched$orcid
  )))
}
