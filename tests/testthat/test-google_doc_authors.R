fake_authors_table <- function() {
  data.frame(
    author_name = c(
      "Ronny A. Hernández Mora",
      "Stefanie Butland",
      "Julie Lowndes",
      "Andy Teucher"
    ),
    alias = c("Ronny", "Stef", "Julie", "Andy Teucher"),
    orcid = c(
      "0000-0001-6225-7096",
      "0000-0002-5427-8951",
      "0000-0003-1682-3872",
      NA
    ),
    stringsAsFactors = FALSE
  )
}

test_that("lookup_authors() returns name and orcid lines for known aliases", {
  local_mocked_bindings(
    gs4_deauth = function() invisible(NULL),
    read_sheet = function(...) fake_authors_table(),
    .package = "googlesheets4"
  )

  result <- lookup_authors("Ronny, Stef, Julie")

  expect_equal(
    result,
    c(
      "  - name: Ronny A. Hernández Mora",
      "    orcid: 0000-0001-6225-7096",
      "  - name: Stefanie Butland",
      "    orcid: 0000-0002-5427-8951",
      "  - name: Julie Lowndes",
      "    orcid: 0000-0003-1682-3872"
    )
  )
})

test_that("lookup_authors() omits the orcid line and warns when orcid is unknown", {
  local_mocked_bindings(
    gs4_deauth = function() invisible(NULL),
    read_sheet = function(...) fake_authors_table(),
    .package = "googlesheets4"
  )

  expect_snapshot(result <- lookup_authors("Andy Teucher"))
  expect_equal(result, "  - name: Andy Teucher")
})

test_that("lookup_authors() errors on an alias not in the sheet", {
  local_mocked_bindings(
    gs4_deauth = function() invisible(NULL),
    read_sheet = function(...) fake_authors_table(),
    .package = "googlesheets4"
  )

  expect_snapshot(error = TRUE, lookup_authors("NotARealAlias"))
})
