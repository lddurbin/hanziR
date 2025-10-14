#' Display collection statistics
#'
#' @return Invisible NULL
#' @export
hanzi_stats <- function() {
  cards <- get_cards_tibble()

  if (nrow(cards) == 0) {
    cli::cli_alert_info("No cards found")
    return(invisible(NULL))
  }

  cli::cli_h1("Collection Statistics")
  cli::cli_text("")

  # Total cards
  cli::cli_alert_info("Total cards: {.strong {nrow(cards)}}")
  cli::cli_text("")

  # Cards by tone
  cli::cli_h2("By Tone")
  tone_counts <- cards |>
    dplyr::filter(!is.na(.data$tone)) |>
    dplyr::count(.data$tone, .data$tone_shape) |>
    dplyr::arrange(.data$tone)

  if (nrow(tone_counts) > 0) {
    for (i in seq_len(nrow(tone_counts))) {
      tone_num <- tone_counts$tone[i]
      tone_shape <- tone_counts$tone_shape[i]
      tone_count <- tone_counts$n[i]
      tone_pattern <- get_tone_pattern(tone_num)
      cli::cli_text("  Tone {tone_num} ({tone_shape} {tone_pattern}): {tone_count}")
    }
  } else {
    cli::cli_text("  No tone data")
  }
  cli::cli_text("")

  # Top initials
  cli::cli_h2("Top Initials")
  initial_counts <- cards |>
    dplyr::filter(!is.na(.data$initial) & nchar(.data$initial) > 0) |>
    dplyr::count(.data$initial, sort = TRUE) |>
    dplyr::slice_head(n = 10)

  if (nrow(initial_counts) > 0) {
    for (i in seq_len(nrow(initial_counts))) {
      cli::cli_text("  {initial_counts$initial[i]}: {initial_counts$n[i]}")
    }
  } else {
    cli::cli_text("  No initial data")
  }
  cli::cli_text("")

  # Top finals
  cli::cli_h2("Top Finals")
  final_counts <- cards |>
    dplyr::filter(!is.na(.data$final) & nchar(.data$final) > 0) |>
    dplyr::count(.data$final, sort = TRUE) |>
    dplyr::slice_head(n = 10)

  if (nrow(final_counts) > 0) {
    for (i in seq_len(nrow(final_counts))) {
      cli::cli_text("  {final_counts$final[i]}: {final_counts$n[i]}")
    }
  } else {
    cli::cli_text("  No final data")
  }
  cli::cli_text("")

  # Tags
  cli::cli_h2("By Tag")
  all_tags <- cards$tags |>
    unlist() |>
    table() |>
    sort(decreasing = TRUE)

  if (length(all_tags) > 0) {
    for (i in seq_along(all_tags)) {
      cli::cli_text("  {names(all_tags)[i]}: {all_tags[i]}")
    }
  } else {
    cli::cli_text("  No tags")
  }
  cli::cli_text("")

  # Recently added
  cli::cli_h2("Recently Added (Last 5)")
  recent <- cards |>
    dplyr::filter(!is.na(.data$added)) |>
    dplyr::arrange(dplyr::desc(.data$added)) |>
    dplyr::slice_head(n = 5) |>
    dplyr::mutate(
      date = format(as.POSIXct(.data$added), "%Y-%m-%d"),
      display = glue::glue("{char} ({pinyin}) - {date}")
    )

  if (nrow(recent) > 0) {
    for (i in seq_len(nrow(recent))) {
      cli::cli_text("  {recent$display[i]}")
    }
  } else {
    cli::cli_text("  No timestamp data")
  }
  cli::cli_text("")

  invisible(NULL)
}
