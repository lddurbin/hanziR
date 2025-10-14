test_that("create_empty_cards creates v2.0 structure", {
  result <- create_empty_cards()
  expect_equal(result$version, "2.0")
  expect_true("created" %in% names(result))
  expect_type(result$cards, "list")
  expect_length(result$cards, 0)
})

test_that("get_cards_tibble handles empty cards", {
  # Create a temporary cards file
  temp_file <- tempfile(fileext = ".yaml")
  on.exit(unlink(temp_file))

  data <- create_empty_cards()
  write_cards(data, temp_file)

  result <- get_cards_tibble(temp_file)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true("keyword" %in% names(result))
  expect_true("mnemonic" %in% names(result))
})

test_that("get_cards_tibble handles v1.0 cards (backward compatibility)", {
  # Create a temporary v1.0 cards file
  temp_file <- tempfile(fileext = ".yaml")
  on.exit(unlink(temp_file))

  # v1.0 format - no keyword or mnemonic
  data <- list(
    version = "1.0",
    created = "2025-10-14",
    cards = list(
      list(
        char = "好",
        pinyin = "hǎo",
        tone = 3L,
        tone_shape = "dip",
        tone_pattern = "\\/",
        initial = "h",
        final = "ao",
        components = list("女", "子"),
        meaning = "good",
        example = "你好",
        tags = list("HSK1"),
        notes = "",
        added = "2025-10-14T10:00:00Z"
      )
    )
  )

  write_cards(data, temp_file)

  result <- get_cards_tibble(temp_file)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_false(is.na(result$char[1]))
  expect_true(nchar(result$char[1]) > 0)  # Non-empty character
  expect_true(is.na(result$keyword[1]))
  expect_true(is.null(result$mnemonic[[1]]))
})

test_that("get_cards_tibble handles v2.0 cards with mnemonic", {
  # Create a temporary v2.0 cards file
  temp_file <- tempfile(fileext = ".yaml")
  on.exit(unlink(temp_file))

  # v2.0 format - with keyword and mnemonic
  data <- list(
    version = "2.0",
    created = "2025-10-14",
    cards = list(
      list(
        char = "好",
        pinyin = "hǎo",
        tone = 3L,
        tone_shape = "dip",
        tone_pattern = "\\/",
        initial = "h",
        final = "ao",
        components = list(
          list(char = "女", meaning = "Woman"),
          list(char = "子", meaning = "Child")
        ),
        meaning = "good, well",
        keyword = "good",
        example = "你好",
        tags = list("HSK1"),
        notes = "",
        added = "2025-10-14T10:00:00Z",
        mnemonic = list(
          actor = "Hugh Jackman",
          set = "Mountain Cabin",
          room = "Bedroom",
          scene = "Test scene"
        )
      )
    )
  )

  write_cards(data, temp_file)

  result <- get_cards_tibble(temp_file)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_false(is.na(result$char[1]))
  expect_true(nchar(result$char[1]) > 0)  # Non-empty character
  expect_equal(result$keyword[1], "good")
  expect_equal(result$mnemonic[[1]]$actor, "Hugh Jackman")
  expect_equal(result$mnemonic[[1]]$scene, "Test scene")
})

test_that("get_cards_tibble handles mixed component formats", {
  # Create a temporary cards file with mixed components
  temp_file <- tempfile(fileext = ".yaml")
  on.exit(unlink(temp_file))

  data <- list(
    version = "2.0",
    created = "2025-10-14",
    cards = list(
      list(
        char = "好",
        pinyin = "hǎo",
        tone = 3L,
        components = list(
          "女",  # Simple string
          list(char = "子", meaning = "Child")  # Object with meaning
        ),
        meaning = "good",
        added = "2025-10-14T10:00:00Z"
      )
    )
  )

  write_cards(data, temp_file)

  result <- get_cards_tibble(temp_file)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_length(result$components[[1]], 2)
})
