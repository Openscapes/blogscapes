local_fake_repo <- function(post_name, env = parent.frame()) {
  repo <- withr::local_tempdir(.local_envir = env)
  gert::git_init(repo)
  gert::git_config_set("user.name", "Test User", repo = repo)
  gert::git_config_set("user.email", "test@example.com", repo = repo)
  writeLines("init", fs::path(repo, "README.md"))
  gert::git_add("README.md", repo = repo)
  gert::git_commit("init", repo = repo)

  target <- fs::path(repo, post_name)
  fs::dir_create(target)
  writeLines("content", fs::path(target, "index.qmd"))

  target
}

test_that("open_crosspost_prs() derives branch from the post folder name by default", {
  target <- local_fake_repo("2026-11-13_newsletter")
  repo <- gert::git_find(target)

  used_branch <- NULL
  local_mocked_bindings(
    git_push = function(remote, refspec, set_upstream, repo) {
      used_branch <<- sub("^refs/heads/", "", refspec)
      invisible(NULL)
    },
    git_remote_info = function(remote, repo) {
      list(url = "https://github.com/owner/repo.git")
    },
    .package = "gert"
  )
  local_mocked_bindings(
    gh = function(...) list(html_url = "https://github.com/owner/repo/pull/1"),
    .package = "gh"
  )

  open_crosspost_prs(target)

  expect_equal(used_branch, "crosspost-2026-11-13_newsletter")
})

test_that("open_crosspost_prs() uses an explicit branch when given", {
  target <- local_fake_repo("2026-11-13_newsletter")

  used_branch <- NULL
  local_mocked_bindings(
    git_push = function(remote, refspec, set_upstream, repo) {
      used_branch <<- sub("^refs/heads/", "", refspec)
      invisible(NULL)
    },
    git_remote_info = function(remote, repo) {
      list(url = "https://github.com/owner/repo.git")
    },
    .package = "gert"
  )
  local_mocked_bindings(
    gh = function(...) list(html_url = "https://github.com/owner/repo/pull/1"),
    .package = "gh"
  )

  open_crosspost_prs(target, branch = "my-custom-branch")

  expect_equal(used_branch, "my-custom-branch")
})
