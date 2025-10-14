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

  if (!is.na(card$initial) && nchar(card$initial) > 0) {
    details[["Initial"]] <- card$initial
  }

  if (!is.na(card$final) && nchar(card$final) > 0) {
    details[["Final"]] <- card$final
  }

  components <- card$components[[1]]
  if (length(components) > 0) {
    details[["Components"]] <- paste(components, collapse = ", ")
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
  cli::cli_text("")

  invisible(NULL)
}
