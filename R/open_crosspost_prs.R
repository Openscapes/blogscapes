#' Open pull requests for crossposted blog changes
#'
#' Takes the copied post folders produced by [crosspost_blog()] and, for each
#' one, creates a branch, commits the copy, pushes it, and opens a pull
#' request on GitHub. `gert` handles the git side (branch/add/commit/push);
#' `gh` makes the API call that actually opens the PR.
#'
#' @param targets Character vector of paths to the copied post folders, one
#'   per destination repo -- this is the (invisible) return value of
#'   [crosspost_blog()]. Each path must live inside a git repo.
#' @param branch Name of the branch to create in each repo, e.g.
#'   "crosspost-2026-09-09-openscapes_esip_summer_2026".
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
#' open_crosspost_prs(targets, branch = "crosspost-esip-summer-2026")
#' }
#' @export
open_crosspost_prs <- function(
  targets,
  branch,
  base = "main",
  remote = "origin"
) {
  pr_urls <- character(length(targets))

  for (i in seq_along(targets)) {
    target <- fs::path_abs(targets[[i]])
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

    pr_urls[i] <- pr$html_url
    message("Opened PR for ", post_name, " -> ", owner_repo, ": ", pr$html_url)
  }

  invisible(pr_urls)
}
