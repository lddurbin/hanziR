#' Get tone shape name
#'
#' Convert tone number to accessible shape name
#'
#' @param tone Tone number (1-5)
#' @return Shape name (flat, rise, dip, fall, neutral)
#' @export
#' @examples
#' get_tone_shape(1)  # "flat"
#' get_tone_shape(3)  # "dip"
get_tone_shape <- function(tone) {
  shapes <- c("flat", "rise", "dip", "fall", "neutral")
  
  if (is.na(tone) || !tone %in% 1:5) {
    cli::cli_warn("Invalid tone: {tone}. Using neutral.")
    return("neutral")
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
  # Tone marks on different vowels
  tone_map <- list(
    "1" = c("ā", "ē", "ī", "ō", "ū", "ǖ", "Ā", "Ē", "Ī", "Ō", "Ū", "Ǖ"),
    "2" = c("á", "é", "í", "ó", "ú", "ǘ", "Á", "É", "Í", "Ó", "Ú", "Ǘ"),
    "3" = c("ǎ", "ě", "ǐ", "ǒ", "ǔ", "ǚ", "Ǎ", "Ě", "Ǐ", "Ǒ", "Ǔ", "Ǚ"),
    "4" = c("à", "è", "ì", "ò", "ù", "ǜ", "À", "È", "Ì", "Ò", "Ù", "Ǜ")
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

