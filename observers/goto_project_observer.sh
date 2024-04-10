
#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

###############################################
############## Goto Project Observer ##########
###############################################

# Function to change to a project directory
goto_project_operation() {
  local project_name="$1"
  local project_dir=$(sqlite3 "$DATABASE_FILE" "SELECT directory FROM images WHERE project='$project_name' LIMIT 1")

  log "INFO" "Project Name: $project_name"
  log "INFO" "Project Directory: $project_dir"

  [ -n "$project_dir" ] || { log "ERROR" "Project directory not found for $project_name"; return 1; }

  log "INFO" "Changing directory to: $project_dir"
  cd "$project_dir" || { log "ERROR" "Failed to change directory to: $project_dir"; return 1; }

  log "INFO" "Changed directory to: $(pwd)"
}

# Observer for changing to a project directory
goto_project_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering goto_project_observer method with command: $command, project_name: $project_name"

  # Check if the command is "--goto" and project_name is provided
  if [ "$command" = "--goto" ] && [ -n "$project_name" ]; then
    log "INFO" "Changing to the directory of the specified project: $project_name"

    # Use the function to change to the project directory
    goto_project_operation "$project_name"
    
    # Check the result of the operation
    if [ $? -eq 0 ]; then
      # Successfully changed to the project directory
      log "INFO" "Changed to the directory of the specified project: $project_name"
    else
      # Project not found or failed to change directory
      log "ERROR" "Failed to change to the directory of the specified project: $project_name"
      log "INFO" "Project not found: $project_name"
      echo "Failed to change to the directory: Project not found: $project_name"
      source $BASE_DIR/observers/list_projects_observer.sh
      echo "avaiable projects: "
      list_all_tracked_projects
    fi
    
    # Regardless of success or failure, return true
    return 0
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "goto_project_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

