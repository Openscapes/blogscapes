#' Open pull requests for crossposted blog changes
#'
#' Takes the copied post folders produced by [crosspost_blog()] and, for each
#' one, creates a branch, commits the copy, pushes it, and opens a pull
#' request on GitHub. `gert` handles the git side (branch/add/commit/push);
#' `gh` makes the API call that actually opens the PR.
#'
#' Each target is attempted independently -- if one target fails (e.g. a
#' destination repo has a git issue), the rest are still attempted rather
#' than stopping the whole call. Successes are reported as they happen; if
#' any target failed, a single error summarizing every failure is raised
#' after all targets have been attempted. That error does not mean nothing
#' happened -- any targets that succeeded already have a branch pushed and
#' a PR opened on GitHub.
#'
#' @param targets Character vector of paths to the copied post folders, one
#'   per destination repo -- this is the (invisible) return value of
#'   [crosspost_blog()]. Each path must live inside a git repo.
#' @param branch Name of the branch to create in each repo. Defaults to
#'   `"crosspost-<post folder name>"`, e.g.
#'   "crosspost-2026-09-09-openscapes_esip_summer_2026" -- the post folder
#'   name is taken from `targets`, same as `crosspost_blog()` uses to build
#'   each target path. Pass a different value to use a custom name.
#' @param base Base branch to open the PR against. Default "main".
#' @param remote Name of the git remote to push to. Default "origin".
#'
#' @return Invisibly, a character vector of the created PR URLs.
#'
#' @examples
#' \dontrun{
#' targets <- crosspost_blog(
#'   post = "website-new/blog/2026-09-09-openscapes_esip_summer_2026",
#'   root = "~/Documents/repos/github/openscapes/crossposting",
#'   destinations = c(
#'     nasa = "NASA-Openscapes.github.io/news",
#'     nmfs = "nmfs-openscapes.github.io/blog"
#'   )
#' )
#'
#' # Uses branch "crosspost-2026-09-09-openscapes_esip_summer_2026" by default
#' open_crosspost_prs(targets)
#' }
#' @export
open_crosspost_prs <- function(
  targets,
  branch = NULL,
  base = "main",
  remote = "origin"
) {
  if (is.null(branch)) {
    branch <- paste0("crosspost-", fs::path_file(targets[[1]]))
  }

  pr_urls <- character(length(targets))
  failures <- list()

  for (i in seq_along(targets)) {
    result <- tryCatch(
      open_crosspost_pr_for_target(targets[[i]], branch, base, remote),
      error = function(e) e
    )

    if (inherits(result, "error")) {
      failures[[targets[[i]]]] <- conditionMessage(result)
      next
    }

    pr_urls[i] <- result
  }

  if (length(failures) > 0) {
    n <- length(failures)
    bullets <- paste0("{.path ", names(failures), "}: ", unlist(failures))
    names(bullets) <- rep("x", n)

    cli::cli_abort(c(
      "Failed to open a PR for {n} target{?s}:",
      bullets,
      "i" = "Any other targets succeeded and already have a branch pushed and a PR opened."
    ))
  }

  invisible(pr_urls)
}

#' Branch, commit, push, and open a PR for one crosspost target
#'
#' The per-target body of [open_crosspost_prs()], split out so it can be
#' wrapped in `tryCatch()` without one target's failure aborting the
#' whole loop.
#'
#' @inheritParams open_crosspost_prs
#' @param target A single path from `targets`.
#'
#' @return The opened PR's URL.
#' @noRd
open_crosspost_pr_for_target <- function(target, branch, base, remote) {
  target <- fs::path_real(target)
  post_name <- fs::path_file(target)
  repo <- gert::git_find(target)

  gert::git_branch_create(branch, repo = repo)
  gert::git_add(fs::path_rel(target, start = repo), repo = repo)
  gert::git_commit(paste("Crosspost:", post_name), repo = repo)
  gert::git_push(
    remote = remote,
    refspec = paste0("refs/heads/", branch),
    set_upstream = TRUE,
    repo = repo
  )

  remote_url <- gert::git_remote_info(remote, repo = repo)$url
  owner_repo <- sub("^.*[:/]([^/]+/[^/]+?)(\\.git)?$", "\\1", remote_url)
  parts <- strsplit(owner_repo, "/")[[1]]

  pr <- gh::gh(
    "POST /repos/{owner}/{repo}/pulls",
    owner = parts[1],
    repo = parts[2],
    title = paste("Crosspost:", post_name),
    head = branch,
    base = base
  )

  cli::cli_inform(c(
    "v" = "Opened PR for {.val {post_name}} -> {.val {owner_repo}}: {.url {pr$html_url}}"
  ))

  pr$html_url
}
