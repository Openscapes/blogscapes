# build_qmd_front_matter() messages about a single unknown category

    Code
      build_qmd_front_matter(header, post_name = "2026-11-19_my-post", base_url = "https://openscapes.org/blog")
    Message
      ! Category "art-history" is not in the known categories list -- double check it's intentional.
      i See <https://github.com/Openscapes/website-new/wiki/Adding-blog-posts#categories>.
    Output
      [1] "---"                                                  
      [2] "title: \"My post title\""                             
      [3] "date: 2026-11-19"                                     
      [4] "citation:"                                            
      [5] "  url: https://openscapes.org/blog/2026-11-19_my-post"
      [6] "categories: [blog, art-history]"                      
      [7] "---"                                                  

# build_qmd_front_matter() messages about multiple unknown categories

    Code
      build_qmd_front_matter(header, post_name = "2026-11-19_my-post", base_url = "https://openscapes.org/blog")
    Message
      ! Categories "foo" and "bar" are not in the known categories list -- double check they're intentional.
      i See <https://github.com/Openscapes/website-new/wiki/Adding-blog-posts#categories>.
    Output
      [1] "---"                                                  
      [2] "title: \"My post title\""                             
      [3] "date: 2026-11-19"                                     
      [4] "citation:"                                            
      [5] "  url: https://openscapes.org/blog/2026-11-19_my-post"
      [6] "categories: [foo, bar]"                               
      [7] "---"                                                  

