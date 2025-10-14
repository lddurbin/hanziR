#' Initialize a new cards.yaml file
#'
#' Creates a new cards.yaml file with example cards
#'
#' @param path Path where cards.yaml should be created. If NULL, uses default location.
#' @param force If TRUE, overwrite existing file without prompting
#' @return Invisible path to created file
#' @export
hanzi_init <- function(path = NULL, force = FALSE) {
  # Determine target path
  if (is.null(path)) {
    path <- get_init_path()
  }

  # Check if file already exists
  if (file.exists(path) && !force) {
    cli::cli_alert_info("File {.file {path}} already exists")
    response <- readline("Overwrite? (y/N): ")

    if (!tolower(trimws(response)) %in% c("y", "yes")) {
      cli::cli_alert_info("Cancelled. No changes made.")
      return(invisible(NULL))
    }
  }

  # Ensure directory exists
  dir_path <- dirname(path)
  if (!dir.exists(dir_path) && dir_path != ".") {
    dir.create(dir_path, recursive = TRUE)
    cli::cli_alert_success("Created directory {.file {dir_path}}")
  }

  # Copy template or create minimal structure
  template_path <- system.file("extdata", "cards-template.yaml", package = "hanziR")

  if (file.exists(template_path)) {
    file.copy(template_path, path, overwrite = TRUE)
  } else {
    # Create minimal structure if template not found (during development)
    data <- list(
      version = "1.0",
      created = format_date(),
      cards = list(
        list(
          char = "\u597d",
          pinyin = "h\u01ceo",
          tone = 3L,
          tone_shape = "dip",
          tone_pattern = "\\/",
          initial = "h",
          final = "ao",
          components = list("\u5973", "\u5b50"),
          meaning = "good, well",
          example = "\u4f60\u597d (n\u01d0 h\u01ceo) - hello",
          tags = list("HSK1", "common", "greeting"),
          notes = "One of the most common characters",
          added = format_timestamp()
        )
      )
    )

    write_cards(data, path)
  }

  cli::cli_alert_success("Created {.file {path}}")
  cli::cli_h2("Next steps:")
  cli::cli_ul(c(
    "Add a new card: {.code hanzi add}",
    "List all cards: {.code hanzi list}",
    "Show a card: {.code hanzi show <char>}",
    "Get help: {.code hanzi --help}"
  ))

  invisible(path)
}
