test_that("the draft template parses as every recognized header field", {
  template_path <- system.file(
    "extdata",
    "google_doc_draft_template.md",
    package = "blogscapes"
  )
  content <- readLines(template_path)

  header <- parse_doc_header(content)

  expect_setequal(
    names(header),
    c(
      "Description",
      "Publish date",
      "Location",
      "URL",
      "Authors",
      "Image",
      "Categories",
      "body"
    )
  )
})

test_that("the draft template's example image block is instructional, not live syntax", {
  template_path <- system.file(
    "extdata",
    "google_doc_draft_template.md",
    package = "blogscapes"
  )
  content <- readLines(template_path)

  header <- parse_doc_header(content)
  images <- render_image_blocks(header$body)

  # The "ex: " prefix keeps this from being mistaken for a real block by
  # render_image_blocks() -- it's meant to be edited by the author, not
  # auto-rendered as-is.
  expect_equal(images$image_names, character(0))
})

test_that("new_google_doc_draft() uploads the template and opens it by default", {
  uploaded <- NULL
  browsed <- NULL

  local_mocked_bindings(
    drive_upload = function(media, path, name, type) {
      uploaded <<- list(media = media, path = path, name = name, type = type)
      structure(list(name = name), class = "dribble")
    },
    drive_browse = function(file) {
      browsed <<- file
      invisible(file)
    },
    .package = "googledrive"
  )

  result <- new_google_doc_draft("2026-11-19-my-title")

  expect_equal(uploaded$name, "2026-11-19-my-title")
  expect_equal(uploaded$type, "document")
  expect_true(fs::file_exists(uploaded$media))
  expect_false(is.null(browsed))
})

test_that("new_google_doc_draft() does not browse when browse = FALSE", {
  browsed <- FALSE

  local_mocked_bindings(
    drive_upload = function(media, path, name, type) {
      structure(list(name = name), class = "dribble")
    },
    drive_browse = function(file) {
      browsed <<- TRUE
      invisible(file)
    },
    .package = "googledrive"
  )

  new_google_doc_draft("2026-11-19-my-title", browse = FALSE)

  expect_false(browsed)
})

test_that("new_google_doc_draft() passes path through to drive_upload()", {
  uploaded_path <- NULL

  local_mocked_bindings(
    drive_upload = function(media, path, name, type) {
      uploaded_path <<- path
      structure(list(name = name), class = "dribble")
    },
    drive_browse = function(file) invisible(file),
    .package = "googledrive"
  )

  new_google_doc_draft("2026-11-19-my-title", path = "some-folder-id")

  expect_equal(uploaded_path, "some-folder-id")
})
