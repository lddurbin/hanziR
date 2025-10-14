#' Export cards to various formats
#'
#' @param format Export format: "md", "csv", or "tsv"
#' @param out_dir Output directory
#' @return Invisible NULL
#' @export
hanzi_export <- function(format = c("md", "csv", "tsv"), out_dir = "export") {
  format <- match.arg(format)
  
  cards <- get_cards_tibble()
  
  if (nrow(cards) == 0) {
    cli::cli_alert_info("No cards to export")
    return(invisible(NULL))
  }
  
  # Create output directory
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
    cli::cli_alert_success("Created directory {.file {out_dir}}")
  }
  
  switch(
    format,
    "md" = export_markdown(cards, out_dir),
    "csv" = export_csv(cards, out_dir),
    "tsv" = export_anki_tsv(cards, out_dir)
  )
  
  invisible(NULL)
}

#' Export to Markdown
#'
#' @param cards Cards tibble
#' @param out_dir Output directory
#' @keywords internal
export_markdown <- function(cards, out_dir) {
  cli::cli_alert_info("Exporting to Markdown...")
  
  # Create one file per card
  for (i in seq_len(nrow(cards))) {
    card <- cards[i, ]
    # Use pinyin for filename to avoid encoding issues
    safe_name <- gsub("[^a-zA-Z0-9]", "", card$pinyin)
    if (nchar(safe_name) == 0) safe_name <- paste0("card", i)
    filename <- file.path(out_dir, paste0(safe_name, ".md"))
    
    # Build markdown content
    content <- c(
      glue::glue("# {card$char}"),
      "",
      glue::glue("**Pinyin:** {card$pinyin}"),
      glue::glue("**Tone:** {format_tone(card$tone, include_color = FALSE)}"),
      "",
      glue::glue("## Meaning"),
      card$meaning,
      ""
    )
    
    if (!is.na(card$initial) && nchar(card$initial) > 0) {
      content <- c(content, glue::glue("**Initial:** {card$initial}"), "")
    }
    
    if (!is.na(card$final) && nchar(card$final) > 0) {
      content <- c(content, glue::glue("**Final:** {card$final}"), "")
    }
    
    components <- card$components[[1]]
    if (length(components) > 0) {
      content <- c(
        content,
        "## Components",
        paste("-", components),
        ""
      )
    }
    
    if (!is.na(card$example) && nchar(card$example) > 0) {
      content <- c(content, "## Example", card$example, "")
    }
    
    tags <- card$tags[[1]]
    if (length(tags) > 0) {
      content <- c(
        content,
        "## Tags",
        paste("`", tags, "`", sep = "", collapse = " "),
        ""
      )
    }
    
    if (!is.na(card$notes) && nchar(card$notes) > 0) {
      content <- c(content, "## Notes", card$notes, "")
    }
    
    writeLines(content, filename)
  }
  
  # Create index file
  index_file <- file.path(out_dir, "index.md")
  index_content <- c(
    "# Hanzi Card Index",
    "",
    glue::glue("Total cards: {nrow(cards)}"),
    "",
    "## Cards",
    ""
  )
  
  for (i in seq_len(nrow(cards))) {
    card <- cards[i, ]
    safe_name <- gsub("[^a-zA-Z0-9]", "", card$pinyin)
    if (nchar(safe_name) == 0) safe_name <- paste0("card", i)
    index_content <- c(
      index_content,
      glue::glue("- [{card$char}]({safe_name}.md) - {card$pinyin} - {card$meaning}")
    )
  }
  
  writeLines(index_content, index_file)
  
  cli::cli_alert_success("Exported {nrow(cards)} card{?s} + index to {.file {out_dir}}")
}

#' Export to CSV
#'
#' @param cards Cards tibble
#' @param out_dir Output directory
#' @keywords internal
export_csv <- function(cards, out_dir) {
  cli::cli_alert_info("Exporting to CSV...")
  
  filename <- file.path(out_dir, "cards.csv")
  
  # Flatten list columns
  export_data <- cards |>
    dplyr::mutate(
      components = purrr::map_chr(.data$components, ~ paste(.x, collapse = "; ")),
      tags = purrr::map_chr(.data$tags, ~ paste(.x, collapse = "; "))
    )
  
  readr::write_csv(export_data, filename)
  
  cli::cli_alert_success("Exported {nrow(cards)} card{?s} to {.file {filename}}")
}

#' Export to Anki TSV
#'
#' @param cards Cards tibble
#' @param out_dir Output directory
#' @keywords internal
export_anki_tsv <- function(cards, out_dir) {
  cli::cli_alert_info("Exporting to Anki TSV...")
  
  filename <- file.path(out_dir, "anki_import.tsv")
  
  # Create Anki format: Front \t Back
  anki_data <- cards |>
    dplyr::mutate(
      Front = glue::glue("{char}\n{pinyin}"),
      Back = glue::glue("{meaning}\n\nExample: {ifelse(is.na(example), '(none)', example)}")
    ) |>
    dplyr::select(.data$Front, .data$Back)
  
  readr::write_tsv(anki_data, filename)
  
  cli::cli_alert_success("Exported {nrow(cards)} card{?s} to {.file {filename}}")
  cli::cli_text("")
  cli::cli_alert_info("To import into Anki:")
  cli::cli_ol(c(
    "Open Anki and select your deck",
    "File > Import",
    "Select {.file {filename}}",
    "Set 'Fields separated by: Tab'",
    "Map Field 1 to Front, Field 2 to Back",
    "Click Import"
  ))
}

