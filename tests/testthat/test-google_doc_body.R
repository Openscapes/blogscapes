test_that("strip_data_uri_images() replaces a data: URI image with its alt text", {
  body <- c(
    "Some text with an emoji ![:star2:][image1] in it.",
    "",
    "[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABE=>"
  )

  result <- strip_data_uri_images(body)

  expect_equal(result, c("Some text with an emoji :star2: in it.", ""))
})

test_that("strip_data_uri_images() handles multiple data: URI images", {
  body <- c(
    "Line with ![:star2:][img1] and ![:tada:][img2] emoji.",
    "",
    "[img1]: <data:image/png;base64,AAA=>",
    "[img2]: <data:image/png;base64,BBB=>"
  )

  result <- strip_data_uri_images(body)

  expect_equal(result, c("Line with :star2: and :tada: emoji.", ""))
})

test_that("strip_data_uri_images() leaves a body with no data: URIs unchanged", {
  body <- c(
    "Just a normal paragraph.",
    "",
    "Another one with ![alt](./cover.jpg)."
  )

  result <- strip_data_uri_images(body)

  expect_equal(result, body)
})

test_that("strip_data_uri_images() does not touch file-based image references", {
  body <- c(
    "![a real figure](./cover.jpg)",
    "",
    "[ref]: ./not-a-data-uri.png"
  )

  result <- strip_data_uri_images(body)

  expect_equal(result, body)
})

test_that("strip_heading_bold() unwraps a fully-bolded heading", {
  body <- c("## **Some heading**", "Body text.")

  result <- strip_heading_bold(body)

  expect_equal(result, c("## Some heading", "Body text."))
})

test_that("strip_heading_bold() handles different heading levels", {
  body <- c("# **Top level**", "### **Third level**")

  result <- strip_heading_bold(body)

  expect_equal(result, c("# Top level", "### Third level"))
})

test_that("strip_heading_bold() leaves a heading with partial bold unchanged", {
  body <- c("## Some **bold** word")

  result <- strip_heading_bold(body)

  expect_equal(result, body)
})

test_that("strip_heading_bold() leaves non-heading bold text unchanged", {
  body <- c("A paragraph with **bold** text.", "**Also bold** at line start.")

  result <- strip_heading_bold(body)

  expect_equal(result, body)
})

test_that("wrap_blockquotes() wraps a single-line blockquote", {
  body <- c("Before.", "> A quoted line.", "After.")

  result <- wrap_blockquotes(body)

  expect_equal(
    result,
    c(
      "Before.",
      "::: {.blockquote-blue}",
      "> A quoted line.",
      ":::",
      "After."
    )
  )
})

test_that("wrap_blockquotes() wraps a multi-line blockquote as one block", {
  body <- c("> Line one.", "> Line two.")

  result <- wrap_blockquotes(body)

  expect_equal(
    result,
    c("::: {.blockquote-blue}", "> Line one.", "> Line two.", ":::")
  )
})

test_that("wrap_blockquotes() wraps two separate blockquotes independently", {
  body <- c("> First quote.", "Middle text.", "> Second quote.")

  result <- wrap_blockquotes(body)

  expect_equal(
    result,
    c(
      "::: {.blockquote-blue}",
      "> First quote.",
      ":::",
      "Middle text.",
      "::: {.blockquote-blue}",
      "> Second quote.",
      ":::"
    )
  )
})

test_that("wrap_blockquotes() leaves a body with no blockquotes unchanged", {
  body <- c("Just a normal paragraph.", "Another one.")

  result <- wrap_blockquotes(body)

  expect_equal(result, body)
})
