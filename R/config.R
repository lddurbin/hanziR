#' Manage mnemonic system configuration
#'
#' Main entry point for config subcommands
#'
#' @param subcommand One of: "init", "show", "validate", "set"
#' @param ... Additional arguments passed to subcommands
#' @return Invisible NULL
#' @export
hanzi_config <- function(subcommand = "show", ...) {
  if (is.null(subcommand)) subcommand <- "show"

  switch(subcommand,
    "init" = config_init(...),
    "show" = config_show(...),
    "validate" = config_validate(...),
    "set" = config_set(...),
    cli::cli_abort("Unknown subcommand: {.val {subcommand}}")
  )

  invisible(NULL)
}

#' Initialize config.yaml with default template
#'
#' @param force If TRUE, overwrite existing config file
#' @return Invisible NULL
#' @export
config_init <- function(force = FALSE) {
  # Determine target path
  config_path <- get_config_init_path()

  # Check if file already exists
  if (file.exists(config_path) && !force) {
    cli::cli_alert_info("File {.file {config_path}} already exists")
    response <- readline("Overwrite? (y/N): ")

    if (!tolower(trimws(response)) %in% c("y", "yes")) {
      cli::cli_alert_info("Cancelled. No changes made.")
      return(invisible(NULL))
    }
  }

  # Ensure directory exists
  dir_path <- dirname(config_path)
  if (!dir.exists(dir_path) && dir_path != ".") {
    dir.create(dir_path, recursive = TRUE)
    cli::cli_alert_success("Created directory {.file {dir_path}}")
  }

  # Copy template
  template_path <- system.file("extdata", "config-template.yaml", package = "hanziR")

  if (file.exists(template_path)) {
    file.copy(template_path, config_path, overwrite = TRUE)
    cli::cli_alert_success("Created {.file {config_path}}")
  } else {
    cli::cli_abort("Config template not found in package installation")
  }

  cli::cli_h2("Next steps:")
  cli::cli_ul(c(
    "View config: {.code hanzi config show}",
    "Validate config: {.code hanzi config validate}",
    "Customize actors: {.code hanzi config set actor <initial> <name>}"
  ))

  invisible(NULL)
}

#' Display current configuration
#'
#' @param section Optional section to display: "actors", "sets", "rooms", "props"
#' @return Invisible NULL
#' @export
config_show <- function(section = NULL) {
  config <- tryCatch(
    read_config(),
    error = function(e) {
      cli::cli_abort(c(
        "Could not read config file",
        "i" = "Run {.code hanzi config init} to create one"
      ))
    }
  )

  if (!is.null(section)) {
    section <- tolower(section)
    if (section == "actors") {
      show_actors(config)
    } else if (section == "sets") {
      show_sets(config)
    } else if (section == "rooms") {
      show_rooms(config)
    } else if (section == "props") {
      show_props(config)
    } else {
      cli::cli_abort("Unknown section: {.val {section}}")
    }
  } else {
    # Show all sections
    cli::cli_h1("Mnemonic System Configuration")
    cli::cli_text("")

    show_actors(config)
    cli::cli_text("")

    show_sets(config)
    cli::cli_text("")

    show_rooms(config)
    cli::cli_text("")

    show_props(config, max_display = 10)
  }

  invisible(NULL)
}

#' Show actors section
#' @keywords internal
show_actors <- function(config) {
  cli::cli_h2("Actors ({length(config$mnemonic_system$actors)} defined)")

  if (length(config$mnemonic_system$actors) == 0) {
    cli::cli_alert_info("No actors defined")
    return(invisible(NULL))
  }

  actors <- config$mnemonic_system$actors
  for (initial in names(actors)) {
    cli::cli_text("{.strong {initial}}: {actors[[initial]]}")
  }

  invisible(NULL)
}

#' Show sets section
#' @keywords internal
show_sets <- function(config) {
  cli::cli_h2("Sets ({length(config$mnemonic_system$sets)} defined)")

  if (length(config$mnemonic_system$sets) == 0) {
    cli::cli_alert_info("No sets defined")
    return(invisible(NULL))
  }

  sets <- config$mnemonic_system$sets
  for (final in names(sets)) {
    cli::cli_text("{.strong {final}}: {sets[[final]]}")
  }

  invisible(NULL)
}

