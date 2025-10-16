#' Main CLI entry point
#'
#' Routes commands to appropriate functions
#'
#' @param args Command line arguments (character vector)
#' @return Invisible NULL
#' @export
hanzi_cli <- function(args = commandArgs(trailingOnly = TRUE)) {
  if (length(args) == 0) {
    show_help()
    return(invisible(NULL))
  }

  command <- args[1]
  remaining_args <- if (length(args) > 1) args[-1] else character()

  tryCatch({
    switch(
      command,
      "init" = {
        minimal <- "--minimal" %in% remaining_args || "--empty" %in% remaining_args
        force <- "--force" %in% remaining_args
        hanzi_init(minimal = minimal, force = force)
      },
      "add" = hanzi_add(),
      "edit" = {
        # Parse character and flags
        char <- if (length(remaining_args) > 0) remaining_args[1] else NULL

        # Check for flags
        tone <- NULL
        pinyin <- NULL
        meaning <- NULL
        interactive <- "--interactive" %in% remaining_args || "-i" %in% remaining_args

        # Parse --tone flag
        tone_idx <- which(remaining_args == "--tone")
        if (length(tone_idx) > 0 && length(remaining_args) > tone_idx) {
          tone <- as.integer(remaining_args[tone_idx + 1])
        }

        # Parse --pinyin flag
        pinyin_idx <- which(remaining_args == "--pinyin")
        if (length(pinyin_idx) > 0 && length(remaining_args) > pinyin_idx) {
          pinyin <- remaining_args[pinyin_idx + 1]
        }

        # Parse --meaning flag
        meaning_idx <- which(remaining_args == "--meaning")
        if (length(meaning_idx) > 0 && length(remaining_args) > meaning_idx) {
          meaning <- remaining_args[meaning_idx + 1]
        }

        hanzi_edit(
          char = char,
          tone = tone,
          pinyin = pinyin,
          meaning = meaning,
          interactive = interactive
        )
      },
      "list" = hanzi_list(),
      "show" = {
        if (length(remaining_args) == 0) {
          cli::cli_abort("Usage: hanzi show <character>")
        }
        hanzi_show(remaining_args[1])
      },
      "mnemonic" = {
        if (length(remaining_args) == 0) {
          cli::cli_abort("Usage: hanzi mnemonic <character>")
        }
        hanzi_mnemonic(remaining_args[1])
      },
      "search" = {
        if (length(remaining_args) == 0) {
          cli::cli_abort("Usage: hanzi search <query...>")
        }
        hanzi_search(remaining_args)
      },
      "filter" = hanzi_filter(remaining_args),
      "export" = {
        if (length(remaining_args) == 0) {
          cli::cli_abort("Usage: hanzi export <format> [--out <dir>]")
        }
        format <- remaining_args[1]
        out_dir <- parse_option(remaining_args, "--out", default = "export")
        hanzi_export(format, out_dir)
      },
      "config" = {
        subcommand <- if (length(remaining_args) > 0) remaining_args[1] else "show"
        sub_args <- if (length(remaining_args) > 1) remaining_args[-1] else character()
        do.call(hanzi_config, c(list(subcommand = subcommand), as.list(sub_args)))
      },
      "actors" = {
        show_usage <- "--usage" %in% remaining_args
        hanzi_actors(show_usage = show_usage)
      },
      "sets" = {
        show_usage <- "--usage" %in% remaining_args
        hanzi_sets(show_usage = show_usage)
      },
      "props" = {
        show_usage <- "--usage" %in% remaining_args
        limit <- parse_option(remaining_args, "--limit")
        if (!is.null(limit)) limit <- as.integer(limit)
        hanzi_props(show_usage = show_usage, limit = limit)
      },
      "stats" = hanzi_stats(),
      "validate" = hanzi_validate(),
      "--help" = show_help(),
      "-h" = show_help(),
      "help" = show_help(),
      {
        cli::cli_alert_danger("Unknown command: {.code {command}}")
        show_help()
        quit(status = 1)
      }
    )
  }, error = function(e) {
    cli::cli_alert_danger("Error: {conditionMessage(e)}")
    quit(status = 1)
  })

  invisible(NULL)
}

