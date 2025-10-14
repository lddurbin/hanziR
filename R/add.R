#' Add a new card interactively
#'
#' Prompts user for card details and adds to cards.yaml
#'
#' @return Invisible NULL
#' @export
hanzi_add <- function() {
  cli::cli_h2("Add New Card")

  # Character (required)
  char <- readline("Character (required): ")
  char <- trimws(char)

  if (nchar(char) == 0) {
    cli::cli_abort("Character is required")
  }

  # Pinyin (required)
  pinyin <- readline("Pinyin with tone marks (required): ")
  pinyin <- trimws(pinyin)

  if (nchar(pinyin) == 0) {
    cli::cli_abort("Pinyin is required")
  }

  # Parse tone from pinyin
  tone <- parse_tone_from_pinyin(pinyin)

  # Allow manual tone override
  tone_input <- readline(sprintf("Tone (1-5) [detected: %d]: ", tone))
  tone_input <- trimws(tone_input)
  if (nchar(tone_input) > 0) {
    tone <- as.integer(tone_input)
    if (!validate_tone(tone)) {
      cli::cli_abort("Invalid tone. Must be 1-5.")
    }
  }

  # Auto-generate tone shape and pattern
  tone_shape <- get_tone_shape(tone)
  tone_pattern <- get_tone_pattern(tone)

  # Initial
  initial <- readline("Initial consonant: ")
  initial <- trimws(initial)

  # Final
  final <- readline("Final vowel: ")
  final <- trimws(final)

  # Components
  components_input <- readline("Components (comma-separated): ")
  components <- if (nchar(trimws(components_input)) > 0) {
    strsplit(components_input, ",")[[1]] |>
      stringr::str_trim()
  } else {
    character()
  }

  # Meaning (required)
  meaning <- readline("Meaning (required): ")
  meaning <- trimws(meaning)

  if (nchar(meaning) == 0) {
    cli::cli_abort("Meaning is required")
  }

  # Example
  example <- readline("Example: ")
  example <- trimws(example)
  if (nchar(example) == 0) example <- NA_character_

  # Tags
  tags_input <- readline("Tags (comma-separated): ")
  tags <- if (nchar(trimws(tags_input)) > 0) {
    strsplit(tags_input, ",")[[1]] |>
      stringr::str_trim()
  } else {
    character()
  }

  # Notes
  notes <- readline("Notes: ")
  notes <- trimws(notes)
  if (nchar(notes) == 0) notes <- NA_character_

  # Create card
  card <- list(
    char = char,
    pinyin = pinyin,
    tone = tone,
    tone_shape = tone_shape,
    tone_pattern = tone_pattern,
    initial = if (nchar(initial) > 0) initial else NA_character_,
    final = if (nchar(final) > 0) final else NA_character_,
    components = if (length(components) > 0) components else list(),
    meaning = meaning,
    example = example,
    tags = if (length(tags) > 0) tags else list(),
    notes = notes,
    added = format_timestamp()
  )

  # Read existing cards
  data <- tryCatch(
    read_cards(),
    error = function(e) {
      cli::cli_alert_info("Creating new cards file")
      create_empty_cards()
    }
  )

  # Add card
  data <- add_card_to_data(data, card)

  # Write back
  write_cards(data)

  # Show success
  cli::cli_alert_success("Added card: {.strong {char}} ({pinyin})")
  cli::cli_text("")
  cli::cli_dl(c(
    "Character" = char,
    "Pinyin" = pinyin,
    "Tone" = format_tone(tone, include_color = TRUE),
    "Meaning" = meaning,
    "Tags" = if (length(tags) > 0) paste(tags, collapse = ", ") else "(none)"
  ))

  invisible(NULL)
}
