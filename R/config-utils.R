#' Find the config.yaml file
#'
#' Looks for config.yaml in the same directory as cards.yaml
#'
#' @param must_exist If TRUE, abort if file doesn't exist
#' @return Path to config.yaml or NULL
#' @keywords internal
find_config_file <- function(must_exist = TRUE) {
  # Find the cards directory
  cards_path <- find_cards_file(must_exist = FALSE)

  if (!is.null(cards_path)) {
    # Look for config.yaml in the same directory as cards.yaml
    cards_dir <- dirname(cards_path)
    config_path <- file.path(cards_dir, "config.yaml")

    if (file.exists(config_path)) {
      return(normalizePath(config_path))
    }
  }

  # Check current directory
  if (file.exists("config.yaml")) {
    return(normalizePath("config.yaml"))
  }

  # Check inst/data/
  inst_path <- "inst/data/config.yaml"
  if (file.exists(inst_path)) {
    return(normalizePath(inst_path))
  }

  # Check installed package location
  pkg_path <- system.file("data", "config.yaml", package = "hanziR")
  if (pkg_path != "") {
    return(pkg_path)
  }

  if (must_exist) {
    cli::cli_abort(c(
      "Could not find {.file config.yaml}",
      "i" = "Run {.code hanzi init} to create one"
    ))
  }

  NULL
}

#' Get the default config.yaml path for initialization
#'
#' Returns the path where config.yaml should be created
#'
#' @return Path for new config.yaml
#' @keywords internal
get_config_init_path <- function() {
  # Same directory as cards.yaml
  cards_path <- get_init_path()
  config_path <- file.path(dirname(cards_path), "config.yaml")
  config_path
}

#' Read config from YAML file
#'
#' @param path Path to config.yaml file. If NULL, uses find_config_file()
#' @return List with config data
#' @export
read_config <- function(path = NULL) {
  if (is.null(path)) {
    path <- find_config_file(must_exist = TRUE)
  }

  if (!file.exists(path)) {
    cli::cli_abort("File not found: {.file {path}}")
  }

  tryCatch({
    # Read YAML content as UTF-8 text
    yaml_text <- readLines(path, encoding = "UTF-8", warn = FALSE)
    data <- yaml::yaml.load(paste(yaml_text, collapse = "\n"))

    # Validate structure
    if (is.null(data$mnemonic_system)) {
      cli::cli_abort("Invalid config.yaml: missing 'mnemonic_system' field")
    }

    data
  }, error = function(e) {
    cli::cli_abort(c(
      "Failed to read {.file {path}}",
      "x" = conditionMessage(e)
    ))
  })
}

#' Write config to YAML file
#'
#' @param data List with config data
#' @param path Path to config.yaml file
#' @return Invisible NULL
#' @export
write_config <- function(data, path = NULL) {
  if (is.null(path)) {
    path <- find_config_file(must_exist = FALSE)
    if (is.null(path)) {
      path <- get_config_init_path()
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

#' Get actor for a given initial
#'
#' @param initial Pinyin initial (e.g., "sh", "b")
#' @param config Config data. If NULL, reads from file
#' @return Actor name or NULL if not found
#' @export
get_actor <- function(initial, config = NULL) {
  if (is.null(config)) {
    config <- read_config()
  }

  if (is.null(initial) || is.na(initial)) {
    return(NULL)
  }

  # Ensure initial has hyphen
  initial_key <- paste0(initial, "-")

  config$mnemonic_system$actors[[initial_key]]
}

#' Get set (location) for a given final
#'
#' @param final Pinyin final (e.g., "ao", or null final for standalone initials)
#' @param config Config data. If NULL, reads from file
#' @return Set name or NULL if not found
#' @export
get_set <- function(final, config = NULL) {
  if (is.null(config)) {
    config <- read_config()
  }

  if (is.null(final) || is.na(final)) {
    return(NULL)
  }

  # Ensure final has hyphen prefix
  final_key <- paste0("-", final)
  # Handle special case of null final
  if (final == "\u00D8" || final == "") {
    final_key <- "\u00D8"
  }

  config$mnemonic_system$sets[[final_key]]
}

#' Get room for a given tone
#'
#' @param tone Tone number (1-5)
#' @param config Config data. If NULL, reads from file
#' @return Room name or NULL if not found
#' @export
get_room <- function(tone, config = NULL) {
  if (is.null(config)) {
    config <- read_config()
  }

  if (is.null(tone) || is.na(tone)) {
    return(NULL)
  }

  config$mnemonic_system$rooms_by_tone[[as.character(tone)]]
}

#' Get prop meaning for a given component
#'
#' @param component Component character
#' @param config Config data. If NULL, reads from file
#' @return Prop meaning or NULL if not found
#' @export
get_prop <- function(component, config = NULL) {
  if (is.null(config)) {
    config <- read_config()
  }

  if (is.null(component) || is.na(component)) {
    return(NULL)
  }

  config$mnemonic_system$props[[component]]
}

#' Normalize component to list format
#'
#' Converts components to a standardized format that supports both
#' v1.0 (string) and v2.0 (object with char and meaning) formats
#'
#' @param components Vector or list of components
#' @return List of components in normalized format
#' @keywords internal
normalize_components <- function(components) {
  if (is.null(components)) {
    return(list())
  }

  # If it's a simple character vector, convert to list
  if (is.character(components)) {
    components <- as.list(components)
  }

  # Normalize each component
  lapply(components, function(comp) {
    if (is.character(comp)) {
      # v1.0 format: simple string
      comp
    } else if (is.list(comp) && !is.null(comp$char)) {
      # v2.0 format: object with char and optionally meaning
      comp
    } else {
      # Unknown format, return as-is
      comp
    }
  })
}

#' Extract component characters from normalized components
#'
#' @param components Normalized components list
#' @return Character vector of component characters
#' @keywords internal
extract_component_chars <- function(components) {
  if (is.null(components) || length(components) == 0) {
    return(character())
  }

  sapply(components, function(comp) {
    if (is.character(comp)) {
      comp
    } else if (is.list(comp) && !is.null(comp$char)) {
      comp$char
    } else {
      NA_character_
    }
  })
}
