#!/bin/bash

# Configuration
BASE_DIR="$HOME/bin/devman"
LOG_DIR="$BASE_DIR/logs"
LOG_FILE="$LOG_DIR/devops_manager.log"
OBSERVER_DIR="$BASE_DIR/observers"
DOCKERFILE_TEMPLATES_DIR="$BASE_DIR/dockerfile_templates"
INIT_LUA_CONFIG="$BASE_DIR/neoconfig_templates"

source "$BASE_DIR/logging.sh"

# Function to create a new project
create_new_project() {
  local project_name="$1"
  local project_type="$2"

  log "INFO" "Creating a new project: $project_name, Type: $project_type"

  # Validate project type
  case "$project_type" in
    "ocaml" | "rust" | "go" | "python" | "cplusplus" | "javascript" | "lua")
      ;;
    *)
      log "ERROR" "Invalid project type: $project_type"
      return 1
      ;;
  esac

  # Set up project directory
  local project_dir="$HOME/Documents/code/$project_name"
  mkdir -p "$project_dir"
  log "INFO" "Project directory created: $project_dir"
  # Common section for all project types
  # Copy init.lua from neoconfig_templates
  cp "$INIT_LUA_CONFIG/init.lua" "$project_dir/"
  
  # Copy Dockerfile from templates
  local dockerfile_template=""
  case "$project_type" in
    "ocaml" | "rust" | "go" | "python" | "cplusplus" | "javascript" | "lua")
      dockerfile_template="${project_type}_dockerfile"
      ;;
    *)
      log "ERROR" "Invalid project type: $project_type"
      return 1
      ;;
  esac
  local dockerfile_path="$DOCKERFILE_TEMPLATES_DIR/$dockerfile_template"
  cp "$dockerfile_path" "$project_dir/Dockerfile"
  log "INFO" "Dockerfile created: $project_dir/Dockerfile"

  # Create standard files based on project type
  case "$project_type" in
    "ocaml")
      touch "$project_dir/main.ml"
      echo "ocamlbuild -pkg ocamlfind -pkg core main.native" > "$project_dir/Makefile"
      echo "clean:" >> "$project_dir/Makefile"
      echo "  ocamlbuild -clean" >> "$project_dir/Makefile"
      touch "$project_dir/.merlin"
      ;;
    "rust")
      touch "$project_dir/main.rs"
      touch "$project_dir/Cargo.toml"
      ;;
    "go")
      touch "$project_dir/main.go"
      ;;
    "python")
      touch "$project_dir/main.py"
      touch "$project_dir/requirements.txt"
      ;;
    "cplusplus")
      touch "$project_dir/main.cpp"
      ;;
    "javascript")
      touch "$project_dir/main.js"
      touch "$project_dir/package.json"
      ;;
    "lua")
      touch "$project_dir/main.lua"
      ;;
  esac

  log "INFO" "Standard files created for $project_type in $project_dir"

  # Change to the project directory
  cd "$project_dir" || return 1
  log "INFO" "Changed to the project directory: $project_dir"
}

# Observer for creating a new project
create_new_project_observer() {
  local command="$1"
  local project_name="$2"
  local project_type="$3"

  log "DEBUG" "Entering create_new_project_observer method with command: $command, project_name: $project_name, project_type: $project_type"

  # Check if the command is "--create-new-project" and project_name and project_type are provided
  if [ "$command" = "--create-new-project" ] && [ -n "$project_name" ] && [ -n "$project_type" ]; then
    # Use the function to create a new project
    create_new_project "$project_name" "$project_type"
    return $?  # Return the result of the operation
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "create_new_project_observer initialized. BASE_DIR: $BASE_DIR, LOG_FILE: $LOG_FILE"

