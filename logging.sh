
#!/bin/bash
#

# Configuration
BASE_DIR="$HOME/bin/devman"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/devops_manager.log"

# Source the colors.sh and text_decorator.sh libraries
source "$BASE_DIR/colors.sh"
source "$BASE_DIR/text_decorator.sh"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Touch log file if it doesn't exist
touch "$LOG_FILE"

# Logging function with level
log() {
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local level=$1
  local message=$2

  local timestamp_style=$(create_style "TURQUOISE_SURF_CYAN")
  local level_style=""
  local message_style=""

  case "$level" in
    "DEBUG")
      level_style=$(create_style "FOREST_GREEN")
      message_style=$(create_style "WHITE_SMOKE")
      ;;
    "INFO")
      level_style=$(create_style "BLUE_LAGOON_CYAN")
      message_style=$(create_style "ASHEN_WISP" "BG_LIGHT_ALABASTER")
      ;;
    "WARNING" | "WARN")
      level_style=$(create_style "GOLDENROD")
      message_style=$(create_style "SILVER_FOG")
      ;;
    "ERROR")
      level_style=$(create_style "ROSEWOOD_RED")
      message_style=$(create_style "STEEL_SILVER")
      ;;
    "CRITICAL")
      level_style=$(create_style "MAROON" "BOLD")
      message_style=$(create_style "SLATE_GRAY")
      ;;
    "ALERT")
      level_style=$(create_style "DARK_RED" "BOLD" "UNDERLINE")
      message_style=$(create_style "LIGHT_SMOKE")
      ;;
    "EMERGENCY")
      level_style=$(create_style "DARK_RED" "BOLD" "UNDERLINE" "ITALIC")
      message_style=$(create_style "DARK_MAGENTA")
      ;;
    *)
      level_style=""
      ;;
  esac

  local formatted_timestamp=$(create_decoration "$timestamp" "$timestamp_style")
  local formatted_level=$(create_decoration "$level" "$level_style")
  local formatted_message=$(create_decoration "$message" "$message_style")

  local formatted_entry="$formatted_timestamp [$formatted_level] $formatted_message"

  echo -e "$formatted_entry" >> "$LOG_FILE"
}

# Error handling function
handle_error() {
  local exit_code=$?
  local function_name="${FUNCNAME[1]:-unknown}"
  local line_number="${BASH_LINENO:-unknown}"

  log "ERROR" "Error occurred in function '$function_name' on line $line_number with exit code $exit_code"

  [[ "$function_name" == "show_help" ]] || return 1

  log "DEBUG" "Stack trace: ${FUNCNAME[@]}"
  log "DEBUG" "BASH_LINENO: ${BASH_LINENO[@]}"
  log "INFO" "Continuing with the script..."

  return 0
}
# # Test code for each log level
# log "DEBUG" "This is a debug message."
# log "INFO" "This is an info message."
# log "WARNING" "This is a warning message."
# log "ERROR" "This is an error message."
# log "CRITICAL" "This is a critical message."
# log "ALERT" "This is an alert message."
# log "EMERGENCY" "This is an emergency message."

# Additional debug logging for the entire script
log "DEBUG" "Script started. BASE_DIR: $BASE_DIR, LOG_FILE: $LOG_FILE"

