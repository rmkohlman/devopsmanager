
#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

##############################################
############## Clean Start Observer ##########
##############################################

# Delete project images and wipe the database
delete_project_images() {
  log "DEBUG" "Entering delete_project_images method..."
  local project_name="${1:-$(basename "$(pwd)")}"

  # Delete all images associated with the project
  docker images -a | grep "$project_name" | awk '{print $3}' | xargs docker rmi -f

  # Wipe the database entries for the project
  sqlite3 "$DATABASE_FILE" "DELETE FROM images WHERE project='$project_name'"
}

# Function to delete project images and wipe the database
clean_start_project() {
  local command="$1"
  local project_name="$2"

  log "INFO" "Cleaning start for project: $project_name"

  # Delete all images and wipe the database for the specific project
  delete_project_images "$project_name"

  # Build a new development image and load the database
  build_image_observer "--build" "$project_name"
}

# Observer for a clean start for a project
clean_start_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering clean_start_observer method with command: $command, project_name: $project_name"

  # Check if the command is "--clean-start" and project_name is provided
  if [ "$command" = "--clean-start" ] && [ -n "$project_name" ]; then
    # Perform the clean start operation
    clean_start_project "$command" "$project_name"

    # Additional sanity checks...
    # If any issues are found, log an error and return 1

    return 0
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "clean_start_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

