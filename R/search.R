#' Search cards by query
#'
#' Full-text search across all fields
#'
#' @param queries Character vector of search terms
#' @return Invisible NULL
#' @export
hanzi_search <- function(queries) {
  cards <- get_cards_tibble()
  
  if (nrow(cards) == 0) {
    cli::cli_alert_info("No cards found")
    return(invisible(NULL))
  }
  
  # Combine all searchable fields into one string per card
  search_text <- cards |>
    dplyr::mutate(
      components_str = purrr::map_chr(.data$components, ~ paste(.x, collapse = " ")),
      tags_str = purrr::map_chr(.data$tags, ~ paste(.x, collapse = " ")),
      search_field = paste(
        .data$char,
        .data$pinyin,
        .data$meaning,
        .data$example,
        .data$notes,
        .data$components_str,
        .data$tags_str,
        sep = " "
      )
    )
  
  # Search for any query term (OR logic)
  query_pattern <- paste(queries, collapse = "|")
  matches <- stringr::str_detect(
    search_text$search_field,
    stringr::regex(query_pattern, ignore_case = TRUE)
  )
  
  results <- cards[matches, ]
  
  if (nrow(results) == 0) {
    cli::cli_alert_info("No matches found for: {.emph {paste(queries, collapse = ', ')}}")
    return(invisible(NULL))
  }
  
  # Display results
  cli::cli_h2("Search Results")
  cli::cli_text("Query: {.emph {paste(queries, collapse = ', ')}}")
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

