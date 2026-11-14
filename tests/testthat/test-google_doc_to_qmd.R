test_that("google_doc_to_qmd() errors on missing base_url without creating any folder", {
  blog_dir <- withr::local_tempdir()
  post_name <- "2026-11-13-my-title"

  expect_snapshot(
    error = TRUE,
    google_doc_to_qmd(
      doc = "https://docs.google.com/document/d/FILE_ID/edit",
      post_name = post_name,
      blog_dir = blog_dir
    )
  )

  expect_false(fs::dir_exists(fs::path(blog_dir, post_name)))
})

test_that("google_doc_to_qmd() errors when blog_dir does not exist", {
  parent <- withr::local_tempdir()
  blog_dir <- fs::path(parent, ".blog")
  post_name <- "2026-11-13-my-title"

  expect_error(
    google_doc_to_qmd(
      doc = "https://docs.google.com/document/d/FILE_ID/edit",
      post_name = post_name,
      blog_dir = blog_dir,
      base_url = "https://openscapes.org/blog/"
    ),
    "`blog_dir` does not exist"
  )

  expect_false(fs::dir_exists(blog_dir))
})

test_that("google_doc_to_qmd() succeeds on retry even if a stale index.md is present", {
  blog_dir <- withr::local_tempdir()
  post_name <- "2026-11-13-my-title"
  post_dir <- fs::path(blog_dir, post_name)
  fs::dir_create(post_dir)
  writeLines(
    "stale content from a previous failed run",
    fs::path(post_dir, "index.md")
  )

  local_mocked_bindings(
    drive_download = function(file, path, type, overwrite) {
      writeLines(
        c("**Blog Title:** My post title", "**Publish date:** 2026-11-13"),
        path
      )
      invisible(NULL)
    },
    .package = "googledrive"
  )
  local_mocked_bindings(
    download_doc_images = function(...) invisible(character(0))
  )

  target <- google_doc_to_qmd(
    doc = "https://docs.google.com/document/d/FILE_ID/edit",
    post_name = post_name,
    blog_dir = blog_dir,
    base_url = "https://openscapes.org/blog/"
  )

  expect_true(fs::file_exists(target))
  expect_false(fs::file_exists(fs::path(post_dir, "index.md")))
})
