#' Add a new card interactively
#'
#' Prompts user for card details and adds to cards.yaml
#'
#' @return Invisible NULL
#' @export
hanzi_add <- function() {
  cli::cli_h2("Add New Card")

  # Character (required)
  char <- read_line("Character (required): ")
  char <- trimws(char)

  if (nchar(char) == 0) {
    cli::cli_abort("Character is required")
  }

  # Pinyin (required)
  pinyin <- read_line("Pinyin with tone marks (required): ")
  pinyin <- trimws(pinyin)

  if (nchar(pinyin) == 0) {
    cli::cli_abort("Pinyin is required")
  }

  # Parse tone from pinyin
  tone <- parse_tone_from_pinyin(pinyin)

  # Allow manual tone override
  tone_input <- read_line(sprintf("Tone (1-5) [detected: %d]: ", tone))
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
  initial <- read_line("Initial consonant: ")
  initial <- trimws(initial)

  # Final
  final <- read_line("Final vowel: ")
  final <- trimws(final)

  # Components
  components_input <- read_line("Components (comma-separated): ")
  components <- if (nchar(trimws(components_input)) > 0) {
    strsplit(components_input, ",")[[1]] |>
      stringr::str_trim()
  } else {
    character()
  }

  # Meaning (required)
  meaning <- read_line("Meaning (required): ")
  meaning <- trimws(meaning)

  if (nchar(meaning) == 0) {
    cli::cli_abort("Meaning is required")
  }

  # Example
  example <- read_line("Example: ")
  example <- trimws(example)
  if (nchar(example) == 0) example <- NA_character_

  # Tags
  tags_input <- read_line("Tags (comma-separated): ")
  tags <- if (nchar(trimws(tags_input)) > 0) {
    strsplit(tags_input, ",")[[1]] |>
      stringr::str_trim()
  } else {
    character()
  }

  # Notes
  notes <- read_line("Notes: ")
  notes <- trimws(notes)
  if (nchar(notes) == 0) notes <- NA_character_

  # Mnemonic system (optional)
  cli::cli_text("")
  cli::cli_h3("Mnemonic Information (optional - press Enter to skip)")

  # Load config if available
  config <- tryCatch(read_config(), error = function(e) NULL)

  mnemonic <- NULL
  add_mnemonic <- read_line("Add mnemonic information? (y/N): ")

  if (tolower(trimws(add_mnemonic)) %in% c("y", "yes")) {
    mnemonic <- list()

    # Keyword (optional)
    keyword_prompt <- sprintf("Keyword (default: %s): ", meaning)
    keyword <- read_line(keyword_prompt)
    keyword <- trimws(keyword)
    if (nchar(keyword) == 0) keyword <- meaning

    # Actor (auto-populate from config)
    if (!is.null(config) && nchar(initial) > 0) {
      suggested_actor <- get_actor(initial, config)
      if (!is.null(suggested_actor)) {
        actor_prompt <- sprintf("Actor [%s]: ", suggested_actor)
        actor <- read_line(actor_prompt)
        actor <- trimws(actor)
        if (nchar(actor) == 0) actor <- suggested_actor
        mnemonic$actor <- actor
      } else {
        actor <- read_line("Actor: ")
        actor <- trimws(actor)
        if (nchar(actor) > 0) mnemonic$actor <- actor
      }
    } else {
      actor <- read_line("Actor: ")
      actor <- trimws(actor)
      if (nchar(actor) > 0) mnemonic$actor <- actor
    }

    # Set (auto-populate from config)
    if (!is.null(config) && nchar(final) > 0) {
      suggested_set <- get_set(final, config)
      if (!is.null(suggested_set)) {
        set_prompt <- sprintf("Set [%s]: ", suggested_set)
        set <- read_line(set_prompt)
        set <- trimws(set)
        if (nchar(set) == 0) set <- suggested_set
        mnemonic$set <- set
      } else {
        set <- read_line("Set: ")
        set <- trimws(set)
        if (nchar(set) > 0) mnemonic$set <- set
      }
    } else {
      set <- read_line("Set: ")
      set <- trimws(set)
      if (nchar(set) > 0) mnemonic$set <- set
    }

    # Room (auto-populate from config)
    if (!is.null(config) && !is.na(tone)) {
      suggested_room <- get_room(tone, config)
      if (!is.null(suggested_room)) {
        room_prompt <- sprintf("Room [%s]: ", suggested_room)
        room <- read_line(room_prompt)
        room <- trimws(room)
        if (nchar(room) == 0) room <- suggested_room
        mnemonic$room <- room
      } else {
        room <- read_line("Room: ")
        room <- trimws(room)
        if (nchar(room) > 0) mnemonic$room <- room
      }
    } else {
      room <- read_line("Room: ")
      room <- trimws(room)
      if (nchar(room) > 0) mnemonic$room <- room
    }

    # Scene (multiline)
    cli::cli_text("Scene (press Enter twice when done):")
    scene_lines <- character()
    repeat {
      line <- read_line()
      if (nchar(trimws(line)) == 0 && length(scene_lines) > 0) break
      if (nchar(trimws(line)) > 0) scene_lines <- c(scene_lines, line)
    }
    if (length(scene_lines) > 0) {
      mnemonic$scene <- paste(scene_lines, collapse = "\n")
    }

    # Only include mnemonic if it has content
    if (length(mnemonic) == 0) mnemonic <- NULL
  }

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
    keyword = if (exists("keyword") && nchar(keyword) > 0) keyword else NA_character_,
    example = example,
    tags = if (length(tags) > 0) tags else list(),
    notes = notes,
    added = format_timestamp()
  )

  # Add mnemonic if present
  if (!is.null(mnemonic) && length(mnemonic) > 0) {
    card$mnemonic <- mnemonic
  }

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
