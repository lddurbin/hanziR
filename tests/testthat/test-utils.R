test_that("truncate_text works correctly", {
  expect_equal(truncate_text("short", max_len = 10), "short")
  expect_equal(truncate_text("this is a very long text", max_len = 10), "this is...")
  expect_equal(truncate_text("exact", max_len = 5), "exact")
})

test_that("format_timestamp returns ISO 8601 format", {
  timestamp <- format_timestamp(as.POSIXct("2025-10-14 10:30:00", tz = "UTC"))
  expect_match(timestamp, "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z")
})

test_that("format_date returns YYYY-MM-DD format", {
  date <- format_date(as.POSIXct("2025-10-14 10:30:00", tz = "UTC"))
  expect_match(date, "\\d{4}-\\d{2}-\\d{2}")
})

