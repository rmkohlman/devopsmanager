
#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

###############################################
############## Build Image Observer ###########
###############################################

# Function to build the Docker image
build_docker_image() {
  local project_name="${1}"
  local image_name="${project_name}_${DEFAULT_DEV_IMAGE_NAME}:latest"

  log "INFO" "Building development image for project: $project_name"
  docker build --build-arg USER=$USER -t "$image_name" --target development .

  return $?
}

# Function to update the project's Docker image in the database
update_project_image_in_database() {
  local project_name="${1}"
  local image_name="${project_name}_${DEFAULT_DEV_IMAGE_NAME}:latest"

  sqlite3 "$DATABASE_FILE" "INSERT OR REPLACE INTO images (project, image, directory) VALUES ('$project_name', '$image_name', '$(pwd)');"
}

# Observer for building the Docker development image
build_image_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering build_image_observer function with command: $command, project_name: $project_name"

  # Check if the command is "--build"
  if [ "$command" = "--build" ]; then
    # Check if Dockerfile exists
    if [ ! -f "Dockerfile" ]; then
      log "ERROR" "Dockerfile not found in the current directory. Cannot build the image."
      return 1
    fi

    log "INFO" "Building development image for project: $project_name"

    # Build the Docker development image
    build_docker_image "$project_name"

    # Perform sanity checks
    if [ $? -ne 0 ]; then
      log "ERROR" "Build failed for project: $project_name"
      return 1
    fi

    # Update the project's Docker image in the database
    update_project_image_in_database "$project_name"

    # Additional sanity checks...
    # If any issues are found, log an error and return 1

    return 0
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "build_image_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

