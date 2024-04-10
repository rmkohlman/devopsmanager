
#!/bin/bash

# Configuration
BASE_DIR="$HOME/bin/devman"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/devops_manager.log"
DATABASE_FILE="$BASE_DIR/.image_tracker.db"
DEFAULT_DEV_IMAGE_NAME="dev_image"
DEFAULT_DEV_NETWORK="development_network"  # Define the default network name
OBSERVER_DIR="$BASE_DIR/observers"
source "$BASE_DIR/logging.sh"

###############################################
############## Run Container Observer #########
###############################################

# Function to extract exposed ports from Dockerfile
extract_exposed_ports() {
    local observer_name="extract_exposed_ports"
    log "DEBUG" "$observer_name: Entering function"
    
    # Search Dockerfile for EXPOSE instructions
    exposed_ports=$(grep -E "^EXPOSE" Dockerfile | awk '{print $2}')
    
    log "DEBUG" "$observer_name: Extracted exposed ports: $exposed_ports"
    
    echo "$exposed_ports"
}

# Function to build port arguments for docker run
build_port_args() {
    local observer_name="build_port_args"
    log "DEBUG" "$observer_name: Entering function"
    
    # Extract exposed ports
    exposed_ports=$(extract_exposed_ports)

    port_args=""
    for port in $exposed_ports; do
        port_args+=" -p $port:$port"
    done

    log "DEBUG" "$observer_name: Built port arguments: $port_args"
    
    echo "$port_args"
}

# Function to create a Docker network if it doesn't exist
create_network() {
    local observer_name="create_network"
    local network_name="$1"

    log "DEBUG" "$observer_name: Attempting to create network: $network_name"

    if ! docker network inspect "$network_name" &> /dev/null; then
        log "INFO" "$observer_name: Network $network_name not found. Creating..."
        docker network create "$network_name"
        if [ $? -eq 0 ]; then
            log "INFO" "$observer_name: Network $network_name created successfully."
        else
            log "ERROR" "$observer_name: Failed to create network $network_name."
        fi
    else
        log "INFO" "$observer_name: Network $network_name already exists."
    fi
}

# Function to run container operation
run_container_operation() {
    local observer_name="run_container_operation"
    local project_name="$1"
    local preprod_image_name="${project_name}_${DEFAULT_DEV_IMAGE_NAME}:latest"

    log "INFO" "$observer_name: Running container for project: $project_name"

    local preprod_image=$(sqlite3 "$DATABASE_FILE" "SELECT image FROM images WHERE project='$project_name' AND image='$preprod_image_name' LIMIT 1")
    log "DEBUG" "$observer_name: Preprod image: $preprod_image"

    if [ -z "$preprod_image" ]; then
        log "INFO" "$observer_name: Preprod image not found in the database. Running build operation..."
        build_image_observer "--build" "$project_name"
    else
        log "INFO" "$observer_name: Found preprod image in the database: $preprod_image"
    fi

    local volume_name=$(sqlite3 "$DATABASE_FILE" "SELECT volume_name FROM images WHERE project='$project_name' AND image='$preprod_image_name' LIMIT 1")

    if [ -z "$volume_name" ]; then
        log "INFO" "$observer_name: Volume name not found in the database. Creating volume..."
        volume_name="${project_name}_volume"
        docker volume create "$volume_name"
        sqlite3 "$DATABASE_FILE" "UPDATE images SET volume_name='$volume_name' WHERE project='$project_name' AND image='$preprod_image_name'"
    else
        log "INFO" "$observer_name: Found volume name in the database: $volume_name"
    fi

    local neovim_volume="${project_name}_neovim"

    port_args=$(build_port_args)

    # Create the Docker network if it doesn't exist
    create_network "$DEFAULT_DEV_NETWORK"

    log "DEBUG" "$observer_name: preprod_image_name: $preprod_image_name"
    log "DEBUG" "$observer_name: volume_name: $volume_name"
    log "DEBUG" "$observer_name: port_args: $port_args"

    log "INFO" "$observer_name: Executing docker run command..."

    local docker_command="docker run -it --rm -u root:root \
            -v \"$(pwd)\":/workspace \
            -v \"$volume_name\":/path/in/container \
            -v \"$neovim_volume\":/root/.local/share/nvim \
            $port_args --network $DEFAULT_DEV_NETWORK $preprod_image_name"

    log "DEBUG" "$observer_name: Docker command: $docker_command"

    # Execute the Docker command
    log "INFO" "$observer_name: Executing docker run command: $docker_command"
    eval "$docker_command"
}

run_container_observer() {
    local observer_name="run_container_observer"
    local command="$1"
    local project_name="$2"

    log "DEBUG" "$observer_name: Entering function"
    log "DEBUG" "$observer_name: Command: $command, Project name: $project_name"

    if [ "$command" = "--run-project" ] && [ -n "$project_name" ]; then
        log "INFO" "$observer_name: Executing run_container_operation for project: $project_name"
        run_container_operation "$project_name"
        local result=$?
        if [ $result -eq 0 ]; then
            log "INFO" "$observer_name: Docker container for project $project_name ran successfully."
        else
            log "ERROR" "$observer_name: Failed to run Docker container for project $project_name."
        fi
        return $result
    else
        log "WARNING" "$observer_name: Invalid command or project_name not provided. Command: $command, project_name: $project_name"
        return 1
    fi
}

# Additional debug logging for the entire script
log "DEBUG" "run_container_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"


