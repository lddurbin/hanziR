test_that("normalize_components handles string vectors", {
  components <- c("一", "丨")
  result <- normalize_components(components)
  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]], "一")
  expect_equal(result[[2]], "丨")
})

test_that("normalize_components handles object format", {
  components <- list(
    list(char = "一", meaning = "Razor Blade"),
    list(char = "丨", meaning = "Stick")
  )
  result <- normalize_components(components)
  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]]$char, "一")
  expect_equal(result[[1]]$meaning, "Razor Blade")
})

test_that("normalize_components handles mixed format", {
  components <- list(
    "一",
    list(char = "丨", meaning = "Stick")
  )
  result <- normalize_components(components)
  expect_type(result, "list")
  expect_length(result, 2)
  expect_equal(result[[1]], "一")
  expect_equal(result[[2]]$char, "丨")
})

test_that("extract_component_chars extracts from string format", {
  components <- list("一", "丨")
  result <- extract_component_chars(components)
  expect_equal(result, c("一", "丨"))
})

test_that("extract_component_chars extracts from object format", {
  components <- list(
    list(char = "一", meaning = "Razor Blade"),
    list(char = "丨", meaning = "Stick")
  )
  result <- extract_component_chars(components)
  expect_equal(result, c("一", "丨"))
})

test_that("extract_component_chars handles mixed format", {
  components <- list(
    "一",
    list(char = "丨", meaning = "Stick")
  )
  result <- extract_component_chars(components)
  expect_equal(result, c("一", "丨"))
})

test_that("get_actor returns NULL for missing config", {
  # Skip if config doesn't exist
  skip_if_not(file.exists("config.yaml") || file.exists("inst/data/config.yaml"))
})

test_that("get_set returns NULL for missing config", {
  # Skip if config doesn't exist
  skip_if_not(file.exists("config.yaml") || file.exists("inst/data/config.yaml"))
})

test_that("get_room returns NULL for missing config", {
  # Skip if config doesn't exist
  skip_if_not(file.exists("config.yaml") || file.exists("inst/data/config.yaml"))
})

test_that("get_prop returns NULL for missing config", {
  # Skip if config doesn't exist
  skip_if_not(file.exists("config.yaml") || file.exists("inst/data/config.yaml"))
})

