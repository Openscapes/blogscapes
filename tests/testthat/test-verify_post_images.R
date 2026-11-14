local_post <- function(qmd_lines, images = character(0), env = parent.frame()) {
  post <- withr::local_tempdir(.local_envir = env)
  writeLines(qmd_lines, fs::path(post, "index.qmd"))
  for (image in images) {
    fs::file_create(fs::path(post, image))
  }
  post
}

test_that("verify_post_images() informs success when all images are self-contained", {
  post <- local_post(
    c(
      "---",
      "image: cover.jpg",
      "---",
      "![alt text](./inline.png)"
    ),
    images = c("cover.jpg", "inline.png")
  )

  expect_message(
    result <- verify_post_images(post),
    "2 images are self-contained"
  )
  expect_true(result)
})

test_that("verify_post_images() informs success with singular wording for one image", {
  post <- local_post(c("---", "image: cover.jpg", "---"), images = "cover.jpg")

  expect_message(verify_post_images(post), "1 image is self-contained")
})

test_that("verify_post_images() informs success with zero images", {
  post <- local_post(c("---", "title: no images here", "---"))

  expect_message(verify_post_images(post), "0 images are self-contained")
})

test_that("verify_post_images() errors when an image reference points outside the post", {
  post <- local_post(c("---", "image: ../cover.jpg", "---"))

  expect_error(verify_post_images(post), "outside its own folder")
})

test_that("verify_post_images() errors when a referenced image is missing", {
  post <- local_post(c("---", "image: cover.jpg", "---"))

  expect_error(verify_post_images(post), "doesn't exist")
})
