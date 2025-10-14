#' Filter cards by criteria
#'
#' @param args Command line arguments with filter options
#' @return Invisible NULL
#' @export
hanzi_filter <- function(args = character()) {
  cards <- get_cards_tibble()
  
  if (nrow(cards) == 0) {
    cli::cli_alert_info("No cards found")
    return(invisible(NULL))
  }
  
  # Parse filter options
  initial_filter <- parse_option(args, "--initial")
  final_filter <- parse_option(args, "--final")
  tone_filter <- parse_option(args, "--tone")
  component_filter <- parse_option(args, "--component")
  tag_filter <- parse_option(args, "--tag")
  
  # Start with all cards
  results <- cards
  filters_applied <- character()
  
  # Apply initial filter
  if (!is.null(initial_filter)) {
    results <- results |>
      dplyr::filter(!is.na(.data$initial) & .data$initial == !!initial_filter)
    filters_applied <- c(filters_applied, glue::glue("initial={initial_filter}"))
  }
  
  # Apply final filter
  if (!is.null(final_filter)) {
    results <- results |>
      dplyr::filter(!is.na(.data$final) & .data$final == !!final_filter)
    filters_applied <- c(filters_applied, glue::glue("final={final_filter}"))
  }
  
  # Apply tone filter
  if (!is.null(tone_filter)) {
    tone_num <- as.integer(tone_filter)
    if (!validate_tone(tone_num)) {
      cli::cli_abort("Invalid tone: {tone_filter}. Must be 1-5.")
    }
    results <- results |>
      dplyr::filter(.data$tone == !!tone_num)
    filters_applied <- c(filters_applied, glue::glue("tone={tone_num}"))
  }
  
  # Apply component filter
  if (!is.null(component_filter)) {
    results <- results |>
      dplyr::filter(
        purrr::map_lgl(
          .data$components,
          ~ component_filter %in% .x
        )
      )
    filters_applied <- c(filters_applied, glue::glue("component={component_filter}"))
  }
  
  # Apply tag filter
  if (!is.null(tag_filter)) {
    results <- results |>
      dplyr::filter(
        purrr::map_lgl(
          .data$tags,
          ~ tag_filter %in% .x
        )
      )
    filters_applied <- c(filters_applied, glue::glue("tag={tag_filter}"))
  }
  
  # Check if any filters were applied
  if (length(filters_applied) == 0) {
    cli::cli_alert_info("No filters specified. Showing all cards.")
    results <- cards
  }
  
  # Display results
  if (nrow(results) == 0) {
    cli::cli_alert_info("No cards match the filter criteria")
    cli::cli_text("Filters: {.emph {paste(filters_applied, collapse = ', ')}}")
    return(invisible(NULL))
  }
  
  cli::cli_h2("Filtered Cards")
  if (length(filters_applied) > 0) {
    cli::cli_text("Filters: {.emph {paste(filters_applied, collapse = ', ')}}")
  }
  cli::cli_text("")
  
  display <- results |>
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
  
  print(display, n = Inf)
  
  cli::cli_text("")
  cli::cli_alert_info("Found {.strong {nrow(results)}} match{?es}")
  
  invisible(NULL)
}

