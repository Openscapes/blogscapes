doc_header_fields <- c(
  "Blog Title",
  "Publish date",
  "Location",
  "URL",
  "Authors",
  "Image",
  "Categories"
)

#' Split a Google Doc's metadata block from its body
#'
#' Google Docs produced from the Openscapes blog template start with a block
#' of plain-text `Field: value` lines (see [doc_header_fields]) before the
#' actual post content. This reads those lines into a named list and returns
#' the remaining lines as the body, unchanged.
#'
#' Google Drive's Markdown export bolds each of these lines, but not always
#' consistently -- `Blog Title:` may become `**Blog Title:**` or
#' `**Blog Title**:`, depending on where the bold formatting was applied in
#' the doc. The field-name match tolerates `**` on either side of the colon.
#'
#' @param content Character vector of lines, e.g. from `readLines()`.
#'
#' @return A list with one element per recognized field found (named by
#'   field, e.g. `header[["Blog Title"]]`) plus `body`, the character vector
#'   of lines after the metadata block. Fields not present in `content` are
#'   absent from the result, not `NA`.
#' @noRd
parse_doc_header <- function(content) {
  pattern <- paste0(
    "^\\**(",
    paste(doc_header_fields, collapse = "|"),
    ")\\**:\\**\\s*"
  )

  n_header <- 0
  for (line in content) {
    if (!grepl(pattern, line)) {
      break
    }
    n_header <- n_header + 1
  }

  header_lines <- content[seq_len(n_header)]
  body <- if (n_header == 0) content else content[-seq_len(n_header)]

  values <- trimws(sub(pattern, "", header_lines))
  names(values) <- sub(
    "\\**$",
    "",
    sub(":.*$", "", sub("^\\**", "", header_lines))
  )

  result <- as.list(values[nzchar(values)])
  result$body <- body
  result
}

#' Derive a post's date from its folder name
#'
#' @param post_name Post folder name, expected to start with a `YYYY-MM-DD`
#'   date, `-` or `_` separated from the rest of the name.
#'
#' @return The leading date, as a string (`"YYYY-MM-DD"`).
#' @noRd
post_name_date <- function(post_name) {
  match <- regmatches(post_name, regexpr("^\\d{4}-\\d{2}-\\d{2}", post_name))
  if (length(match) == 0) {
    stop(
      "post_name must start with a YYYY-MM-DD date to derive `date`: ",
      post_name
    )
  }
  match
}

#' Build a post's citation URL
#'
#' @param base_url Base URL the post is published under, e.g.
#'   "https://openscapes.org/blog/".
#' @param post_name Post folder name, used as the URL's final path segment.
#'
#' @return The full post URL, as a string.
#' @noRd
post_citation_url <- function(base_url, post_name) {
  paste0(sub("/$", "", base_url), "/", post_name)
}

#' Build Quarto YAML front matter from a parsed doc header
#'
#' @param header A list as returned by [parse_doc_header()].
#' @param post_name Post folder name, used to derive `date` and
#'   `citation.url`.
#' @param base_url Base URL the post is published under, passed to
#'   [post_citation_url()] to build `citation.url`.
#' @param authors_sheet A Google Sheet, passed to [lookup_authors()] to
#'   resolve the doc's `Authors:` field.
#'
#' @return A character vector of YAML front matter lines, including the
#'   leading and trailing `---` delimiters.
#' @noRd
build_qmd_front_matter <- function(
  header,
  post_name,
  base_url,
  authors_sheet = default_authors_sheet
) {
  date <- header[["Publish date"]]
  if (is.null(date)) {
    date <- post_name_date(post_name)
  }

  if (!is.null(header[["URL"]])) {
    message(
      "Doc's 'URL:' field is ignored -- citation.url is always derived ",
      "from base_url and post_name."
    )
  }
  url <- post_citation_url(base_url, post_name)

  authors <- NULL
  if (!is.null(header[["Authors"]])) {
    authors <- lookup_authors(header[["Authors"]], authors_sheet)
  }

  categories <- NULL
  if (!is.null(header[["Categories"]])) {
    categories <- trimws(strsplit(header[["Categories"]], ",")[[1]])
  }

  c(
    "---",
    paste0("title: \"", header[["Blog Title"]], "\""),
    if (!is.null(authors)) c("author:", authors),
    paste0("date: ", date),
    "citation:",
    paste0("  url: ", url),
    if (!is.null(categories)) {
      paste0("categories: [", paste(categories, collapse = ", "), "]")
    },
    if (!is.null(header[["Image"]])) paste0("image: ", header[["Image"]]),
    "---"
  )
}
