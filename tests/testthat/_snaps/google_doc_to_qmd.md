# google_doc_to_qmd() errors on missing base_url without creating any folder

    Code
      google_doc_to_qmd(doc = "https://docs.google.com/document/d/FILE_ID/edit",
        post_name = post_name, blog_dir = blog_dir)
    Condition
      Error in `google_doc_to_qmd()`:
      ! `base_url` is required: the post's citation.url can't be built without it.

