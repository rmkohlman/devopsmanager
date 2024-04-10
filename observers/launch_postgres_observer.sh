#!/bin/bash

BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/logging.sh"

###############################################
############# Launch PostgreSQL Observer ######
###############################################

# Function to check if the PostgreSQL container exists and is stopped
postgres_container_exists_and_stopped() {
    local container_name="postgresdb"
    local container_status=$(docker inspect -f '{{.State.Status}}' "$container_name" 2>/dev/null || echo "not_found")

    # Check if container exists and is stopped
    if [ "$container_status" = "exited" ]; then
        return 0  # Container exists and is stopped
    else
        return 1  # Container doesn't exist or is not stopped
    fi
}

# Function to start the PostgreSQL container
start_postgres_container() {
    local container_name="postgresdb"
    log "INFO" "Starting PostgreSQL container..."
    docker start "$container_name"
    log "INFO" "PostgreSQL container started successfully."
}

# Function to launch the PostgreSQL container if it doesn't exist or is not stopped
launch_postgres_container() {
    if postgres_container_exists_and_stopped; then
        start_postgres_container
    else
        log "INFO" "Launching PostgreSQL container..."
        docker run --name postgresdb -e POSTGRES_PASSWORD=postgres -p 5432:5432 --network development_network -v postgres_data:/var/lib/postgresql/data -d postgres
        log "INFO" "PostgreSQL container launched successfully."
    fi
}

# Observer for launching a PostgreSQL container
launch_postgres_observer() {
    local command="$1"
    local projet_name="$2"

    log "DEBUG" "Entering launch_postgres_observer method with command: $command"

    # Check if the command is "--launch-postgres"
    if [ "$command" = "--launch-postgres" ]; then
        launch_postgres_container
        return $?  # Return the result of the operation
    else
        return 1  # Return false if no work to do
    fi
}

# Additional debug logging for the entire script
log "DEBUG" "launch_postgres_observer initialized. BASE_DIR: $BASE_DIR, LOG_FILE: $LOG_FILE"