#' Show rooms section
#' @keywords internal
show_rooms <- function(config) {
  cli::cli_h2("Rooms by Tone ({length(config$mnemonic_system$rooms_by_tone)} defined)")

  if (length(config$mnemonic_system$rooms_by_tone) == 0) {
    cli::cli_alert_info("No rooms defined")
    return(invisible(NULL))
  }

  rooms <- config$mnemonic_system$rooms_by_tone
  for (tone in names(rooms)) {
    cli::cli_text("{.strong Tone {tone}}: {rooms[[tone]]}")
  }

  invisible(NULL)
}

#' Show props section
#' @keywords internal
show_props <- function(config, max_display = NULL) {
  n_props <- length(config$mnemonic_system$props)
  cli::cli_h2("Props ({n_props} defined)")

  if (n_props == 0) {
    cli::cli_alert_info("No props defined")
    return(invisible(NULL))
  }

  props <- config$mnemonic_system$props
  prop_names <- names(props)

  if (!is.null(max_display) && n_props > max_display) {
    # Show only first max_display
    for (i in seq_len(max_display)) {
      comp <- prop_names[i]
      cli::cli_text("{.strong {comp}}: {props[[comp]]}")
    }
    cli::cli_alert_info("... and {n_props - max_display} more. Use {.code hanzi config show props} to see all.")
  } else {
    for (comp in prop_names) {
      cli::cli_text("{.strong {comp}}: {props[[comp]]}")
    }
  }

  invisible(NULL)
}

#' Validate configuration
#'
#' @return Invisible NULL
#' @export
config_validate <- function() {
  config <- tryCatch(
    read_config(),
    error = function(e) {
      cli::cli_abort(c(
        "Could not read config file",
        "i" = "Run {.code hanzi config init} to create one"
      ))
    }
  )

  errors <- character()
  warnings <- character()

  # Validate structure
  if (is.null(config$mnemonic_system)) {
    errors <- c(errors, "Missing 'mnemonic_system' section")
  } else {
    # Validate sets (must have exactly 13)
    required_finals <- c("-a", "-o", "-e", "-ai", "-ei", "-ao", "-ou", "-an", "-ang", "-(e)n", "-(e)ng", "-ong", "\u00D8")

    if (is.null(config$mnemonic_system$sets)) {
      errors <- c(errors, "Missing 'sets' section")
    } else {
      n_sets <- length(config$mnemonic_system$sets)
      if (n_sets != 13) {
        errors <- c(errors, sprintf("Sets: expected 13, found %d", n_sets))
      }

      # Check for missing required finals
      defined_finals <- names(config$mnemonic_system$sets)
      missing <- setdiff(required_finals, defined_finals)
      if (length(missing) > 0) {
        errors <- c(errors, sprintf("Missing required finals: %s", paste(missing, collapse = ", ")))
      }
    }

    # Validate rooms (must have exactly 5 for tones 1-5)
    if (is.null(config$mnemonic_system$rooms_by_tone)) {
      errors <- c(errors, "Missing 'rooms_by_tone' section")
    } else {
      n_rooms <- length(config$mnemonic_system$rooms_by_tone)
      if (n_rooms != 5) {
        errors <- c(errors, sprintf("Rooms: expected 5 tones, found %d", n_rooms))
      }

      # Check for missing tones
      required_tones <- as.character(1:5)
      defined_tones <- names(config$mnemonic_system$rooms_by_tone)
      missing <- setdiff(required_tones, defined_tones)
      if (length(missing) > 0) {
        errors <- c(errors, sprintf("Missing rooms for tones: %s", paste(missing, collapse = ", ")))
      }
    }

    # Validate actors (warn if less than 23)
    if (is.null(config$mnemonic_system$actors)) {
      warnings <- c(warnings, "No actors defined")
    } else {
      n_actors <- length(config$mnemonic_system$actors)
      if (n_actors < 23) {
        warnings <- c(warnings, sprintf("Only %d/23 actors defined", n_actors))
      }
    }

    # Check props
    if (is.null(config$mnemonic_system$props)) {
      warnings <- c(warnings, "No props defined")
    }
  }

  # Display results
  if (length(errors) > 0) {
    cli::cli_h2("Validation Errors")
    for (err in errors) {
      cli::cli_alert_danger(err)
    }
  }

  if (length(warnings) > 0) {
    cli::cli_h2("Validation Warnings")
    for (warn in warnings) {
      cli::cli_alert_warning(warn)
    }
  }

  if (length(errors) == 0 && length(warnings) == 0) {
    cli::cli_alert_success("Configuration is valid!")
  } else if (length(errors) == 0) {
    cli::cli_alert_info("Configuration is valid with {length(warnings)} warning{?s}")
  } else {
    cli::cli_alert_danger("Configuration has {length(errors)} error{?s}")
  }

  invisible(NULL)
}

