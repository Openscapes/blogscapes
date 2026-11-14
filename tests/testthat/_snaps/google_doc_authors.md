# lookup_authors() omits the orcid line and warns when orcid is unknown

    Code
      result <- lookup_authors("Andy Teucher")
    Condition
      Warning in `lookup_authors()`:
      No ORCID on file for author(s): Andy Teucher -- omitting orcid from their entry.

# lookup_authors() errors on an alias not in the sheet

    Code
      lookup_authors("NotARealAlias")
    Condition
      Error in `lookup_authors()`:
      ! No entry for author(s): NotARealAlias
      Add them to the authors sheet: https://docs.google.com/spreadsheets/d/1AgmOtwHgePl1-eavGal_D_ZT3znIwbRCoeFSgY-vrJY

