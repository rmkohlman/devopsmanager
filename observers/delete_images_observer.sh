#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

##################################################
############ Delete Project Images Observer ######
##################################################

# Function to delete project images and wipe the database
delete_project_images_operation() {
  local project_name="$1"

  log "INFO" "Starting the Deletion process for project: $project_name"

  # Delete all images associated with the project
  docker images -a | grep "$project_name" | awk '{print $3}' | xargs docker rmi -f
  log "INFO" "Deleted images  for project: $project_name"

  # Wipe the database entries for the project
  sqlite3 "$DATABASE_FILE" "DELETE FROM images WHERE project='$project_name'"
  log "INFO" "Deleted images from database for project: $project_name"
}

# Observer for deleting project images
delete_images_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering delete_images_observer method with command: $command, project_name: $project_name"

  # Check if the command is "--delete-images" and project_name is provided
  if [ "$command" = "--delete-images" ] && [ -n "$project_name" ]; then
    # Use the function to delete project images and wipe the database
    delete_project_images_operation "$project_name"
    return 0 # Return the result of the operation
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "delete_images_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

