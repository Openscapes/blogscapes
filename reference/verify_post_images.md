# Verify a blog post's images are self-contained

Scans a post's \`.qmd\`/\`.Rmd\` file for every image reference (YAML
front matter \`image:\` field and body \`\![\]()\` syntax) and checks
that each one resolves to a file inside the post's own folder, and that
the file actually exists there. \`crosspost_blog()\` copies the post
folder as-is, so a reference pointing outside of it would silently
produce a broken image in the destination repo.

## Usage

``` r
verify_post_images(post = getwd())
```

## Arguments

- post:

  Path to the blog post folder to check. Defaults to the current working
  directory, i.e. run this from inside the blog post's own folder.

## Value

Invisibly, \`TRUE\` if all image references resolve to existing files
inside \`post\`. Errors otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
verify_post_images("website-new/blog/2026-09-09-openscapes_esip_summer_2026")
} # }
```
