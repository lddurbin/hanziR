# hanziR Package - Project Plan

## Overview
A minimal R package providing a console app for managing Chinese character (Hanzi) learning cards with accessible tone cues and multiple export formats.

## Package Structure

```
hanziR/
├── DESCRIPTION
├── NAMESPACE
├── README.md
├── LICENSE
├── R/
│   ├── hanzi-package.R       # Package documentation
│   ├── cli.R                  # Main CLI entry point
│   ├── init.R                 # Initialize cards.yaml
│   ├── add.R                  # Add new cards
│   ├── list.R                 # List all cards
│   ├── show.R                 # Show single card
│   ├── search.R               # Search cards
│   ├── filter.R               # Filter cards by criteria
│   ├── export.R               # Export to md/csv/tsv
│   ├── stats.R                # Display statistics
│   ├── validate.R             # Validate cards.yaml
│   ├── utils.R                # Helper functions
│   ├── yaml-utils.R           # YAML read/write
│   └── tone-utils.R           # Accessible tone representations
├── inst/
│   ├── extdata/
│   │   └── cards-template.yaml  # Template for new projects
│   └── bin/
│       └── hanzi              # Executable script (Rscript wrapper)
├── man/                       # Documentation (auto-generated)
├── tests/
│   └── testthat/
│       ├── testthat.R
│       ├── test-init.R
│       ├── test-add.R
│       ├── test-filter.R
│       ├── test-export.R
│       └── test-validate.R
└── vignettes/
    └── getting-started.Rmd
```

## Core Dependencies

### Required Packages
- **yaml**: Reading/writing YAML files
- **cli**: Rich console formatting and progress bars
- **glue**: String interpolation
- **tibble**: Modern data frames
- **dplyr**: Data manipulation (tidyverse)
- **purrr**: Functional programming (tidyverse)
- **stringr**: String operations (tidyverse)
- **readr**: CSV export (tidyverse)

### Development Dependencies
- **usethis**: Package development workflow
- **devtools**: Package development tools
- **testthat**: Unit testing (>= 3.0.0)
- **withr**: Temporary file handling for tests

## Data Schema: cards.yaml

```yaml
version: "1.0"
created: "2025-10-14"
cards:
  - char: "好"
    pinyin: "hǎo"
    tone: 3
    tone_shape: "dip"        # Accessible: 1=flat, 2=rise, 3=dip, 4=fall, 5=neutral
    tone_pattern: "\\/"      # Visual pattern
    initial: "h"
    final: "ao"
    components: ["女", "子"]
    meaning: "good, well"
    example: "你好 (nǐ hǎo) - hello"
    tags: ["HSK1", "common", "greeting"]
    notes: "One of the most common characters"
    added: "2025-10-14T10:30:00Z"
    
  - char: "中"
    pinyin: "zhōng"
    tone: 1
    tone_shape: "flat"
    tone_pattern: "---"
    initial: "zh"
    final: "ong"
    components: ["口", "|"]
    meaning: "middle, center, China"
    example: "中国 (Zhōngguó) - China"
    tags: ["HSK1", "common"]
    notes: ""
    added: "2025-10-14T10:31:00Z"
```

## Command Line Interface

### 1. `hanzi init`
Initialize a new cards.yaml file in the current directory or inst/data/.

**Implementation:**
- Check if cards.yaml already exists
- Prompt user to confirm overwrite if exists
- Create minimal template with example cards
- Display success message with next steps

### 2. `hanzi add`
Interactive prompt to add a new card.

**Workflow:**
1. Prompt for character (required)
2. Prompt for pinyin (required)
3. Parse/prompt for tone (1-5)
4. Auto-generate tone_shape and tone_pattern
5. Parse/prompt for initial and final
6. Prompt for components (comma-separated)
7. Prompt for meaning (required)
8. Prompt for example (optional)
9. Prompt for tags (comma-separated, optional)
10. Prompt for notes (optional)
11. Add timestamp
12. Append to cards.yaml
13. Display summary of added card

### 3. `hanzi list`
List all cards in a compact table format.

**Output columns:**
- Character
- Pinyin (with tone)
- Tone shape (accessible)
- Meaning (truncated)
- Tags
- Count: X cards

### 4. `hanzi show <char>`
Display detailed information about a specific character.

