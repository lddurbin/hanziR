# hanziR

> A minimal R package for managing Chinese character (Hanzi) learning cards from the terminal

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

`hanziR` provides a pure terminal workflow for managing Hanzi (Chinese character) flashcards. It uses a YAML file as the source of truth and includes accessible tone cues (shapes + patterns + color names) for learners who are color blind.

## Features

- 📝 **YAML-based**: Simple, human-readable source of truth (`cards.yaml`)
- 🎯 **Terminal-first**: Complete workflow without leaving the command line
- ♿ **Accessible**: Tone representation using shapes, patterns, AND colors
- 🎬 **Mnemonic System**: Hanzi Movie Method integration for memorable character learning
- 📊 **Multiple exports**: Markdown, CSV, and Anki TSV formats
- 🔍 **Powerful filtering**: Search by initial, final, tone, component, or tag
- 📈 **Statistics**: Track your collection and progress
- 🔄 **Backward Compatible**: v1.0 cards work seamlessly with v2.0 mnemonic features

## Installation

```r
# Install from GitHub
devtools::install_github("lddurbin/hanziR")

# Or install development version from source
devtools::install()
```

### Making the CLI Available

After installation, make the `hanzi` command available in your terminal:

```bash
# Add to your ~/.zshrc or ~/.bashrc
export PATH="$PATH:$(Rscript -e 'cat(system.file("bin", package="hanziR"))')"

# Or create a symbolic link
sudo ln -s "$(Rscript -e 'cat(system.file("bin", package="hanziR"))')/hanzi" /usr/local/bin/hanzi
```

Reload your shell or run `source ~/.zshrc` to apply changes.

## Quick Start

```bash
# Initialize a new collection (creates cards.yaml + config.yaml)
hanzi init                  # With example cards
hanzi init --minimal        # Or start from scratch with empty cards

# Add a card interactively
hanzi add

# List all cards
hanzi list

# Show details for a specific character (includes mnemonic if present)
hanzi show 好

# Quick-view of just the mnemonic information
hanzi mnemonic 好

# Search across all fields
hanzi search greeting

# Filter by criteria (including mnemonic elements!)
hanzi filter --tag HSK1
hanzi filter --tone 3 --initial h
hanzi filter --actor "Hugh"
hanzi filter --set "Cabin" --room "Bedroom"

# Export to various formats (includes mnemonic data!)
hanzi export md --out docs/   # Markdown with mnemonic sections
hanzi export csv              # CSV with mnemonic_actor, mnemonic_set, etc.
hanzi export tsv              # Anki-compatible with mnemonics on back

# View statistics
hanzi stats

# Validate your cards.yaml (includes mnemonic validation)
hanzi validate
```

## Hanzi Movie Method (Mnemonic System)

`hanziR` v2.0+ supports the **Hanzi Movie Method** from Mandarin Blueprint, a powerful mnemonic technique for memorizing Chinese characters using mental "movies."

### Configuration Commands

Manage your personal mnemonic system with `hanzi config`:

```bash
# Initialize config with default actors/sets/rooms
hanzi config init

# View entire configuration
hanzi config show

# View specific sections
hanzi config show actors
hanzi config show sets
hanzi config show rooms
hanzi config show props

# Validate configuration
hanzi config validate

# Customize your system
hanzi config set actor sh "Sean Connery"
hanzi config set set -ao "Mountain Cabin"
hanzi config set room 3 "Bedroom"
hanzi config set prop 女 "Woman"
```

### Discovery Commands

Explore your mnemonic system with these commands:

```bash
# List all actors
hanzi actors

# List actors with usage stats (how many cards use each)
hanzi actors --usage

# List all sets (locations)
hanzi sets

# List sets with usage stats
hanzi sets --usage

# List all props (component meanings)
hanzi props

# List props with usage stats, limited to first 20
hanzi props --usage --limit 20
```

### Core Components

Each character can have a mnemonic story built from:

1. **Actor** - Person associated with the Pinyin initial (e.g., "sh-" → Sean Connery)
2. **Set** - Location associated with the Pinyin final (e.g., "-ao" → Mountain Cabin)
3. **Room** - Specific location within the set for the tone (e.g., Tone 3 → Bedroom)
4. **Props** - Character components with mnemonic meanings (e.g., "女" → Woman)
5. **Scene** - The full mnemonic story combining all elements

