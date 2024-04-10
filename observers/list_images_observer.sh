
#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

###############################################
############## List Images Observer ###########
###############################################

# Function to list images for a specific project
list_images_for_project() {
  local project_name="$1"
  log "DEBUG" "Entering list_images_for_project function with project_name: $project_name"

  log "DEBUG" "Value of project_name: $project_name"

  if [ -z "$project_name" ]; then
    log "ERROR" "Project name is required for listing images."
    return 1
  fi

  images=$(sqlite3 "$DATABASE_FILE" "SELECT DISTINCT image FROM images WHERE project = '$project_name'")

  if [ -n "$images" ]; then
    echo "$images"
    return 0  # Indicate that processing was successful
  else
    log "INFO" "No images found for project: $project_name"
    return 1  # Indicate that no images were found
  fi
}

# Function to list images for all projects
list_images_for_all_projects() {
  log "INFO" "Listing images for all projects"

  # Retrieve all projects and their images
  images=$(sqlite3 "$DATABASE_FILE" "SELECT DISTINCT image FROM images")

  if [ -n "$images" ]; then
    echo "$images"
    return 0  # Indicate that processing was successful
  else
    log "INFO" "No images found in the database"
    return 1  # Indicate that no images were found
  fi
}

# Observer for listing images
list_images_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering list_images_observer function with command: $command, project_name: $project_name"

  # Check if the command is "--list-images"
  if [ "$command" = "--list-images" ]; then
    log "INFO" "Listing images for project: $project_name"

    # Check if the project name is "all"
    if [ "$project_name" = "all" ]; then
      log "INFO" "Listing images for all projects"
      # Use the function to retrieve images for all projects
      list_images_for_all_projects
    else
      # Use the function to retrieve images for the provided project
      list_images_for_project "$project_name"
    fi
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "list_images_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