**Output:**
```
╔════════════════════════════════════════╗
║  好 (hǎo) - Tone 3 (dip \/)           ║
╠════════════════════════════════════════╣
║  Meaning: good, well                   ║
║  Components: 女, 子                    ║
║  Initial: h | Final: ao                ║
║  Example: 你好 (nǐ hǎo) - hello        ║
║  Tags: HSK1, common, greeting          ║
║  Notes: One of the most common chars   ║
║  Added: 2025-10-14                     ║
╚════════════════════════════════════════╝
```

### 5. `hanzi search <query...>`
Full-text search across all fields.

**Behavior:**
- Search in: char, pinyin, meaning, example, notes, tags
- Case-insensitive
- Multiple terms = OR logic
- Display matching cards in list format

### 6. `hanzi filter [options]`
Filter cards by specific criteria.

**Options:**
- `--initial <value>`: Filter by initial (e.g., "zh")
- `--final <value>`: Filter by final (e.g., "ong")
- `--tone <1-5>`: Filter by tone number
- `--component <char>`: Filter by component character
- `--tag <tag>`: Filter by tag (e.g., "HSK1")
- Multiple filters = AND logic
- Display matching cards in list format

### 7. `hanzi export <format> [--out <dir>]`
Export cards to various formats.

**Formats:**
- `md`: Markdown files (one per card + index.md)
- `csv`: Single CSV file with all fields
- `tsv`: Anki-compatible TSV (Front: char/pinyin, Back: meaning/example)

**Behavior:**
- Default output: `./export/`
- Create output directory if doesn't exist
- For markdown: create one file per card (`好.md`) + `index.md` with links
- Display count of exported files

### 8. `hanzi stats`
Display statistics about the card collection.

**Metrics:**
- Total cards
- Cards by tone (1-5)
- Cards by initial (top 10)
- Cards by final (top 10)
- Cards by tag
- Cards by component (if many cards)
- Most recently added (5 cards)

### 9. `hanzi validate`
Validate the cards.yaml file for consistency.

**Checks:**
- Valid YAML syntax
- Required fields present (char, pinyin, meaning)
- Valid tone values (1-5)
- Valid initial/final combinations
- No duplicate characters
- Consistent tone shape/pattern with tone number
- Display warnings for missing optional fields
- Exit with appropriate code

## Accessible Tone System

Mandarin has 5 tones. For accessibility (color blindness):

