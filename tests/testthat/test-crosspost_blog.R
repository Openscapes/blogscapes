local_rendered_post <- function(env = parent.frame()) {
  post <- withr::local_tempdir(.local_envir = env)
  writeLines(
    c("---", "image: cover.jpg", "---", "content"),
    fs::path(post, "index.qmd")
  )
  fs::file_create(fs::path(post, "cover.jpg"))
  writeLines("refs", fs::path(post, "references.bib"))

  writeLines("html", fs::path(post, "index.html"))
  fs::dir_create(fs::path(post, "index_files", "libs"))
  writeLines("js", fs::path(post, "index_files", "libs", "bootstrap.js"))
  fs::dir_create(fs::path(post, ".quarto"))
  writeLines("cache", fs::path(post, ".quarto", "cache.bin"))
  fs::dir_create(fs::path(post, "site_libs", "quarto-nav"))
  writeLines("nav", fs::path(post, "site_libs", "quarto-nav", "quarto-nav.js"))

  post
}

test_that("copy_post_contents() copies only the source file, its images, and references.bib", {
  post <- local_rendered_post()
  target <- fs::path(withr::local_tempdir(), "my-post")

  copy_post_contents(post, target, overwrite = FALSE)

  copied <- fs::path_rel(
    fs::dir_ls(target, recurse = TRUE, all = TRUE),
    start = target
  )

  expect_setequal(copied, c("cover.jpg", "index.qmd", "references.bib"))
})

test_that("copy_post_contents() excludes an entire *_files/ folder, not just its name", {
  post <- local_rendered_post()
  target <- fs::path(withr::local_tempdir(), "my-post")

  copy_post_contents(post, target, overwrite = FALSE)

  expect_false(fs::dir_exists(fs::path(target, "index_files")))
  expect_false(fs::file_exists(fs::path(
    target,
    "index_files",
    "libs",
    "bootstrap.js"
  )))
})

test_that("copy_post_contents() excludes files it has no reason to copy, even unrecognized ones", {
  post <- local_rendered_post()
  fs::dir_create(fs::path(post, "some-future-quarto-cache-dir"))
  writeLines("?", fs::path(post, "some-future-quarto-cache-dir", "mystery.bin"))
  writeLines("notes", fs::path(post, "scratch-notes.txt"))

  target <- fs::path(withr::local_tempdir(), "my-post")
  copy_post_contents(post, target, overwrite = FALSE)

  expect_false(fs::dir_exists(fs::path(target, "some-future-quarto-cache-dir")))
  expect_false(fs::file_exists(fs::path(target, "scratch-notes.txt")))
})

test_that("copy_post_contents() works without a references.bib", {
  post <- withr::local_tempdir()
  writeLines(
    c("---", "image: cover.jpg", "---", "content"),
    fs::path(post, "index.qmd")
  )
  fs::file_create(fs::path(post, "cover.jpg"))

  target <- fs::path(withr::local_tempdir(), "my-post")
  copy_post_contents(post, target, overwrite = FALSE)

  copied <- fs::path_rel(
    fs::dir_ls(target, recurse = TRUE, all = TRUE),
    start = target
  )
  expect_setequal(copied, c("cover.jpg", "index.qmd"))
})

test_that("crosspost_blog() copies source content but not render artifacts to each destination", {
  post <- local_rendered_post()
  dest_root <- withr::local_tempdir()
  fs::dir_create(fs::path(dest_root, "nasa"))
  fs::dir_create(fs::path(dest_root, "nmfs"))

  targets <- crosspost_blog(
    post = post,
    destinations = c(
      nasa = fs::path(dest_root, "nasa"),
      nmfs = fs::path(dest_root, "nmfs")
    )
  )

  for (target in targets) {
    copied <- fs::path_rel(
      fs::dir_ls(target, recurse = TRUE, all = TRUE),
      start = target
    )
    expect_setequal(copied, c("cover.jpg", "index.qmd", "references.bib"))
  }
})
