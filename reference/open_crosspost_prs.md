# Open pull requests for crossposted blog changes

Takes the copied post folders produced by \[crosspost_blog()\] and, for
each one, creates a branch, commits the copy, pushes it, and opens a
pull request on GitHub. \`gert\` handles the git side
(branch/add/commit/push); \`gh\` makes the API call that actually opens
the PR.

## Usage

``` r
open_crosspost_prs(targets, branch, base = "main", remote = "origin")
```

## Arguments

- targets:

  Character vector of paths to the copied post folders, one per
  destination repo – this is the (invisible) return value of
  \[crosspost_blog()\]. Each path must live inside a git repo.

- branch:

  Name of the branch to create in each repo, e.g.
  "crosspost-2026-09-09-openscapes_esip_summer_2026".

- base:

  Base branch to open the PR against. Default "main".

- remote:

  Name of the git remote to push to. Default "origin".

## Value

Invisibly, a character vector of the created PR URLs.

## Examples

``` r
if (FALSE) { # \dontrun{
targets <- crosspost_blog(
  post = "website-new/blog/2026-09-09-openscapes_esip_summer_2026",
  root = "~/Documents/repos/github/openscapes/crossposting",
  destinations = c(
    nasa = "NASA-Openscapes.github.io/news",
    nmfs = "nmfs-openscapes.github.io/blog"
  )
)

open_crosspost_prs(targets, branch = "crosspost-esip-summer-2026")
} # }
```
