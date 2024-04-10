
#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

###############################################
############## Update Directory Observer ######
###############################################

# Function to perform the update directory operation
update_directory_operation() {
  local project_name="$1"
  local new_directory="$2"

  log "INFO" "Updating the directory for the specified project: $project_name"
  log "INFO" "New directory: $new_directory"

  # Update the project directory in the database
  sqlite3 "$DATABASE_FILE" "UPDATE images SET directory='$new_directory' WHERE project='$project_name';"
}

# Observer for updating the directory of a project
update_directory_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering update_directory_observer method with command: $command, project_name: $project_name"

  # Check if the command is "--update-directory" and project_name is provided
  if [ "$command" = "--update-directory" ] && [ -n "$project_name" ]; then
    local new_directory="$(pwd)"

    # Call the business logic method to perform the update
    update_directory_operation "$project_name" "$new_directory"
    return 0  # Return true since it matches the command
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "update_directory_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"
