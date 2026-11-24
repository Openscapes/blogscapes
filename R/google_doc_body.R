#' Strip base64 data: URI images from a post body
#'
#' Google Drive's Markdown export encodes any inline image it doesn't have
#' a separate file for as a base64 `data:` URI reference -- this commonly
#' happens with emoji pasted from Slack (e.g. `:star2:`), since Slack
#' renders shortcodes as small custom images rather than plain Unicode
#' characters. These aren't images the author intentionally added, and
#' the base64 payload can be arbitrarily large, so each
#' `![alt][ref]` / `[ref]: <data:...>` pair is replaced by its plain alt
#' text and the now-unused reference definition is dropped.
#'
#' @param body Character vector of body lines, e.g. `parse_doc_header()`'s
#'   `body` element.
#'
#' @return The character vector of body lines, with any `data:` URI image
#'   usages replaced by their alt text and their reference definitions
#'   removed.
#' @noRd
strip_data_uri_images <- function(body) {
  definition_pattern <- "^\\[([^]]+)\\]:\\s*<data:image/[^>]*>\\s*$"
  definitions <- grep(definition_pattern, body)
  if (length(definitions) == 0) {
    return(body)
  }

  refs <- sub(definition_pattern, "\\1", body[definitions])

  out <- body[-definitions]
  for (ref in refs) {
    usage_pattern <- paste0("!\\[([^]]*)\\]\\[", ref, "\\]")
    out <- sub(usage_pattern, "\\1", out)
  }

  out
}

#' Strip bold markers that wrap an entire Markdown heading
#'
#' Google Drive's Markdown export sometimes renders a Google Doc heading as
#' both a Markdown heading (`##`) and bold (`**...**`), e.g. a Doc's "Heading
#' 2" style becomes `## **Some heading**` instead of `## Some heading`. The
#' extra bold isn't visible in the doc itself, but shows up as unwanted
#' boldface in a rendered Quarto site's table of contents.
#'
#' Only strips bold that wraps the heading's *entire* text -- a heading with
#' bold around part of its text (e.g. `## Some **bold** word`) is left
#' alone, since that bold is presumably intentional.
#'
#' @param body Character vector of body lines, e.g. `parse_doc_header()`'s
#'   `body` element.
#'
#' @return The character vector of body lines, with fully-bolded headings
#'   unwrapped.
#' @noRd
strip_heading_bold <- function(body) {
  sub("^(#+)\\s+\\*\\*(.+)\\*\\*\\s*$", "\\1 \\2", body)
}

#' Wrap blockquotes in a blue Quarto callout div
#'
#' Google Drive's Markdown export renders a Google Doc blockquote as a plain
#' Markdown blockquote (lines starting with `>`), which gets the Quarto
#' theme's default blockquote styling. The Openscapes blog instead wants
#' blockquotes to appear with a blue vertical line, which the theme provides
#' via a `.blockquote-blue` fenced div.
#'
#' Each contiguous run of `>`-prefixed lines is wrapped as one block, so a
#' multi-line quote becomes a single `.blockquote-blue` div rather than one
#' per line.
#'
#' @param body Character vector of body lines, e.g. `parse_doc_header()`'s
#'   `body` element.
#'
#' @return The character vector of body lines, with each blockquote run
#'   wrapped in `::: {.blockquote-blue}` / `:::` fence lines.
#' @noRd
wrap_blockquotes <- function(body) {
  is_quote <- grepl("^>", body)
  if (!any(is_quote)) {
    return(body)
  }

  starts <- which(is_quote & !c(FALSE, is_quote[-length(is_quote)]))
  ends <- which(is_quote & !c(is_quote[-1], FALSE))

  out <- character(0)
  i <- 1
  n <- length(body)
  run <- 1

  while (i <= n) {
    if (run <= length(starts) && i == starts[run]) {
      out <- c(
        out,
        "::: {.blockquote-blue}",
        body[starts[run]:ends[run]],
        ":::"
      )
      i <- ends[run] + 1
      run <- run + 1
    } else {
      out <- c(out, body[i])
      i <- i + 1
    }
  }

  out
}
