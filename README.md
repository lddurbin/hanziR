# hanziR

> A minimal R package for managing Chinese character (Hanzi) learning cards from the terminal

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

`hanziR` provides a pure terminal workflow for managing Hanzi (Chinese character) flashcards. It uses a YAML file as the source of truth and includes accessible tone cues (shapes + patterns + color names) for learners who are color blind.

## Features

- 📝 **YAML-based**: Simple, human-readable source of truth (`cards.yaml`)
- 🎯 **Terminal-first**: Complete workflow without leaving the command line
- ♿ **Accessible**: Tone representation using shapes, patterns, AND colors
- 📊 **Multiple exports**: Markdown, CSV, and Anki TSV formats
- 🔍 **Powerful filtering**: Search by initial, final, tone, component, or tag
- 📈 **Statistics**: Track your collection and progress

## Installation

```r
# Install development version from source
devtools::install()

# Or install from GitHub (when available)
# devtools::install_github("username/hanziR")
```

### Making the CLI Available

After installation, make the `hanzi` command available in your terminal:

```bash
# Add to your ~/.zshrc or ~/.bashrc
export PATH="$PATH:$(Rscript -e 'cat(system.file("exec", package="hanziR"))')"

# Or create a symbolic link
sudo ln -s $(Rscript -e 'cat(system.file("exec", package="hanziR"))') /usr/local/bin/hanzi
```

Reload your shell or run `source ~/.zshrc` to apply changes.

## Quick Start

```bash
# Initialize a new collection
hanzi init

# Add a card interactively
hanzi add

# List all cards
hanzi list

# Show details for a specific character
hanzi show 好

# Search across all fields
hanzi search greeting

# Filter by criteria
hanzi filter --tag HSK1
hanzi filter --tone 3 --initial h

# Export to various formats
hanzi export md --out docs/
hanzi export csv
hanzi export tsv  # Anki-compatible

# View statistics
hanzi stats

# Validate your cards.yaml
hanzi validate
```

## Accessible Tone System

Mandarin Chinese has 5 tones. To ensure accessibility for color-blind users, each tone is represented with:

| Tone | Name    | Shape   | Pattern | Description        |
|------|---------|---------|---------|---------------------|
| 1    | First   | flat    | `---`   | High level         |
| 2    | Second  | rise    | `/`     | Rising             |
| 3    | Third   | dip     | `\/`    | Dip then rise      |
| 4    | Fourth  | fall    | `\`     | Falling            |
| 5    | Neutral | neutral | `.`     | Light/neutral tone |

Example output: "好 (hǎo) - Tone 3 (dip \\/)"

## Commands

### `hanzi init`
Initialize a new `cards.yaml` file with example cards.

### `hanzi add`
Interactively add a new card with prompts for all fields.

### `hanzi list`
Display all cards in a compact table format.

### `hanzi show <char>`
Show detailed information about a specific character.

### `hanzi search <query...>`
Full-text search across all fields (character, pinyin, meaning, examples, notes, tags).

### `hanzi filter [options]`
Filter cards by specific criteria:
- `--initial <value>`: Filter by initial consonant
- `--final <value>`: Filter by final vowel sound
- `--tone <1-5>`: Filter by tone number
- `--component <char>`: Filter by component character
- `--tag <tag>`: Filter by tag (e.g., HSK1, common)

### `hanzi export <format> [--out <dir>]`
Export cards to different formats:
- `md`: Markdown files (one per card + index)
- `csv`: Single CSV file
- `tsv`: Anki-compatible two-column format (Front/Back)

### `hanzi stats`
Display statistics about your card collection.

### `hanzi validate`
Validate the `cards.yaml` file for consistency and completeness.

## Data Structure

Cards are stored in `inst/data/cards.yaml`:

```yaml
version: "1.0"
created: "2025-10-14"
cards:
  - char: "好"
    pinyin: "hǎo"
    tone: 3
    tone_shape: "dip"
    tone_pattern: "\\/"
    initial: "h"
    final: "ao"
    components: ["女", "子"]
    meaning: "good, well"
    example: "你好 (nǐ hǎo) - hello"
    tags: ["HSK1", "common", "greeting"]
    notes: "One of the most common characters"
    added: "2025-10-14T10:30:00Z"
```

## Development Status

🚧 **Currently in development** - See [PROJECT_PLAN.md](PROJECT_PLAN.md) for roadmap.

- [ ] Phase 1: Setup & Infrastructure
- [ ] Phase 2: Core Infrastructure
- [ ] Phase 3: CRUD Operations
- [ ] Phase 4: Query Operations
- [ ] Phase 5: Export & Stats
- [ ] Phase 6: CLI Integration
- [ ] Phase 7: Documentation & Polish
- [ ] Phase 8: Testing & Release

## Contributing

This is a personal learning tool project. Suggestions and feedback welcome!

## License

MIT License - See LICENSE file for details

## Author

Built with ❤️ for accessible language learning

