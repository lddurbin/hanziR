#' Validate cards.yaml file
#'
#' Checks for consistency and completeness
#'
#' @return Invisible logical (TRUE if valid)
#' @export
hanzi_validate <- function() {
  cli::cli_h2("Validating cards.yaml")
  cli::cli_text("")
  
  # Try to read file
  data <- tryCatch(
    read_cards(),
    error = function(e) {
      cli::cli_alert_danger("Failed to read cards.yaml: {conditionMessage(e)}")
      quit(status = 1)
    }
  )
  
  errors <- character()
  warnings <- character()
  
  # Check version
  if (is.null(data$version)) {
    warnings <- c(warnings, "Missing version field")
  }
  
  # Check cards
  if (length(data$cards) == 0) {
    warnings <- c(warnings, "No cards found")
  } else {
    cli::cli_alert_info("Checking {length(data$cards)} cards...")
    
    chars_seen <- character()
    
    for (i in seq_along(data$cards)) {
      card <- data$cards[[i]]
      card_id <- glue::glue("Card #{i}")
      
      # Required fields
      if (is.null(card$char) || nchar(card$char) == 0) {
        errors <- c(errors, glue::glue("{card_id}: Missing character"))
      } else {
        card_id <- glue::glue("Card #{i} ({card$char})")
        
        # Check for duplicates
        if (card$char %in% chars_seen) {
          warnings <- c(warnings, glue::glue("{card_id}: Duplicate character"))
        }
        chars_seen <- c(chars_seen, card$char)
      }
      
      if (is.null(card$pinyin) || nchar(card$pinyin) == 0) {
        errors <- c(errors, glue::glue("{card_id}: Missing pinyin"))
      }
      
      if (is.null(card$meaning) || nchar(card$meaning) == 0) {
        errors <- c(errors, glue::glue("{card_id}: Missing meaning"))
      }
      
      # Tone validation
      if (!is.null(card$tone)) {
        if (!validate_tone(card$tone)) {
          errors <- c(errors, glue::glue("{card_id}: Invalid tone {card$tone} (must be 1-5)"))
        } else {
          # Check tone consistency
          expected_shape <- get_tone_shape(card$tone)
          expected_pattern <- get_tone_pattern(card$tone)
          
          if (!is.null(card$tone_shape) && card$tone_shape != expected_shape) {
            warnings <- c(warnings, glue::glue(
              "{card_id}: Tone shape mismatch (expected '{expected_shape}', got '{card$tone_shape}')"
            ))
          }
          
          if (!is.null(card$tone_pattern) && card$tone_pattern != expected_pattern) {
            warnings <- c(warnings, glue::glue(
              "{card_id}: Tone pattern mismatch (expected '{expected_pattern}', got '{card$tone_pattern}')"
            ))
          }
        }
      } else {
        warnings <- c(warnings, glue::glue("{card_id}: Missing tone"))
      }
      
      # Optional field warnings
      if (is.null(card$example) || nchar(card$example) == 0) {
        # Don't warn about missing examples
      }
      
      if (is.null(card$tags) || length(card$tags) == 0) {
        # Don't warn about missing tags
      }
    }
  }
  
  # Report results
  cli::cli_text("")
  
  if (length(errors) == 0 && length(warnings) == 0) {
    cli::cli_alert_success("Validation passed! No errors or warnings.")
    return(invisible(TRUE))
  }
  
  if (length(errors) > 0) {
    cli::cli_h3("Errors ({length(errors)})")
    for (error in errors) {
      cli::cli_alert_danger(error)
    }
    cli::cli_text("")
  }
  
  if (length(warnings) > 0) {
    cli::cli_h3("Warnings ({length(warnings)})")
    for (warning in warnings) {
      cli::cli_alert_warning(warning)
    }
    cli::cli_text("")
  }
  
  if (length(errors) > 0) {
    cli::cli_alert_danger("Validation failed with {length(errors)} error{?s}")
    quit(status = 1)
  } else {
    cli::cli_alert_success("Validation passed with {length(warnings)} warning{?s}")
  }
  
  invisible(length(errors) == 0)
}

