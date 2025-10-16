#' Edit an existing card
#'
#' Updates a card's properties. Can be used interactively or with command-line flags.
#'
#' @param char Character to edit
#' @param tone New tone (1-5)
#' @param pinyin New pinyin
#' @param meaning New meaning
#' @param example New example
#' @param tags New tags (comma-separated string)
#' @param notes New notes
#' @param interactive If TRUE, prompt for all fields interactively
#' @return Invisible NULL
#' @export
hanzi_edit <- function(char = NULL, tone = NULL, pinyin = NULL, meaning = NULL,
                       example = NULL, tags = NULL, notes = NULL,
                       interactive = FALSE) {
  # Load cards
  data <- tryCatch(
    read_cards(),
    error = function(e) {
      cli::cli_abort("No cards file found. Run 'hanzi init' first.")
    }
  )

  # Get character if not provided
  if (is.null(char) || nchar(trimws(char)) == 0) {
    char <- read_line("Character to edit: ")
    char <- trimws(char)
    if (nchar(char) == 0) {
      cli::cli_abort("Character is required")
    }
  }

  # Find the card
  card_idx <- which(sapply(data$cards, function(c) c$char == char))

  if (length(card_idx) == 0) {
    cli::cli_abort("Character {.strong {char}} not found in cards")
  }

  if (length(card_idx) > 1) {
    cli::cli_warn("Multiple cards found for {.strong {char}}, editing first one")
    card_idx <- card_idx[1]
  }

  card <- data$cards[[card_idx]]

  # Show current values
  cli::cli_h2("Editing: {char}")
  cli::cli_text("Current values:")
  cli::cli_dl(c(
    "Pinyin" = card$pinyin %||% "(not set)",
    "Tone" = as.character(card$tone %||% "(not set)"),
    "Meaning" = card$meaning %||% "(not set)"
  ))
  cli::cli_text("")

  # Interactive mode
  if (interactive) {
    cli::cli_alert_info("Press Enter to keep current value, or type new value")

    # Pinyin
    pinyin_prompt <- sprintf("Pinyin [%s]: ", card$pinyin %||% "")
    pinyin_input <- read_line(pinyin_prompt)
    if (nchar(trimws(pinyin_input)) > 0) {
      pinyin <- trimws(pinyin_input)
    }

    # Tone
    tone_prompt <- sprintf("Tone (1-5) [%s]: ", card$tone %||% "")
    tone_input <- read_line(tone_prompt)
    if (nchar(trimws(tone_input)) > 0) {
      tone <- as.integer(trimws(tone_input))
    }

    # Meaning
    meaning_prompt <- sprintf("Meaning [%s]: ", card$meaning %||% "")
    meaning_input <- read_line(meaning_prompt)
    if (nchar(trimws(meaning_input)) > 0) {
      meaning <- trimws(meaning_input)
    }

    # Example
    example_prompt <- sprintf("Example [%s]: ", card$example %||% "")
    example_input <- read_line(example_prompt)
    if (nchar(trimws(example_input)) > 0) {
      example <- trimws(example_input)
    }

    # Tags
    current_tags <- if (length(card$tags) > 0) paste(card$tags, collapse = ", ") else ""
    tags_prompt <- sprintf("Tags [%s]: ", current_tags)
    tags_input <- read_line(tags_prompt)
    if (nchar(trimws(tags_input)) > 0) {
      tags <- trimws(tags_input)
    }

    # Notes
    notes_prompt <- sprintf("Notes [%s]: ", card$notes %||% "")
    notes_input <- read_line(notes_prompt)
    if (nchar(trimws(notes_input)) > 0) {
      notes <- trimws(notes_input)
    }
  }

  # Apply updates
  updated <- FALSE

  if (!is.null(pinyin)) {
    card$pinyin <- pinyin
    # Re-parse tone if pinyin changed
    if (is.null(tone)) {
      new_tone <- parse_tone_from_pinyin(pinyin)
      if (!is.na(new_tone)) {
        card$tone <- new_tone
        card$tone_shape <- get_tone_shape(new_tone)
        card$tone_pattern <- get_tone_pattern(new_tone)
      }
    }
    updated <- TRUE
  }

  if (!is.null(tone)) {
    if (!validate_tone(tone)) {
      cli::cli_abort("Invalid tone. Must be 1-5.")
    }
    card$tone <- as.integer(tone)
    card$tone_shape <- get_tone_shape(tone)
    card$tone_pattern <- get_tone_pattern(tone)
    updated <- TRUE
  }

  if (!is.null(meaning)) {
    card$meaning <- meaning
    updated <- TRUE
  }

  if (!is.null(example)) {
    card$example <- if (nchar(example) > 0) example else NA_character_
    updated <- TRUE
  }

  if (!is.null(tags)) {
    if (nchar(tags) > 0) {
      card$tags <- strsplit(tags, ",")[[1]] |>
        stringr::str_trim()
    } else {
      card$tags <- list()
    }
    updated <- TRUE
  }

  if (!is.null(notes)) {
    card$notes <- if (nchar(notes) > 0) notes else NA_character_
    updated <- TRUE
  }

  if (!updated) {
    cli::cli_alert_info("No changes made")
    return(invisible(NULL))
  }

  # Save updated card
  data$cards[[card_idx]] <- card
  write_cards(data)

  # Show success
  cli::cli_alert_success("Updated card: {.strong {char}}")
  cli::cli_text("")
  cli::cli_dl(c(
    "Pinyin" = card$pinyin,
    "Tone" = format_tone(card$tone, include_color = TRUE),
    "Meaning" = card$meaning
  ))

  invisible(NULL)
}
