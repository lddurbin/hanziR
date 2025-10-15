#' Show detailed information about a card
#'
#' @param char Character to show
#' @return Invisible NULL
#' @export
hanzi_show <- function(char) {
  cards <- get_cards_tibble()

  # Find card
  card <- cards |>
    dplyr::filter(.data$char == !!char)

  if (nrow(card) == 0) {
    cli::cli_abort("Card not found: {.strong {char}}")
  }

  card <- card[1, ]  # Take first match

  # Display card
  cli::cli_text("")
  cli::cli_rule(
    left = glue::glue("{card$char} ({card$pinyin})"),
    right = format_tone(card$tone, include_color = TRUE)
  )
  cli::cli_text("")

  # Build details list
  details <- list()
  details[["Meaning"]] <- card$meaning

  # Show keyword if different from meaning
  if (!is.na(card$keyword) && nchar(card$keyword) > 0 && card$keyword != card$meaning) {
    details[["Keyword"]] <- card$keyword
  }

  if (!is.na(card$initial) && nchar(card$initial) > 0) {
    details[["Initial"]] <- card$initial
  }

  if (!is.na(card$final) && nchar(card$final) > 0) {
    details[["Final"]] <- card$final
  }

  # Handle components (can be simple strings or objects with meanings)
  components <- card$components[[1]]
  if (length(components) > 0) {
    comp_strings <- sapply(components, function(comp) {
      if (is.character(comp)) {
        comp
      } else if (is.list(comp) && !is.null(comp$char)) {
        if (!is.null(comp$meaning)) {
          sprintf("%s (%s)", comp$char, comp$meaning)
        } else {
          comp$char
        }
      } else {
        as.character(comp)
      }
    })
    details[["Components"]] <- paste(comp_strings, collapse = ", ")
  }

  if (!is.na(card$example) && nchar(card$example) > 0) {
    details[["Example"]] <- card$example
  }

  tags <- card$tags[[1]]
  if (length(tags) > 0) {
    details[["Tags"]] <- paste(tags, collapse = ", ")
  }

  if (!is.na(card$notes) && nchar(card$notes) > 0) {
    details[["Notes"]] <- card$notes
  }

  if (!is.na(card$added)) {
    details[["Added"]] <- format(as.POSIXct(card$added), "%Y-%m-%d %H:%M")
  }

  cli::cli_dl(details)

  # Display mnemonic information if present
  mnemonic <- card$mnemonic[[1]]
  if (!is.null(mnemonic) && length(mnemonic) > 0) {
    cli::cli_text("")
    cli::cli_h2("\U0001F3AC Mnemonic")

    mnemonic_details <- list()

    if (!is.null(mnemonic$actor)) {
      mnemonic_details[["Actor"]] <- sprintf("%s (%s)", mnemonic$actor, card$initial)
    }

    if (!is.null(mnemonic$set)) {
      mnemonic_details[["Set"]] <- sprintf("%s (%s)", mnemonic$set, card$final)
    }

    if (!is.null(mnemonic$room)) {
      mnemonic_details[["Room"]] <- sprintf("%s (Tone %s)", mnemonic$room, card$tone)
    }

    if (length(mnemonic_details) > 0) {
      cli::cli_dl(mnemonic_details)
    }

    if (!is.null(mnemonic$scene) && nchar(mnemonic$scene) > 0) {
      cli::cli_text("")
      cli::cli_text("{.strong Scene:}")
      cli::cli_text(mnemonic$scene)
    }
  }

  cli::cli_text("")

  invisible(NULL)
}
