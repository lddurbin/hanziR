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

    # Keyword (if different from meaning)
    if (!is.na(card$keyword) && nchar(card$keyword) > 0 && card$keyword != card$meaning) {
      content <- c(content, glue::glue("**Keyword:** {card$keyword}"), "")
    }

    components <- card$components[[1]]
    if (length(components) > 0) {
      # Handle both string and object format
      comp_lines <- sapply(components, function(comp) {
        if (is.character(comp)) {
          paste("-", comp)
        } else if (is.list(comp) && !is.null(comp$char)) {
          if (!is.null(comp$meaning)) {
            paste("-", comp$char, glue::glue("({comp$meaning})"))
          } else {
            paste("-", comp$char)
          }
        } else {
          paste("-", as.character(comp))
        }
      })
      content <- c(
        content,
        "## Components",
        comp_lines,
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

    # Mnemonic section
    mnemonic <- card$mnemonic[[1]]
    if (!is.null(mnemonic) && length(mnemonic) > 0) {
      content <- c(content, "## Mnemonic", "")

      if (!is.null(mnemonic$actor)) {
        content <- c(content, glue::glue("**Actor:** {mnemonic$actor} ({card$initial})"))
      }

      if (!is.null(mnemonic$set)) {
        content <- c(content, glue::glue("**Set:** {mnemonic$set} ({card$final})"))
      }

      if (!is.null(mnemonic$room)) {
        content <- c(content, glue::glue("**Room:** {mnemonic$room} (Tone {card$tone})"))
      }

      if (!is.null(mnemonic$scene) && nchar(mnemonic$scene) > 0) {
        content <- c(content, "", "**Scene:**", "", mnemonic$scene)
      }

      content <- c(content, "")
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

  # Flatten list columns and extract mnemonic fields
  export_data <- cards |>
    dplyr::mutate(
      components = purrr::map_chr(.data$components, function(comp_list) {
        # Handle both string and object formats
        comp_strings <- sapply(comp_list, function(comp) {
          if (is.character(comp)) {
            comp
          } else if (is.list(comp) && !is.null(comp$char)) {
            if (!is.null(comp$meaning)) {
              paste0(comp$char, " (", comp$meaning, ")")
            } else {
              comp$char
            }
          } else {
            as.character(comp)
          }
        })
        paste(comp_strings, collapse = "; ")
      }),
      tags = purrr::map_chr(.data$tags, ~ paste(.x, collapse = "; ")),
      # Extract mnemonic fields
      mnemonic_actor = purrr::map_chr(.data$mnemonic, function(m) {
        if (!is.null(m) && !is.null(m$actor)) m$actor else NA_character_
      }),
      mnemonic_set = purrr::map_chr(.data$mnemonic, function(m) {
        if (!is.null(m) && !is.null(m$set)) m$set else NA_character_
      }),
      mnemonic_room = purrr::map_chr(.data$mnemonic, function(m) {
        if (!is.null(m) && !is.null(m$room)) m$room else NA_character_
      }),
      mnemonic_scene = purrr::map_chr(.data$mnemonic, function(m) {
        if (!is.null(m) && !is.null(m$scene)) m$scene else NA_character_
      })
    ) |>
    # Remove the nested mnemonic column
    dplyr::select(-.data$mnemonic)

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

  # Create Anki format: Front \t Back (with optional mnemonic)
  anki_data <- cards |>
    dplyr::mutate(
      Front = glue::glue("{char}\n{pinyin}"),
      Back = purrr::pmap_chr(
        list(.data$meaning, .data$example, .data$keyword, .data$mnemonic),
        function(meaning, example, keyword, mnemonic) {
          # Start with meaning
          back_text <- meaning

          # Add example
          if (!is.na(example) && nchar(example) > 0) {
            back_text <- paste0(back_text, "\n\nExample: ", example)
          } else {
            back_text <- paste0(back_text, "\n\nExample: (none)")
          }

          # Add mnemonic if present
          if (!is.null(mnemonic) && length(mnemonic) > 0) {
            mnemonic_parts <- character()

            if (!is.null(mnemonic$actor)) {
              mnemonic_parts <- c(mnemonic_parts, paste("Actor:", mnemonic$actor))
            }
            if (!is.null(mnemonic$set)) {
              mnemonic_parts <- c(mnemonic_parts, paste("Set:", mnemonic$set))
            }
            if (!is.null(mnemonic$room)) {
              mnemonic_parts <- c(mnemonic_parts, paste("Room:", mnemonic$room))
            }

            if (length(mnemonic_parts) > 0) {
              back_text <- paste0(back_text, "\n\n--- MNEMONIC ---\n", paste(mnemonic_parts, collapse = "\n"))
            }

            if (!is.null(mnemonic$scene) && nchar(mnemonic$scene) > 0) {
              back_text <- paste0(back_text, "\n\nScene:\n", mnemonic$scene)
            }
          }

          back_text
        }
      )
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