### Configuration

Your personal mnemonic system is stored in `config.yaml` alongside `cards.yaml`:

```yaml
mnemonic_system:
  actors:
    h-: "Hugh Jackman"
    sh-: "Sean Connery"
    # ... customize all 23 initials
    
  sets:
    -ao: "Mountain Cabin"
    -i: "Beach House"
    Ø: "Childhood Home"  # null final
    # ... exactly 13 sets for 13 finals
    
  rooms_by_tone:
    1: "Outside the Entrance"
    2: "Kitchen"
    3: "Bedroom"
    4: "Bathroom"
    5: "On the Roof"
    
  props:
    女: "Woman"
    子: "Child"
    # ... add as you learn
```

### Using R Functions

```r
library(hanziR)

# Read configuration
config <- read_config()

# Get mnemonic elements
get_actor("sh", config)  # "Sean Connery"
get_set("ao", config)    # "Mountain Cabin"
get_room(3, config)      # "Bedroom"
get_prop("女", config)   # "Woman"
```

### Backward Compatibility

- ✅ All mnemonic fields are **optional**
- ✅ v1.0 cards work perfectly without modification
- ✅ Add mnemonic info gradually as you learn
- ✅ Mix v1.0 and v2.0 cards in the same file

### Exports Include Mnemonic Data

All export formats now include mnemonic information:

**Markdown (`.md`):**
- Each card file includes a "## Mnemonic" section
- Shows actor, set, room, and full scene
- Component meanings displayed in parentheses

**CSV (`.csv`):**
- New columns: `keyword`, `mnemonic_actor`, `mnemonic_set`, `mnemonic_room`, `mnemonic_scene`
- Component meanings included in components column
- Perfect for spreadsheet analysis

**Anki TSV (`.tsv`):**
- Mnemonic appears on card back after meaning/example
- Formatted section: "--- MNEMONIC ---"
- Includes actor, set, room, and scene
- Easy to review while studying

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

### Card Management

#### `hanzi init [--minimal]`
Initialize new `cards.yaml` and `config.yaml` files with templates.

Options:
- `--minimal` or `--empty`: Create an empty cards list without example cards (start from scratch)

#### `hanzi add`
Interactively add a new card with prompts for all fields, including optional mnemonic information (actor, set, room, scene).

#### `hanzi list`
Display all cards in a compact table format.

#### `hanzi show <char>`
Show detailed information about a specific character, including mnemonic section if present.

#### `hanzi mnemonic <char>`
Quick-view of just the mnemonic information (actor, set, room, props, scene) for a character.

#### `hanzi search <query...>`
Full-text search across all fields (character, pinyin, meaning, examples, notes, tags).

#### `hanzi filter [options]`
Filter cards by specific criteria:
- `--initial <value>`: Filter by initial consonant
- `--final <value>`: Filter by final vowel sound
- `--tone <1-5>`: Filter by tone number
- `--component <char>`: Filter by component character
- `--tag <tag>`: Filter by tag (e.g., HSK1, common)
- `--actor <name>`: Filter by mnemonic actor (partial match)
- `--set <name>`: Filter by mnemonic set (partial match)
- `--room <name>`: Filter by mnemonic room (partial match)

#### `hanzi export <format> [--out <dir>]`
Export cards to different formats with mnemonic data:
- `md`: Markdown files (one per card + index) with mnemonic sections
- `csv`: Single CSV file with mnemonic columns
- `tsv`: Anki-compatible format with mnemonics on card back

#### `hanzi stats`
Display statistics about your card collection.

#### `hanzi validate`
Validate the `cards.yaml` file for consistency and completeness, including mnemonic validation against config.

### Configuration Management

#### `hanzi config init`
Initialize `config.yaml` with default actors, sets, rooms, and props.

#### `hanzi config show [section]`
Display configuration. Optional section: `actors`, `sets`, `rooms`, or `props`.

#### `hanzi config validate`
Validate configuration has exactly 13 sets and 5 rooms as required.

