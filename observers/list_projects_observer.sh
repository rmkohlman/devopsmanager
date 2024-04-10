
#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

#############################################
########## List Projects Observer ##########
#############################################

# Function to list all tracked projects
list_all_tracked_projects() {
  # Retrieve all tracked projects
  projects=$(sqlite3 "$DATABASE_FILE" "SELECT DISTINCT project FROM images")

  # Check if the result is not empty
  if [ -n "$projects" ]; then
    echo "$projects"
  fi
}

# Observer for listing tracked projects
list_projects_observer() {
  local command="$1"
  local pattern="$2"

  log "DEBUG" "Entering list_projects_observer method with command: $command, pattern: $pattern"

  # Check if the command is "--list-projects"
  if [ "$command" = "--list-projects" ]; then
    log "INFO" "Listing all tracked projects"

    # Use the function to retrieve all projects
    projects=$(list_all_tracked_projects)

    # Check if the result is not empty
    if [ -n "$projects" ]; then
      # Iterate through the results for each project
      while IFS= read -r project; do
        log "DEBUG" "Processing project: $project"
        echo "$project"
      done <<< "$projects"
    else
      log "INFO" "No projects found in the database"
    fi
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "list_projects_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

