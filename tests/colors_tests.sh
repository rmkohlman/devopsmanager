
#!/usr/bin/env bash

# Check if running in Zsh, then switch to Zsh
if [ -n "$ZSH_VERSION" ]; then
  emulate -L zsh
fi

# Load the colors.sh script
BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/colors.sh"

# Check if the script successfully creates the ANSI codes database file
@test "Create ANSI codes database file" {
  [ -e "$DB_FILE" ]
}

# Check if tables COLORS, EFFECTS, and FORMATS are created in the database
@test "Create ANSI codes tables" {
  sqlite3 "$DB_FILE" ".tables" | grep -q "COLORS"
  sqlite3 "$DB_FILE" ".tables" | grep -q "EFFECTS"
  sqlite3 "$DB_FILE" ".tables" | grep -q "FORMATS"
}

# Check if the script inserts colors correctly into the COLORS table
@test "Insert colors into COLORS table" {
  declare -A expected_colors=(
    ["BLACK"]='\033[0;30m'
    ["RED"]='\033[0;31m'
    ["GREEN"]='\033[0;32m'
    ["YELLOW"]='\033[0;33m'
    ["BLUE"]='\033[0;34m'
    ["MAGENTA"]='\033[0;35m'
    ["CYAN"]='\033[0;36m'
    ["WHITE"]='\033[0;37m'
    ["LIGHT_BLACK"]='\033[1;30m'
    ["LIGHT_RED"]='\033[1;31m'
    # Add more color entries as needed
  )

  for color in "${!expected_colors[@]}"; do
    [ "$(get_value "$color")" = "${expected_colors[$color]}" ]
  done
}

# Check if the script inserts effects correctly into the EFFECTS table
@test "Insert effects into EFFECTS table" {
  declare -A expected_effects=(
    ["BOLD"]='\033[1m'
    ["DIM"]='\033[2m'
    ["ITALIC"]='\033[3m'
    ["UNDERLINE"]='\033[4m'
    ["BLINK"]='\033[5m'
    ["REVERSE"]='\033[7m'
    ["HIDDEN"]='\033[8m'
    ["STRIKETHROUGH"]='\033[9m'
    ["DOUBLE_UNDERLINE"]='\033[21m'
    ["FRAMED"]='\033[51m'
    # Add more effect entries as needed
  )

  for effect in "${!expected_effects[@]}"; do
    [ "$(get_value "$effect")" = "${expected_effects[$effect]}" ]
  done
}

# Check if the script inserts formats correctly into the FORMATS table
@test "Insert formats into FORMATS table" {
  declare -A expected_formats=(
    ["RESET"]='\033[0m'
    ["CLEAR_SCREEN"]='\033[2J'
    ["CLEAR_LINE"]='\033[K'
    ["SAVE_CURSOR"]='\033[s'
    ["RESTORE_CURSOR"]='\033[u'
    ["BEEP"]='\007'
    ["BELL"]='\033[7;11m'
    ["SELECT_GRAPHIC_RENDITION"]='\033[38;5;196m'
    ["SELECT_FOREGROUND_COLOR"]='\033[38;5;9m'
    ["SELECT_BACKGROUND_COLOR"]='\033[48;5;196m'
    # Add more format entries as needed
  )

  for format in "${!expected_formats[@]}"; do
    [ "$(get_value "$format")" = "${expected_formats[$format]}" ]
  done
}

# Check if the script prints all ANSI codes from the database
@test "Print all ANSI codes from the database" {
  run print_all_codes
  [ "$status" -eq 0 ]
}
