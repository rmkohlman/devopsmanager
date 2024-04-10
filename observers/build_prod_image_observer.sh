
#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

###############################################
############## build Prod image observer ######
###############################################

# Function to build the Docker production image
build_prod_docker_image() {
  local project_name="${1}"
  local image_name="${project_name}_${DEFAULT_PROD_IMAGE_NAME}:$(date +'%Y_%m_%d_%H_%M')"

  log "INFO" "Building production image for project: $project_name"
  docker build -t "$image_name" --target production .

  return $?
}

# Function to update the project's Docker production image in the database
update_prod_image_in_database() {
  local project_name="${1}"
  local image_name="${project_name}_${DEFAULT_PROD_IMAGE_NAME}:$(date +'%Y_%m_%d_%H_%M')"

  sqlite3 "$DATABASE_FILE" "INSERT OR REPLACE INTO images (project, image, directory) VALUES ('$project_name', '$image_name', '$(pwd)');"
}

# Observer for building the Docker production image
build_prod_image_observer() {
  local command="$1"
  local project_name="$2"

  log "DEBUG" "Entering build_prod_image_observer method with command: $command, project_name: $project_name"

  # Check if the command is "--build-prod" and project_name is provided
  if [ "$command" = "--build-prod" ] && [ -n "$project_name" ]; then
    # Check if Dockerfile exists
    if [ ! -f "Dockerfile" ]; then
      log "ERROR" "Dockerfile not found in the current directory. Cannot build the production image."
      return 1
    fi

    log "INFO" "Building production image for project: $project_name"

    # Build the Docker production image
    build_prod_docker_image "$project_name"

    # Perform sanity checks
    if [ $? -ne 0 ]; then
      log "ERROR" "Build failed for production image of project: $project_name"
      return 1
    fi

    # Update the project's Docker production image in the database
    update_prod_image_in_database "$project_name"

    # Additional sanity checks...
    # If any issues are found, log an error and return 1

    return 0
  else
    return 1  # Return false if no work to do
  fi
}



# Additional debug logging for the entire script
log "DEBUG" "build_prod_image_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"


