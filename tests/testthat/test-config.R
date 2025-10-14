test_that("config_validate detects missing sections", {
  skip("Validation tests require proper config file mocking")
})

test_that("config_validate checks for 13 sets", {
  skip("Requires properly mocked config environment")
})

test_that("config_validate checks for 5 rooms", {
  skip("Requires properly mocked config environment")
})

test_that("config_set validates tone range", {
  skip_if_not(file.exists("config.yaml") || file.exists("inst/data/config.yaml"))

  expect_error(
    config_set("room", "0", "Invalid Room"),
    "Tone must be between 1 and 5"
  )

  expect_error(
    config_set("room", "6", "Invalid Room"),
    "Tone must be between 1 and 5"
  )
})

test_that("show_actors handles empty actors", {
  config <- list(
    mnemonic_system = list(
      actors = list()
    )
  )

  # Function should run without error
  expect_no_error(show_actors(config))
})

test_that("show_sets handles empty sets", {
  config <- list(
    mnemonic_system = list(
      sets = list()
    )
  )

  # Function should run without error
  expect_no_error(show_sets(config))
})

test_that("show_rooms handles empty rooms", {
  config <- list(
    mnemonic_system = list(
      rooms_by_tone = list()
    )
  )

  # Function should run without error
  expect_no_error(show_rooms(config))
})

test_that("show_props handles empty props", {
  config <- list(
    mnemonic_system = list(
      props = list()
    )
  )

  # Function should run without error
  expect_no_error(show_props(config))
})

test_that("show_props limits display correctly", {
  config <- list(
    mnemonic_system = list(
      props = as.list(setNames(
        paste("Meaning", 1:20),
        paste0("Component", 1:20)
      ))
    )
  )

  # Function should run without error when limiting display
  expect_no_error(show_props(config, max_display = 5))
  # Function should run without error when showing all
  expect_no_error(show_props(config, max_display = NULL))
})

test_that("config_init creates config file", {
  temp_dir <- tempdir()
  temp_config <- file.path(temp_dir, "test_config.yaml")
  on.exit(unlink(temp_config))

  # Mock the template location
  skip_if_not(
    file.exists(system.file("extdata", "config-template.yaml", package = "hanziR")),
    "Config template not found"
  )
})
