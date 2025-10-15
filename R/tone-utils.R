#' Get tone shape name
#'
#' Convert tone number to accessible shape name using Mandarin Blueprint terminology
#'
#' @param tone Tone number (1-5)
#' @return Shape name (singing, unsure, zombie, assertive, contrarian)
#' @export
#' @examples
#' get_tone_shape(1)  # "singing"
#' get_tone_shape(3)  # "zombie"
get_tone_shape <- function(tone) {
  shapes <- c("singing", "unsure", "zombie", "assertive", "contrarian")

  if (is.na(tone) || !tone %in% 1:5) {
    cli::cli_warn("Invalid tone: {tone}. Using contrarian.")
    return("contrarian")
  }

  shapes[tone]
}

#' Get tone pattern
#'
#' Convert tone number to visual pattern
#'
#' @param tone Tone number (1-5)
#' @return Pattern string
#' @export
#' @examples
#' get_tone_pattern(1)  # "---"
#' get_tone_pattern(4)  # "\\"
get_tone_pattern <- function(tone) {
  patterns <- c("---", "/", "\\/", "\\", ".")

  if (is.na(tone) || !tone %in% 1:5) {
    return(".")
  }

  patterns[tone]
}

#' Get tone color name
#'
#' Convert tone number to color name (for accessibility)
#'
#' @param tone Tone number (1-5)
#' @return Color name
#' @keywords internal
get_tone_color_name <- function(tone) {
  colors <- c("red", "orange", "green", "blue", "gray")

  if (is.na(tone) || !tone %in% 1:5) {
    return("gray")
  }

  colors[tone]
}

#' Format tone for display
#'
#' Create accessible tone representation with number, shape, and pattern
#'
#' @param tone Tone number (1-5)
#' @param include_color If TRUE, use cli colors in output
#' @return Formatted tone string
#' @export
#' @examples
#' format_tone(3)  # "Tone 3 (dip \\/)"
format_tone <- function(tone, include_color = TRUE) {
  if (is.na(tone) || !tone %in% 1:5) {
    return("Tone ? (unknown)")
  }

  shape <- get_tone_shape(tone)
  pattern <- get_tone_pattern(tone)

  if (include_color && requireNamespace("cli", quietly = TRUE)) {
    # Use cli colors but also include text labels
    color_name <- get_tone_color_name(tone)
    color_fn <- switch(
      color_name,
      "red" = cli::col_red,
      "orange" = cli::make_ansi_style("orange"),
      "green" = cli::col_green,
      "blue" = cli::col_blue,
      "gray" = cli::col_grey,
      identity
    )

    color_fn(glue::glue("Tone {tone} ({shape} {pattern})"))
  } else {
    glue::glue("Tone {tone} ({shape} {pattern})")
  }
}

#' Parse tone from pinyin
#'
#' Extract tone number from pinyin with tone marks
#'
#' @param pinyin Pinyin string with or without tone marks
#' @return Tone number (1-5) or NA
#' @keywords internal
parse_tone_from_pinyin <- function(pinyin) {
  # Tone marks on different vowels (using Unicode escapes)
  tone_map <- list(
    "1" = c("\u0101", "\u0113", "\u012b", "\u014d", "\u016b", "\u01d6",
            "\u0100", "\u0112", "\u012a", "\u014c", "\u016a", "\u01d5"),
    "2" = c("\u00e1", "\u00e9", "\u00ed", "\u00f3", "\u00fa", "\u01d8",
            "\u00c1", "\u00c9", "\u00cd", "\u00d3", "\u00da", "\u01d7"),
    "3" = c("\u01ce", "\u011b", "\u01d0", "\u01d2", "\u01d4", "\u01da",
            "\u01cd", "\u011a", "\u01cf", "\u01d1", "\u01d3", "\u01d9"),
    "4" = c("\u00e0", "\u00e8", "\u00ec", "\u00f2", "\u00f9", "\u01dc",
            "\u00c0", "\u00c8", "\u00cc", "\u00d2", "\u00d9", "\u01db")
  )

  for (tone in names(tone_map)) {
    if (any(stringr::str_detect(pinyin, stringr::fixed(tone_map[[tone]])))) {
      return(as.integer(tone))
    }
  }

  # Check for numeric tone at end (e.g., "hao3")
  if (stringr::str_detect(pinyin, "[1-5]$")) {
    tone <- stringr::str_extract(pinyin, "[1-5]$")
    return(as.integer(tone))
  }

  # Default to tone 5 (neutral) if no tone found
  5L
}

#' Validate tone value
#'
#' @param tone Tone value to validate
#' @return TRUE if valid, FALSE otherwise
#' @keywords internal
validate_tone <- function(tone) {
  !is.na(tone) && is.numeric(tone) && tone %in% 1:5
}
