#!/bin/bash

# Configuration
DEFAULT_DEV_IMAGE_NAME="dev_image"
DEFAULT_PROD_IMAGE_NAME="prod_image"
BASE_DIR="$HOME/bin/devman"
OBSERVER_DIR="$BASE_DIR/observers"
DATABASE_FILE="$BASE_DIR/.image_tracker.db"

# LOG_DIR and LOG_FILE are sourced from logging.sh

# Source the logging functions
source "$BASE_DIR/logging.sh"

# Additional debug logging for the entire script
log "DEBUG" "$(basename "$0") - Main script started. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

# Check dependencies including the presence of the "app" folder
check_dependencies() {
  log "DEBUG" "$(basename "$0") - Checking dependencies..."
  command -v docker &> /dev/null || { log "ERROR" "$(basename "$0") - Docker is not installed or not in the PATH."; exit 1; }
  command -v sqlite3 &> /dev/null || { log "ERROR" "$(basename "$0") - SQLite is not installed or not in the PATH."; exit 1; }

  # Check for the existence of the "app" folder
  # [ -d "$BASE_DIR/app" ] || { log "ERROR" "$(basename "$0") - The 'app' folder is missing."; exit 1; }
}

# Initialize the database and log file
initialize_database() {
  log "DEBUG" "$(basename "$0") - Initializing database and log file..."
  check_dependencies

  # Create the database file if it doesn't exist
  [ -f "$DATABASE_FILE" ] || sqlite3 "$DATABASE_FILE" "CREATE TABLE images (project TEXT, image TEXT, directory TEXT);"

  # Create the log file if it doesn't exist
  touch "$LOG_FILE" || { log "ERROR" "$(basename "$0") - Could not create the log file: $LOG_FILE"; exit 1; }
}

# Additional debug logging for the entire script
log "DEBUG" "$(basename "$0") - Main script initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

###############################################
############## Notifier  ######################
###############################################

# Source all observer scripts
source "$OBSERVER_DIR/build_image_observer.sh"
source "$OBSERVER_DIR/build_prod_image_observer.sh"
source "$OBSERVER_DIR/clean_start_observer.sh"
source "$OBSERVER_DIR/list_projects_observer.sh"
source "$OBSERVER_DIR/list_images_observer.sh"
source "$OBSERVER_DIR/goto_project_observer.sh"
source "$OBSERVER_DIR/delete_images_observer.sh"
source "$OBSERVER_DIR/start_project_observer.sh"
source "$OBSERVER_DIR/update_directory_observer.sh"
source "$OBSERVER_DIR/help_observer.sh"
source "$OBSERVER_DIR/create_new_project_observer.sh"
source "$OBSERVER_DIR/sync_neovim_config_observer.sh"
source "$OBSERVER_DIR/launch_postgres_observer.sh"

# Array of observers
observers=(
  launch_postgres_observer
  build_image_observer
  build_prod_image_observer
  clean_start_observer
  list_projects_observer
  list_images_observer
  goto_project_observer
  delete_images_observer
  start_project_observer
  create_new_project_observer
  sync_neovim_config_observer
  update_directory_observer  # Add the new observer here
  help_observer
)

# Notifier function
notify_observers() {
    local module_name="devopsmanager"
    log "DEBUG" "$(basename "$0") - $module_name - Notifier function called with arguments: $@"
    if [ $# -eq 0 ]; then
        log "DEBUG" "$(basename "$0") - $module_name - No command provided. Calling help_observer with --help."
        help_observer "--help"
        return
    fi

    # Capture all command-line arguments in the args array
    args=("$@")

    # Adjust the second argument if it's not provided
    args[2]="${args[2]:-$(basename "$(pwd)")}"

    for observer in "${observers[@]}"; do
        # Call the observer with the captured arguments
        if "$observer" "${args[@]}"; then
            log "DEBUG" "$(basename "$0") - $module_name - Observer '$observer' returned true. Breaking out of the loop."
            break
        fi
    done
}

###############################################
############## MAIN  ##########################
###############################################
# Parse command-line options
initialize_database
log "DEBUG" "$(basename "$0") - Main script - Arguments passed to notify_observers: $@"
notify_observers "$@"