#' Set configuration values
#'
#' @param type One of: "actor", "set", "room", "prop"
#' @param key The key to set
#' @param value The value to set
#' @return Invisible NULL
#' @export
config_set <- function(type = NULL, key = NULL, value = NULL) {
  if (is.null(type)) {
    cli::cli_abort(c(
      "Missing type argument",
      "i" = "Usage: hanzi config set <type> <key> <value>",
      "i" = "Types: actor, set, room, prop"
    ))
  }

  if (is.null(key)) {
    cli::cli_abort("Missing key argument")
  }

  if (is.null(value)) {
    cli::cli_abort("Missing value argument")
  }

  config <- tryCatch(
    read_config(),
    error = function(e) {
      cli::cli_abort(c(
        "Could not read config file",
        "i" = "Run {.code hanzi config init} to create one"
      ))
    }
  )

  type <- tolower(type)

  if (type == "actor") {
    set_actor(config, key, value)
  } else if (type == "set") {
    set_set(config, key, value)
  } else if (type == "room") {
    set_room(config, key, value)
  } else if (type == "prop") {
    set_prop(config, key, value)
  } else {
    cli::cli_abort("Unknown type: {.val {type}}. Must be one of: actor, set, room, prop")
  }

  invisible(NULL)
}

#' Set an actor
#' @keywords internal
set_actor <- function(config, initial, name) {
  # Ensure initial has hyphen
  if (!grepl("-$", initial)) {
    initial <- paste0(initial, "-")
  }

  config$mnemonic_system$actors[[initial]] <- name
  write_config(config)

  cli::cli_alert_success("Set actor {.strong {initial}} to {.val {name}}")
  invisible(NULL)
}

#' Set a set
#' @keywords internal
set_set <- function(config, final, location) {
  # Validate final is one of the 13 required
  required_finals <- c("-a", "-o", "-e", "-ai", "-ei", "-ao", "-ou", "-an", "-ang", "-(e)n", "-(e)ng", "-ong", "\u00D8")

  # Ensure final has hyphen prefix (unless it's the null final)
  if (final != "\u00D8" && !grepl("^-", final)) {
    final <- paste0("-", final)
  }

  if (!final %in% required_finals) {
    cli::cli_abort(c(
      "Invalid final: {.val {final}}",
      "i" = "Must be one of: {.val {required_finals}}"
    ))
  }

  config$mnemonic_system$sets[[final]] <- location
  write_config(config)

  cli::cli_alert_success("Set location for final {.strong {final}} to {.val {location}}")
  invisible(NULL)
}

#' Set a room
#' @keywords internal
set_room <- function(config, tone, room_name) {
  tone_num <- suppressWarnings(as.integer(tone))

  if (is.na(tone_num) || tone_num < 1 || tone_num > 5) {
    cli::cli_abort("Tone must be between 1 and 5, got: {.val {tone}}")
  }

  config$mnemonic_system$rooms_by_tone[[as.character(tone_num)]] <- room_name
  write_config(config)

  cli::cli_alert_success("Set room for tone {.strong {tone_num}} to {.val {room_name}}")
  invisible(NULL)
}

#' Set a prop
#' @keywords internal
set_prop <- function(config, component, meaning) {
  config$mnemonic_system$props[[component]] <- meaning
  write_config(config)

  cli::cli_alert_success("Set prop {.strong {component}} to {.val {meaning}}")
  invisible(NULL)
}

