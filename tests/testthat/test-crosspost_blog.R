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

  for (target in targets[c("nasa", "nmfs")]) {
    copied <- fs::path_rel(
      fs::dir_ls(target, recurse = TRUE, all = TRUE),
      start = target
    )
    expect_setequal(copied, c("cover.jpg", "index.qmd", "references.bib"))
  }
})

test_that("crosspost_blog() includes the source post itself in the returned targets", {
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

  expect_equal(names(targets), c("source", "nasa", "nmfs"))
  expect_equal(unname(targets["source"]), as.character(fs::path_abs(post)))
})

test_that("open_crosspost_prs() also opens a PR for the source repo, not just destinations", {
  bare <- withr::local_tempdir()
  gert::git_init(bare, bare = TRUE)

  source_repo <- withr::local_tempdir()
  gert::git_clone(bare, source_repo)
  gert::git_config_set("user.name", "Test User", repo = source_repo)
  gert::git_config_set("user.email", "test@example.com", repo = source_repo)
  writeLines("init", fs::path(source_repo, "README.md"))
  gert::git_add("README.md", repo = source_repo)
  gert::git_commit("init", repo = source_repo)
  gert::git_push(remote = "origin", repo = source_repo)

  post <- fs::path(source_repo, "2026-11-13_newsletter")
  fs::dir_create(post)
  writeLines(
    c("---", "title: x", "---", "content"),
    fs::path(post, "index.qmd")
  )

  dest_root <- withr::local_tempdir()
  fs::dir_create(fs::path(dest_root, "nasa"))

  targets <- crosspost_blog(
    post = post,
    destinations = c(nasa = fs::path(dest_root, "nasa"))
  )

  local_mocked_bindings(
    gh = function(...) list(html_url = "https://github.com/owner/repo/pull/1"),
    .package = "gh"
  )

  expect_error(open_crosspost_prs(targets), "Failed to open a PR for 1 target")

  source_branches <- gert::git_branch_list(repo = bare)$name
  expect_true("crosspost-2026-11-13_newsletter" %in% source_branches)
})