| Tone | Name    | Shape   | Pattern | Color Name | Description        |
|------|---------|---------|---------|------------|--------------------|
| 1    | First   | flat    | `---`   | red        | High level         |
| 2    | Second  | rise    | `/`     | orange     | Rising             |
| 3    | Third   | dip     | `\/`    | green      | Dip then rise      |
| 4    | Fourth  | fall    | `\`     | blue       | Falling            |
| 5    | Neutral | neutral | `.`     | gray       | Light/neutral tone |

**Implementation:**
- Always display: tone number + shape + pattern
- Example: "Tone 3 (dip \\/)"
- Use cli package colors for terminal, but always include text labels

## Development Workflow

### Phase 1: Setup (Day 1)
1. ✅ Create PROJECT_PLAN.md
2. Initialize package structure
   ```r
   usethis::create_package("hanziR")
   usethis::use_mit_license()
   usethis::use_readme_md()
   usethis::use_testthat()
   usethis::use_vignette("getting-started")
   usethis::use_pipe()  # For |> operator
   ```
3. Add dependencies to DESCRIPTION
4. Create basic package documentation

### Phase 2: Core Infrastructure (Day 1-2)
1. Implement `yaml-utils.R`: read_cards(), write_cards()
2. Implement `tone-utils.R`: tone shape/pattern generation
3. Implement `utils.R`: file path helpers, validation helpers
4. Write tests for utils
5. Implement `init.R` command
6. Test init command

### Phase 3: CRUD Operations (Day 2-3)
1. Implement `add.R` with interactive prompts
2. Implement `list.R` with formatted table
3. Implement `show.R` with detailed view
4. Write tests for each
5. Manual testing of workflow

### Phase 4: Query Operations (Day 3-4)
1. Implement `search.R` with full-text search
2. Implement `filter.R` with multiple criteria
3. Implement `validate.R` with comprehensive checks
4. Write tests for each
5. Manual testing of edge cases

### Phase 5: Export & Stats (Day 4-5)
1. Implement `export.R` with all three formats
2. Test markdown generation
3. Test CSV/TSV generation
4. Implement `stats.R` with summary statistics
5. Write tests for exports and stats

### Phase 6: CLI Integration (Day 5)
1. Create main `cli.R` with argument parsing
2. Create `inst/bin/hanzi` executable script
3. Test all commands end-to-end
4. Handle edge cases and error messages

### Phase 7: Documentation & Polish (Day 5-6)
1. Complete all roxygen2 documentation
2. Write vignette with examples
3. Update README with installation and usage
4. Add examples to function documentation
5. Run `devtools::check()` and fix issues

### Phase 8: Testing & Release (Day 6)
1. Achieve >80% test coverage
2. Test installation from GitHub
3. Test executable script
4. Create GitHub repository
5. Tag v0.1.0 release

## Testing Strategy

### Unit Tests
- Each R function has corresponding test file
- Test normal cases and edge cases
- Use withr for temporary file handling
- Mock YAML files for testing

### Integration Tests
- Test complete workflows (init → add → list → export)
- Test command chaining
- Test with malformed YAML

### Manual Testing Checklist
- [ ] Init in empty directory
- [ ] Init with existing cards.yaml
- [ ] Add card with all fields
- [ ] Add card with minimal fields
- [ ] List empty cards
- [ ] List 50+ cards
- [ ] Show existing card
- [ ] Show non-existent card
- [ ] Search with matches
- [ ] Search with no matches
- [ ] Filter with single criterion
- [ ] Filter with multiple criteria
- [ ] Export all three formats
- [ ] Stats with empty/small/large sets
- [ ] Validate good file
- [ ] Validate malformed file

## Error Handling

All functions should:
1. Check if cards.yaml exists when required
2. Provide clear error messages
3. Use `cli::cli_abort()` for errors
4. Use `cli::cli_warn()` for warnings
5. Use `cli::cli_inform()` for success messages
6. Validate user input
7. Handle file I/O errors gracefully

## Installation & Usage

### Installation
```r
# Install dependencies
install.packages("devtools")

# Install from source
devtools::install()

# Or from GitHub (future)
devtools::install_github("username/hanziR")
```

### Making CLI Available
```bash
# Add to PATH in ~/.zshrc or ~/.bashrc
export PATH="$PATH:$(Rscript -e 'cat(system.file("bin", package="hanziR"))')"

# Or create symlink
ln -s $(Rscript -e 'cat(system.file("bin", package="hanziR"))') /usr/local/bin/hanzi
```

### Usage Example
```bash
# Initialize
hanzi init

# Add cards
hanzi add

# List all
hanzi list

# Show specific character
hanzi show 好

# Search
hanzi search greeting

# Filter HSK1 cards
hanzi filter --tag HSK1

# Export to markdown
hanzi export md --out docs/

# View statistics
hanzi stats

# Validate
hanzi validate
```

## Success Criteria

- ✅ All commands implemented and working
- ✅ Accessible tone representation
- ✅ YAML source of truth maintained
- ✅ All export formats working
- ✅ >80% test coverage
- ✅ Comprehensive documentation
- ✅ Pure terminal workflow (no GUI)
- ✅ Clean package structure following R conventions
- ✅ Passes `R CMD check` with no errors or warnings

## Future Enhancements (v0.2.0+)

1. **Review System**: Spaced repetition scheduling
2. **Import**: Import from Anki, CSV, or other formats
3. **Audio**: Link to pronunciation audio files
4. **Images**: Associate images with characters
5. **Stroke Order**: Display or link to stroke order diagrams
6. **Progress Tracking**: Track review history and accuracy
7. **Deck Management**: Multiple decks/collections
8. **Web Interface**: Optional Shiny dashboard
9. **API**: R6 class for programmatic access
10. **Fuzzy Search**: More intelligent search with typo tolerance

## Notes

- Keep code modular and testable
- Use tidyverse conventions throughout
- Prioritize readability over performance (small data)
- Follow R package best practices
- Document all exported functions with roxygen2
- Use native pipe `|>` per user preference
- Make tone accessibility a first-class feature
- Ensure graceful degradation in non-color terminals

