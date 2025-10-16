#' Show mnemonic information for a card
#'
#' Quick-view of just the mnemonic information (actor, set, room, scene)
#'
#' @param char Character to show mnemonic for
#' @return Invisible NULL
#' @export
hanzi_mnemonic <- function(char) {
  cards <- get_cards_tibble()

  # Find card
  card <- cards |>
    dplyr::filter(.data$char == !!char)

  if (nrow(card) == 0) {
    cli::cli_abort("Card not found: {.strong {char}}")
  }

  card <- card[1, ]  # Take first match

  # Check if mnemonic exists
  mnemonic <- card$mnemonic[[1]]
  if (is.null(mnemonic) || length(mnemonic) == 0) {
    cli::cli_alert_info("No mnemonic information for {.strong {char}}")
    cli::cli_text("Use {.code hanzi add} to add mnemonic information")
    return(invisible(NULL))
  }

  # Display header
  cli::cli_text("")
  cli::cli_rule(glue::glue("\U0001F3AC {card$char} ({card$pinyin})"))
  cli::cli_text("")

  # Display mnemonic components
  mnemonic_details <- list()

  # Show keyword/meaning first
  keyword_or_meaning <- if (!is.na(card$keyword) && nchar(card$keyword) > 0) {
    card$keyword
  } else {
    card$meaning
  }
  if (!is.na(keyword_or_meaning) && nchar(keyword_or_meaning) > 0) {
    mnemonic_details[["\U0001F3AF Keyword"]] <- keyword_or_meaning
  }

  if (!is.null(mnemonic$actor)) {
    mnemonic_details[["\U0001F3AD Actor"]] <- sprintf(
      "%s (initial: %s)",
      mnemonic$actor,
      card$initial
    )
  }

  if (!is.null(mnemonic$set)) {
    mnemonic_details[["\U0001F3AA Set"]] <- sprintf(
      "%s (final: %s)",
      mnemonic$set,
      card$final
    )
  }

  if (!is.null(mnemonic$room)) {
    mnemonic_details[["\U0001F6AA Room"]] <- sprintf(
      "%s (tone %s)",
      mnemonic$room,
      card$tone
    )
  }

  # Show components/props if in object format
  components <- card$components[[1]]
  if (length(components) > 0) {
    props <- sapply(components, function(comp) {
      if (is.list(comp) && !is.null(comp$char) && !is.null(comp$meaning)) {
        sprintf("%s (%s)", comp$char, comp$meaning)
      } else if (is.character(comp)) {
        comp
      } else {
        NA_character_
      }
    })
    props <- props[!is.na(props)]
    if (length(props) > 0) {
      mnemonic_details[["\U0001F3AD Props"]] <- paste(props, collapse = ", ")
    }
  }

  if (length(mnemonic_details) > 0) {
    cli::cli_dl(mnemonic_details)
  }

  # Display scene
  if (!is.null(mnemonic$scene) && nchar(mnemonic$scene) > 0) {
    cli::cli_text("")
    cli::cli_h2("\U0001F4D6 Scene")
    cli::cli_text(mnemonic$scene)
  }

  cli::cli_text("")

  invisible(NULL)
}