#' Show help message
#'
#' @keywords internal
show_help <- function() {
  cli::cli_h1("hanziR - Terminal-Based Hanzi Learning Card Manager")
  cli::cli_text("")
  cli::cli_h2("Usage:")
  cli::cli_text("  hanzi <command> [options]")
  cli::cli_text("")
  cli::cli_h2("Commands:")
  cli::cli_dl(c(
    "init [--minimal] [--force]" = "Initialize a new cards.yaml file",
    "add" = "Add a new card interactively",
    "edit <char> [--tone N] [--pinyin X]" = "Edit an existing card",
    "list" = "List all cards",
    "show <char>" = "Show detailed info for a character",
    "mnemonic <char>" = "Show mnemonic info for a character",
    "search <query...>" = "Search cards (full-text)",
    "filter [options]" = "Filter cards by criteria",
    "export <format> [--out <dir>]" = "Export cards (md|csv|tsv)",
    "config <subcommand>" = "Manage mnemonic system config",
    "actors [--usage]" = "List all actors in your system",
    "sets [--usage]" = "List all sets in your system",
    "props [--usage] [--limit N]" = "List all props in your system",
    "stats" = "Show collection statistics",
    "validate" = "Validate cards.yaml file"
  ))
  cli::cli_text("")
  cli::cli_h2("Config Subcommands:")
  cli::cli_dl(c(
    "config init" = "Initialize config.yaml with template",
    "config show [section]" = "Show configuration (actors|sets|rooms|props)",
    "config validate" = "Validate configuration",
    "config set <type> <key> <value>" = "Set config value (actor|set|room|prop)"
  ))
  cli::cli_text("")
  cli::cli_h2("Filter Options:")
  cli::cli_dl(c(
    "--initial <value>" = "Filter by initial consonant",
    "--final <value>" = "Filter by final vowel",
    "--tone <1-5>" = "Filter by tone number",
    "--component <char>" = "Filter by component",
    "--tag <tag>" = "Filter by tag",
    "--actor <name>" = "Filter by mnemonic actor (partial match)",
    "--set <name>" = "Filter by mnemonic set (partial match)",
    "--room <name>" = "Filter by mnemonic room (partial match)"
  ))
  cli::cli_text("")
  cli::cli_h2("Examples:")
  cli::cli_code("hanzi init                      # Initialize with example cards")
  cli::cli_code("hanzi init --minimal            # Initialize with empty cards list")
  cli::cli_code("hanzi init --force --minimal    # Force overwrite with minimal setup")
  cli::cli_code("hanzi add")
  cli::cli_code("hanzi edit \u4e2a --tone 2         # Update tone for character")
  cli::cli_code("hanzi edit \u5341 -i                # Edit interactively")
  cli::cli_code("hanzi list")
  cli::cli_code("hanzi show <char>")
  cli::cli_code("hanzi search greeting")
  cli::cli_code("hanzi filter --tag HSK1 --tone 3")
  cli::cli_code("hanzi export md --out docs/")
  cli::cli_text("")
}

#' Parse option from command line arguments
#'
#' @param args Character vector of arguments
#' @param option Option name (e.g., "--out")
#' @param default Default value if option not found
#' @return Option value or default
#' @keywords internal
parse_option <- function(args, option, default = NULL) {
  idx <- which(args == option)

  if (length(idx) == 0) {
    return(default)
  }

  if (idx[1] == length(args)) {
    cli::cli_abort("Option {.code {option}} requires a value")
  }

  args[idx[1] + 1]
}

#' Parse all options with a given prefix
#'
#' @param args Character vector of arguments
#' @param option Option name (e.g., "--tag")
#' @return Character vector of all values for this option
#' @keywords internal
parse_all_options <- function(args, option) {
  idx <- which(args == option)

  if (length(idx) == 0) {
    return(character())
  }

  values <- character()
  for (i in idx) {
    if (i < length(args)) {
      values <- c(values, args[i + 1])
    }
  }

  values
}
