#' Find the cards.yaml file
#'
#' Looks for cards.yaml in the current directory, then in inst/data/
#'
#' @param must_exist If TRUE, abort if file doesn't exist
#' @return Path to cards.yaml or NULL
#' @keywords internal
find_cards_file <- function(must_exist = TRUE) {
  # Check current directory first
  if (file.exists("cards.yaml")) {
    return(normalizePath("cards.yaml"))
  }

  # Check inst/data/
  inst_path <- "inst/data/cards.yaml"
  if (file.exists(inst_path)) {
    return(normalizePath(inst_path))
  }

  # Check installed package location
  pkg_path <- system.file("data", "cards.yaml", package = "hanziR")
  if (pkg_path != "") {
    return(pkg_path)
  }

  if (must_exist) {
    cli::cli_abort(c(
      "Could not find {.file cards.yaml}",
      "i" = "Run {.code hanzi init} to create one"
    ))
  }

  NULL
}

#' Get the default cards.yaml path for initialization
#'
#' Returns the path where cards.yaml should be created
#'
#' @return Path for new cards.yaml
#' @keywords internal
get_init_path <- function() {
  # Prefer inst/data/ if it exists, otherwise current directory
  if (dir.exists("inst/data")) {
    return("inst/data/cards.yaml")
  }
  return("cards.yaml")
}

#' Format a timestamp
#'
#' @param time POSIXct time object
#' @return ISO 8601 formatted string
#' @keywords internal
format_timestamp <- function(time = Sys.time()) {
  format(time, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

#' Format a date
#'
#' @param time POSIXct time object
#' @return Date string (YYYY-MM-DD)
#' @keywords internal
format_date <- function(time = Sys.time()) {
  format(time, "%Y-%m-%d")
}

#' Check if a character is valid Hanzi
#'
#' Basic check if character is in CJK unicode range
#'
#' @param char Character to check
#' @return Logical
#' @keywords internal
is_hanzi <- function(char) {
  if (is.na(char) || nchar(char) == 0) return(FALSE)

  # Get unicode codepoint
  code <- utf8ToInt(char)[1]

  # CJK Unified Ideographs: U+4E00 to U+9FFF
  # CJK Extension A: U+3400 to U+4DBF
  (code >= 0x4E00 && code <= 0x9FFF) ||
    (code >= 0x3400 && code <= 0x4DBF)
}

#' Truncate text to maximum length
#'
#' @param text Character vector
#' @param max_len Maximum length
#' @param suffix Suffix to add if truncated
#' @return Truncated text
#' @keywords internal
truncate_text <- function(text, max_len = 50, suffix = "...") {
  ifelse(
    nchar(text) > max_len,
    paste0(substr(text, 1, max_len - nchar(suffix)), suffix),
    text
  )
}
