test_that("tone shape generation works", {
  expect_equal(get_tone_shape(1), "flat")
  expect_equal(get_tone_shape(2), "rise")
  expect_equal(get_tone_shape(3), "dip")
  expect_equal(get_tone_shape(4), "fall")
  expect_equal(get_tone_shape(5), "neutral")
})

test_that("tone pattern generation works", {
  expect_equal(get_tone_pattern(1), "---")
  expect_equal(get_tone_pattern(2), "/")
  expect_equal(get_tone_pattern(3), "\\/")
  expect_equal(get_tone_pattern(4), "\\")
  expect_equal(get_tone_pattern(5), ".")
})

test_that("tone validation works", {
  expect_true(validate_tone(1))
  expect_true(validate_tone(5))
  expect_false(validate_tone(0))
  expect_false(validate_tone(6))
  expect_false(validate_tone(NA))
})

test_that("format_tone creates accessible output", {
  result <- format_tone(3, include_color = FALSE)
  expect_match(result, "Tone 3")
  expect_match(result, "dip")
  expect_match(result, "\\\\/")
})

