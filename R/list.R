#' List all cards
#'
#' Display all cards in a table format
#'
#' @return Invisible NULL
#' @export
hanzi_list <- function() {
  cards <- get_cards_tibble()

  if (nrow(cards) == 0) {
    cli::cli_alert_info("No cards found")
    cli::cli_text("Run {.code hanzi add} to add your first card")
    return(invisible(NULL))
  }

  # Prepare display table
  display <- cards |>
    dplyr::mutate(
      tone_display = purrr::map2_chr(
        .data$tone,
        .data$tone_shape,
        ~ if (!is.na(.x)) glue::glue("T{.x} ({.y})") else "?"
      ),
      meaning_short = truncate_text(.data$meaning, max_len = 40),
      tags_display = purrr::map_chr(
        .data$tags,
        ~ if (length(.x) > 0) paste(.x, collapse = ", ") else ""
      )
    ) |>
    dplyr::select(
      char = .data$char,
      pinyin = .data$pinyin,
      tone = .data$tone_display,
      meaning = .data$meaning_short,
      tags = .data$tags_display
    )

  # Print header
  cli::cli_h2("Hanzi Cards")
  cli::cli_text("")

  # Print table
  print(display, n = Inf)

  # Print count
  cli::cli_text("")
  cli::cli_alert_info("Total: {.strong {nrow(cards)}} card{?s}")

  invisible(NULL)
}
