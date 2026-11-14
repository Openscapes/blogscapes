image_block_fields <- c("image_name", "caption_text", "alt_text")

#' Replace image placeholder blocks with Quarto figure syntax
#'
#' Looks for three consecutive lines of the form:
#'
#' ```
#' image_name: cover.jpg
#' caption_text: A caption describing the image
#' alt_text: A longer accessible description of the image
#' ```
#'
#' anywhere in a post body, and replaces each occurrence with a centered
#' Quarto figure div referencing `./<image_name>`, with `caption_text` as
#' the figure caption and `alt_text` as its `fig-alt`.
#'
#' The three labels (`image_name`, `caption_text`, `alt_text`) were chosen
#' to be unlikely to appear as the start of three consecutive lines of
#' ordinary prose. If a line starts with `image_name:` but the next two
#' lines don't complete the block (missing, out of order, or not
#' immediately following), a message names the problem and the line is
#' left as plain text; generation continues rather than stopping.
#'
#' `image_name` is a bare filename, expected to already exist in the post
#' folder -- this function does not create, move, or validate the image
#' file itself; [verify_post_images()] still catches a missing file at
#' crosspost time.
#'
#' @param body Character vector of body lines, e.g. `parse_doc_header()`'s
#'   `body` element.
#'
#' @return A list with `body` (character vector, each matched block
#'   replaced by the corresponding Quarto figure div) and `image_names`
#'   (character vector of the `image_name` values found, for downloading).
#' @noRd
render_image_blocks <- function(body) {
  pattern <- paste0(
    "^\\**(",
    paste(image_block_fields, collapse = "|"),
    "):\\**\\s*"
  )
  field_of <- function(line) sub(":.*$", "", sub("^\\**", "", line))

  # Google Drive's Markdown export backslash-escapes underscores
  # (`image_name:` becomes `image\_name:`), since `_` is Markdown italics
  # syntax. Unescape before matching.
  unescaped <- gsub("\\\\_", "_", body)

  out <- character(0)
  image_names <- character(0)
  i <- 1
  n <- length(body)

  while (i <= n) {
    if (
      !grepl(pattern, unescaped[i]) || field_of(unescaped[i]) != "image_name"
    ) {
      out <- c(out, body[i])
      i <- i + 1
      next
    }

    has_caption <- i + 1 <= n &&
      grepl(pattern, unescaped[i + 1]) &&
      field_of(unescaped[i + 1]) == "caption_text"
    has_alt <- i + 2 <= n &&
      grepl(pattern, unescaped[i + 2]) &&
      field_of(unescaped[i + 2]) == "alt_text"

    if (has_caption && has_alt) {
      values <- trimws(sub(pattern, "", unescaped[i:(i + 2)]))
      out <- c(out, render_image_block(values[1], values[2], values[3]))
      image_names <- c(image_names, values[1])
      i <- i + 3
    } else {
      cli::cli_inform(c(
        "!" = "Found {.field image_name:} without a complete {.field caption_text:}/{.field alt_text:} block right after it -- leaving as plain text: {.val {body[i]}}"
      ))
      out <- c(out, body[i])
      i <- i + 1
    }
  }

  list(body = out, image_names = image_names)
}

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

render_image_block <- function(image_name, caption_text, alt_text) {
  alt_text <- gsub("\"", "'", alt_text)

  c(
    "::: {style=\"text-align:center;\"}",
    paste0(
      "![",
      caption_text,
      "](./",
      image_name,
      ")",
      "{fig-alt=\"",
      alt_text,
      "\" fig-align=\"center\" width=\"60%\"}"
    ),
    ":::"
  )
}
