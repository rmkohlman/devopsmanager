#!/bin/bash

# Configuration
BASE_DIR="$HOME/bin/devman"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/devops_manager.log"
DATABASE_FILE="$BASE_DIR/.image_tracker.db"
DEFAULT_DEV_IMAGE_NAME="dev_image"
OBSERVER_DIR="$BASE_DIR/observers"
source "$BASE_DIR/logging.sh"
source "$OBSERVER_DIR/build_image_observer.sh"
source "$OBSERVER_DIR/run_container_observer.sh"

###############################################
############## Start Project Observer #########
###############################################

# Function to extract network names from Dockerfile
extract_networks() {
    # Search Dockerfile for NETWORK instructions
    networks=$(grep -E "^# NETWORK" Dockerfile | awk '{print $3}')
    echo "$networks"
}

# Function to build network arguments for docker run
build_network_args() {
    # Extract network names
    networks=$(extract_networks)

    # Build the --network arguments for docker run
    network_args=""
    for network in $networks; do
        network_args+=" --network $network"
    done

    echo "$network_args"
}

# Function to start the Docker development container for a project
start_project_operation() {
    local observer_name="start_project_observer"
    log "INFO" "$observer_name: Starting development container for project: command: $1, project_name: $2"
    local command="$1"
    local project_name="$2"
    local image_name="${project_name}_${DEFAULT_DEV_IMAGE_NAME}:latest"  # Use the :latest tag

    log "INFO" "$observer_name: Starting development container for project: $project_name"

    # Check if the development image exists
    if docker images -q "$image_name" &> /dev/null; then
        log "INFO" "$observer_name: Using existing local image: $image_name"
    else
        # Build the development image if it doesn't exist
        log "INFO" "$observer_name: Building development image: $image_name"
        build_image_observer "$command" "$project_name"
    fi

    # Retrieve volume name from the database
    local volume_name=$(sqlite3 "$DATABASE_FILE" "SELECT volume_name FROM images WHERE project='$project_name' AND image='$image_name' LIMIT 1")

    # If volume name is empty, create a new volume and update the database
    if [ -z "$volume_name" ]; then
        log "INFO" "$observer_name: Volume name not found in the database. Creating volume..."
        volume_name="${project_name}_volume"
        docker volume create "$volume_name"
        # Update the database with the volume name
        sqlite3 "$DATABASE_FILE" "UPDATE images SET volume_name='$volume_name' WHERE project='$project_name' AND image='$image_name'"
    else
        log "INFO" "$observer_name: Found volume name in the database: $volume_name"
    fi

    # Run the development container with volume for Neovim setup
    run_container_observer "--run-project" "$project_name" 
}

# Observer for starting the Docker development container
start_project_observer() {
    local observer_name="start_project_observer"
    log "INFO" "$observer_name: Received command: $1, project_name: $2"

    local command="$1"
    local project_name="$2"

    log "DEBUG" "$observer_name: Entering start_project_observer method with command: $command, project_name: $project_name"

    # Check if the command is "--start-project" and project_name is provided
    if [ "$command" = "--start-project" ] && [ -n "$project_name" ]; then
        # Use the function to start the Docker development container
        start_project_operation "$command" "$project_name"
        return $?  # Return the result of the operation
    else
        log "ERROR" "$observer_name: Invalid command or project name provided: command: $command, project_name: $project_name"
        return 1  # Return false if no work to do
    fi
}

# Additional debug logging for the entire script
log "DEBUG" "Script initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

start_project_observer "$@"

