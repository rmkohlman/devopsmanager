
#!/bin/bash

###############################################
######## Sync Neovim Config Observer ##########
###############################################

# Configuration
BASE_DIR="$HOME/bin/devman"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/devops_manager.log"
OBSERVER_DIR="$BASE_DIR/observers"
NEOVIM_CONFIG_TEMPLATES="$BASE_DIR/neoconfig_templates"
DATABASE_FILE="$BASE_DIR/.image_tracker.db"

source "$BASE_DIR/logging.sh"

# Function to confirm if the project is found and get its path from the database
get_project_path() {
  local project_name="$1"

  log "DEBUG" "Entering get_project_path method for project_name: $project_name"

  # Check if the project exists in the database
  local project_path=$(sqlite3 "$DATABASE_FILE" "SELECT directory FROM images WHERE project='$project_name' LIMIT 1")
  
  if [ -n "$project_path" ]; then
    echo "$project_path"
  else
    log "ERROR" "Project not found in the database: $project_name"
    echo ""  # Return an empty string if project not found
  fi
}

# Function to perform the sync
sync_neovim_config() {
  local project_path="$1"

  log "DEBUG" "Entering sync_neovim_config method for project_path: $project_path"

  # Check if the project path is not empty
  if [ -n "$project_path" ]; then
    # Copy init.lua from neoconfig_templates to the project directory
    cp "$NEOVIM_CONFIG_TEMPLATES/init.lua" "$project_path/"
    log "INFO" "Neovim config synced for project at path: $project_path"
  else
    log "ERROR" "Unable to sync Neovim config: Empty project path"
  fi
}

# Observer function
sync_neovim_config_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering sync_neovim_config_observer method with command: $command, project_name: $project_name"

  # Check if the command matches
  if [ "$command" = "--sync-neovim-config" ]; then
    # Confirm if the project is found and get its path from the database
    local project_path=$(get_project_path "$project_name")

    # Sync the Neovim config if the project is found
    if [ -n "$project_path" ]; then
      sync_neovim_config "$project_path"
      log "INFO" "Neovim config synced for project: $project_name"
    else
      log "ERROR" "Project not found in the database: $project_name"
    fi
  else
    log "DEBUG" "Command does not match --sync-neovim-config"
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "sync_neovim_config_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"