#### `hanzi config set <type> <key> <value>`
Set configuration values:
- `actor <initial> <name>`: Set actor for Pinyin initial
- `set <final> <location>`: Set location for Pinyin final
- `room <tone> <name>`: Set room for tone (1-5)
- `prop <component> <meaning>`: Set mnemonic meaning for component

### Discovery & Reference

#### `hanzi actors [--usage]`
List all actors in your mnemonic system. Use `--usage` to show card counts.

#### `hanzi sets [--usage]`
List all sets (locations) in your mnemonic system. Use `--usage` to show card counts.

#### `hanzi props [--usage] [--limit N]`
List all props (component meanings). Use `--usage` for card counts, `--limit N` to show only first N props.

## Data Structure

### v2.0 Format (with optional mnemonic fields)

Cards are stored in `cards.yaml`:

```yaml
version: "2.0"
created: "2025-10-14"
cards:
  - char: "好"
    pinyin: "hǎo"
    tone: 3
    tone_shape: "dip"
    tone_pattern: "\\/"
    initial: "h"
    final: "ao"
    
    # Standard fields
    meaning: "good, well, fine"
    keyword: "good"  # Optional: simpler mnemonic keyword
    example: "你好 (nǐ hǎo) - hello"
    tags: ["HSK1", "common", "greeting"]
    notes: "One of the most common characters"
    added: "2025-10-14T10:30:00Z"
    
    # Enhanced components - supports both formats:
    components:
      - char: "女"
        meaning: "Woman"  # v2.0: object with meaning
      - char: "子"
        meaning: "Child"
    # OR simple format: components: ["女", "子"]  # v1.0 still works!
    
    # Mnemonic system (completely optional)
    mnemonic:
      actor: "Hugh Jackman"     # Based on initial "h"
      set: "Mountain Cabin"      # Based on final "ao"
      room: "Bedroom"            # Based on tone 3
      scene: |
        Hugh Jackman walks into the bedroom of my mountain cabin,
        holding a woman and child by the hand. He smiles warmly and
        says "This is GOOD - family is what matters most."
```

### v1.0 Format (still fully supported)

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

### Core Package (v0.1.0) ✅
- [x] Setup & Infrastructure
- [x] Core Infrastructure
- [x] CRUD Operations
- [x] Query Operations
- [x] Export & Stats
- [x] CLI Integration
- [x] Documentation & Polish
- [x] Testing & Release

**Status**: Production ready! All 9 commands implemented and tested.

### Hanzi Movie Method Integration

**Phase 1: Core Data Structure ✅ (v2.0)**
- [x] Configuration system (`config.yaml`)
- [x] Enhanced card schema with mnemonic fields
- [x] Flexible component format (strings or objects)
- [x] Backward compatibility with v1.0 cards
- [x] Config utility functions (`get_actor`, `get_set`, `get_room`, `get_prop`)
- [x] Comprehensive test coverage (62 tests passing)
- [x] R CMD check: 0 errors, 0 warnings, 0 notes

**Phase 2: Configuration Management** ✅ (Complete)
- [x] `hanzi config` CLI commands
- [x] Config validation
- [x] Actor/set/room customization

**Phase 3: Enhanced CRUD** ✅ (Complete)
- [x] Interactive mnemonic prompts in `hanzi add`
- [x] Auto-populate from config based on pinyin
- [x] Enhanced `hanzi show` with mnemonic display
- [x] `hanzi mnemonic` quick-view command
- [x] Validation for mnemonic fields

**Phase 4: Enhanced Exports** ✅ (Complete)
- [x] Markdown export with mnemonic sections
- [x] Anki export with mnemonic on card back
- [x] CSV export with mnemonic columns
- [x] Component meanings in all formats

**Phase 5: Discovery & Reference** ✅ (Complete)
- [x] `hanzi actors` - List all actors with usage stats
- [x] `hanzi sets` - List all sets with usage stats
- [x] `hanzi props` - List all props with usage stats
- [x] Filter by actor/set/room in `hanzi filter`
- [x] Partial matching for mnemonic filters

## Contributing

This is a personal learning tool project. Suggestions and feedback welcome!

## License

MIT License - See LICENSE file for details

## Author

Built with ❤️ for accessible language learning

