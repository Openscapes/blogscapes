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
