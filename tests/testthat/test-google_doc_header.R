test_that("parse_doc_header() parses fields bolded as **Field:**", {
  content <- c(
    "**Blog Title:** My post title",
    "**Publish date:** 2026-09-09",
    "**Authors:** Ronny, Julie",
    "Body starts here."
  )

  result <- parse_doc_header(content)

  expect_equal(result[["Blog Title"]], "My post title")
  expect_equal(result[["Publish date"]], "2026-09-09")
  expect_equal(result[["Authors"]], "Ronny, Julie")
  expect_equal(result$body, "Body starts here.")
})

test_that("parse_doc_header() parses fields bolded as **Field**:", {
  content <- c(
    "**Location**: openscapes.org/blog, cross-post:",
    "**URL**: openscapes.org/blog",
    "**Image**: cover.jpg",
    "Body starts here."
  )

  result <- parse_doc_header(content)

  expect_equal(result[["Location"]], "openscapes.org/blog, cross-post:")
  expect_equal(result[["URL"]], "openscapes.org/blog")
  expect_equal(result[["Image"]], "cover.jpg")
  expect_equal(result$body, "Body starts here.")
})

test_that("parse_doc_header() parses a header mixing both bold styles", {
  content <- c(
    "**Blog Title:** Openscapes Fall Newsletter 2026",
    "**Publish date:** 2026-11-13",
    "**Location**: openscapes.org/blog, cross-post:",
    "**URL**: openscapes.org/blog",
    "**Authors:** Julie Lowndes, Stefanie Butland",
    "**Image**: MtWhitneySunrise-ElliotLowndes.jpeg",
    "**Categories:** blog, ESIP, NASA, NOAA",
    "",
    "Body text starts here."
  )

  result <- parse_doc_header(content)

  expect_equal(result[["Blog Title"]], "Openscapes Fall Newsletter 2026")
  expect_equal(result[["Publish date"]], "2026-11-13")
  expect_equal(result[["Location"]], "openscapes.org/blog, cross-post:")
  expect_equal(result[["URL"]], "openscapes.org/blog")
  expect_equal(result[["Authors"]], "Julie Lowndes, Stefanie Butland")
  expect_equal(result[["Image"]], "MtWhitneySunrise-ElliotLowndes.jpeg")
  expect_equal(result[["Categories"]], "blog, ESIP, NASA, NOAA")
  expect_equal(result$body, c("", "Body text starts here."))
})

test_that("parse_doc_header() stops at the first unrecognized line", {
  content <- c(
    "**Blog Title:** My post title",
    "Not a header field.",
    "**Authors:** Ronny"
  )

  result <- parse_doc_header(content)

  expect_equal(result[["Blog Title"]], "My post title")
  expect_null(result[["Authors"]])
  expect_equal(result$body, c("Not a header field.", "**Authors:** Ronny"))
})

test_that("parse_doc_header() omits fields absent from content", {
  content <- c("**Blog Title:** My post title", "Body.")

  result <- parse_doc_header(content)

  expect_false("Authors" %in% names(result))
  expect_false("Image" %in% names(result))
})

test_that("parse_doc_header() returns all content as body when header is absent", {
  content <- c("Just a regular paragraph.", "Another line.")

  result <- parse_doc_header(content)

  expect_equal(result$body, content)
  expect_equal(names(result), "body")
})
