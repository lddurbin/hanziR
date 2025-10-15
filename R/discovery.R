#' List all actors in mnemonic system
#'
#' Display all actors with their associated Pinyin initials
#'
#' @param show_usage If TRUE, also show which cards use each actor
#' @return Invisible NULL
#' @export
hanzi_actors <- function(show_usage = FALSE) {
  # Load config
  config <- tryCatch(
    read_config(),
    error = function(e) {
      cli::cli_abort(c(
        "Could not read config file",
        "i" = "Run {.code hanzi config init} to create one"
      ))
    }
  )

  actors <- config$mnemonic_system$actors

  if (length(actors) == 0) {
    cli::cli_alert_info("No actors defined")
    cli::cli_text("Add actors with: {.code hanzi config set actor <initial> <name>}")
    return(invisible(NULL))
  }

  cli::cli_h1("Actors ({length(actors)} defined)")
  cli::cli_text("")

  # Get usage counts if requested
  if (show_usage) {
    cards <- get_cards_tibble()
    usage_counts <- list()

    for (initial in names(actors)) {
      # Count cards with this initial that have mnemonic actor
      count <- sum(sapply(seq_len(nrow(cards)), function(i) {
        card <- cards[i, ]
        mnem <- card$mnemonic[[1]]
        !is.na(card$initial) &&
          paste0(card$initial, "-") == initial &&
          !is.null(mnem) &&
          !is.null(mnem$actor)
      }))
      usage_counts[[initial]] <- count
    }
  }

  # Display actors
  for (initial in sort(names(actors))) {
    if (show_usage) {
      count <- usage_counts[[initial]]
      cli::cli_text("{.strong {initial}}: {actors[[initial]]} {.dim ({count} card{?s})}")
    } else {
      cli::cli_text("{.strong {initial}}: {actors[[initial]]}")
    }
  }

  cli::cli_text("")
  invisible(NULL)
}

#' List all sets in mnemonic system
#'
#' Display all sets (locations) with their associated Pinyin finals
#'
#' @param show_usage If TRUE, also show which cards use each set
#' @return Invisible NULL
#' @export
hanzi_sets <- function(show_usage = FALSE) {
  # Load config
  config <- tryCatch(
    read_config(),
    error = function(e) {
      cli::cli_abort(c(
        "Could not read config file",
        "i" = "Run {.code hanzi config init} to create one"
      ))
    }
  )

  sets <- config$mnemonic_system$sets

  if (length(sets) == 0) {
    cli::cli_alert_info("No sets defined")
    cli::cli_text("Add sets with: {.code hanzi config set set <final> <location>}")
    return(invisible(NULL))
  }

  cli::cli_h1("Sets ({length(sets)} defined)")
  cli::cli_text("")

  # Get usage counts if requested
  if (show_usage) {
    cards <- get_cards_tibble()
    usage_counts <- list()

    for (final in names(sets)) {
      # Count cards with this final that have mnemonic set
      final_clean <- sub("^-", "", final)
      if (final == "\u00D8") final_clean <- "\u00D8"

      count <- sum(sapply(seq_len(nrow(cards)), function(i) {
        card <- cards[i, ]
        mnem <- card$mnemonic[[1]]
        !is.na(card$final) &&
          (card$final == final_clean || (final == "\u00D8" && card$final == "")) &&
          !is.null(mnem) &&
          !is.null(mnem$set)
      }))
      usage_counts[[final]] <- count
    }
  }

  # Display sets
  for (final in sort(names(sets))) {
    if (show_usage) {
      count <- usage_counts[[final]]
      cli::cli_text("{.strong {final}}: {sets[[final]]} {.dim ({count} card{?s})}")
    } else {
      cli::cli_text("{.strong {final}}: {sets[[final]]}")
    }
  }

  cli::cli_text("")
  invisible(NULL)
}

#' List all props in mnemonic system
#'
#' Display all props (component meanings) in alphabetical order
#'
#' @param show_usage If TRUE, also show which cards use each prop
#' @param limit Maximum number of props to display (NULL for all)
#' @return Invisible NULL
#' @export
hanzi_props <- function(show_usage = FALSE, limit = NULL) {
  # Load config
  config <- tryCatch(
    read_config(),
    error = function(e) {
      cli::cli_abort(c(
        "Could not read config file",
        "i" = "Run {.code hanzi config init} to create one"
      ))
    }
  )

  props <- config$mnemonic_system$props

  if (length(props) == 0) {
    cli::cli_alert_info("No props defined")
    cli::cli_text("Add props with: {.code hanzi config set prop <component> <meaning>}")
    return(invisible(NULL))
  }

  n_props <- length(props)
  cli::cli_h1("Props ({n_props} defined)")
  cli::cli_text("")

  # Get usage counts if requested
  if (show_usage) {
    cards <- get_cards_tibble()
    usage_counts <- list()

    for (comp in names(props)) {
      # Count cards that have this component
      count <- sum(sapply(seq_len(nrow(cards)), function(i) {
        card <- cards[i, ]
        components <- card$components[[1]]
        if (length(components) == 0) return(FALSE)

        # Check if component is in the list
        comp_chars <- sapply(components, function(c) {
          if (is.character(c)) c
          else if (is.list(c) && !is.null(c$char)) c$char
          else NA_character_
        })
        comp %in% comp_chars
      }))
      usage_counts[[comp]] <- count
    }
  }

  # Display props
  prop_names <- sort(names(props))

  if (!is.null(limit) && n_props > limit) {
    display_props <- prop_names[1:limit]
  } else {
    display_props <- prop_names
  }

  for (comp in display_props) {
    if (show_usage) {
      count <- usage_counts[[comp]]
      cli::cli_text("{.strong {comp}}: {props[[comp]]} {.dim ({count} card{?s})}")
    } else {
      cli::cli_text("{.strong {comp}}: {props[[comp]]}")
    }
  }

  if (!is.null(limit) && n_props > limit) {
    cli::cli_text("")
    remaining <- n_props - limit
    cli::cli_alert_info(
      "... and {remaining} more. Use {.code hanzi props} (no limit) to see all."
    )
  }

  cli::cli_text("")
  invisible(NULL)
}
