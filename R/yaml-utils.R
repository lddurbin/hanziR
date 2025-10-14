#' Read cards from YAML file
#'
#' @param path Path to cards.yaml file. If NULL, uses find_cards_file()
#' @return List with cards data
#' @export
read_cards <- function(path = NULL) {
  if (is.null(path)) {
    path <- find_cards_file(must_exist = TRUE)
  }
  
  if (!file.exists(path)) {
    cli::cli_abort("File not found: {.file {path}}")
  }
  
  tryCatch({
    # Read YAML content as UTF-8 text
    yaml_text <- readLines(path, encoding = "UTF-8", warn = FALSE)
    data <- yaml::yaml.load(paste(yaml_text, collapse = "\n"))
    
    # Validate structure
    if (is.null(data$cards)) {
      cli::cli_abort("Invalid cards.yaml: missing 'cards' field")
    }
    
    data
  }, error = function(e) {
    cli::cli_abort(c(
      "Failed to read {.file {path}}",
      "x" = conditionMessage(e)
    ))
  })
}

#' Write cards to YAML file
#'
#' @param data List with cards data
#' @param path Path to cards.yaml file
#' @return Invisible NULL
#' @export
write_cards <- function(data, path = NULL) {
  if (is.null(path)) {
    path <- find_cards_file(must_exist = FALSE)
    if (is.null(path)) {
      path <- get_init_path()
    }
  }
  
  # Ensure directory exists
  dir_path <- dirname(path)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  
  tryCatch({
    # Convert to YAML string and write with UTF-8 encoding
    yaml_text <- yaml::as.yaml(data)
    writeLines(yaml_text, path, useBytes = FALSE)
    invisible(NULL)
  }, error = function(e) {
    cli::cli_abort(c(
      "Failed to write {.file {path}}",
      "x" = conditionMessage(e)
    ))
  })
}

#' Get all cards as a tibble
#'
#' @param path Path to cards.yaml file
#' @return Tibble with card data
#' @export
get_cards_tibble <- function(path = NULL) {
  data <- read_cards(path)
  
  if (length(data$cards) == 0) {
    return(tibble::tibble(
      char = character(),
      pinyin = character(),
      tone = integer(),
      tone_shape = character(),
      tone_pattern = character(),
      initial = character(),
      final = character(),
      components = list(),
      meaning = character(),
      example = character(),
      tags = list(),
      notes = character(),
      added = character()
    ))
  }
  
  # Convert list of cards to tibble
  cards_df <- data$cards |>
    purrr::map_dfr(function(card) {
      tibble::tibble(
        char = card$char %||% NA_character_,
        pinyin = card$pinyin %||% NA_character_,
        tone = card$tone %||% NA_integer_,
        tone_shape = card$tone_shape %||% NA_character_,
        tone_pattern = card$tone_pattern %||% NA_character_,
        initial = card$initial %||% NA_character_,
        final = card$final %||% NA_character_,
        components = list(card$components %||% character()),
        meaning = card$meaning %||% NA_character_,
        example = card$example %||% NA_character_,
        tags = list(card$tags %||% character()),
        notes = card$notes %||% NA_character_,
        added = card$added %||% NA_character_
      )
    })
  
  cards_df
}

#' Create an empty cards data structure
#'
#' @return List with empty cards structure
#' @keywords internal
create_empty_cards <- function() {
  list(
    version = "1.0",
    created = format_date(),
    cards = list()
  )
}

#' Add a card to cards data
#'
#' @param data Cards data list
#' @param card Card list to add
#' @return Updated cards data
#' @keywords internal
add_card_to_data <- function(data, card) {
  # Ensure card has required fields
  required <- c("char", "pinyin", "meaning")
  missing <- setdiff(required, names(card))
  
  if (length(missing) > 0) {
    cli::cli_abort("Card missing required fields: {.field {missing}}")
  }
  
  # Add timestamp if not present
  if (is.null(card$added)) {
    card$added <- format_timestamp()
  }
  
  # Auto-generate tone fields if missing but tone is present
  if (!is.null(card$tone) && is.null(card$tone_shape)) {
    card$tone_shape <- get_tone_shape(card$tone)
  }
  if (!is.null(card$tone) && is.null(card$tone_pattern)) {
    card$tone_pattern <- get_tone_pattern(card$tone)
  }
  
  # Append card
  data$cards <- c(data$cards, list(card))
  
  data
}

# Null coalescing operator
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

