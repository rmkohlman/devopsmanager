
#!/bin/bash

BASE_DIR="$HOME/bin/devman"

# Source the colors.sh and text_decorator.sh libraries
source "$BASE_DIR/colors.sh"
source "$BASE_DIR/text_decorator.sh"

# Observer for showing the help message
show_help() {
  log "DEBUG" "Entering show_help method..."

  # Define styles
  bold_style=$(create_style "BOLD")
  italic_style=$(create_style "ITALIC")
  light_text_style=$(create_style "EXTRA_LIGHT_WHITE")
  reset_style=$(create_style "RESET")

  # Create decorations
  command_title_decoration=$(create_decoration "$bold_style")
  option_title_decoration=$(create_decoration "$bold_style")

  # Define background colors
  dark_gray_bg_color=$(create_style "BG_DARK_GRAY")
  dark_white_bg_color=$(create_style "BG_DARK_WHITE")

  # Apply decorations to the help message
  echo -e "${dark_gray_bg_color}${command_title_decoration}Command Options:${reset_style}"
  print_option "--build" "Build and run the development container" "$italic_style" "$dark_white_bg_color" "$light_text_style"
  print_option "--build-prod" "Build the production image" "$italic_style" "$dark_gray_bg_color" "$light_text_style"
  print_option "--clean-start" "Delete project images and rebuild the development image" "$italic_style" "$dark_white_bg_color" "$light_text_style"
  print_option "--list-projects" "List all tracked projects" "$italic_style" "$dark_gray_bg_color" "$light_text_style"
  print_option "--list-images [PROJECT]" "List images for the specified project (or 'all' for all projects)" "$italic_style" "$dark_white_bg_color" "$light_text_style"
  print_option "--goto PROJECT" "Change to the directory of the specified project" "$italic_style" "$dark_gray_bg_color" "$light_text_style"
  print_option "--update-directory [PROJECT]" "Update the directory for the specified project (or use the current working directory)" "$italic_style" "$dark_white_bg_color" "$light_text_style"
  print_option "--delete-images" "Delete project images and wipe the database" "$italic_style" "$dark_gray_bg_color" "$light_text_style"
  print_option "--start-project" "Start the development container for the project" "$italic_style" "$dark_white_bg_color" "$light_text_style"
  print_option "--create-new-project NAME TYPE" "Create a new project with the specified NAME and TYPE" "$italic_style" "$dark_gray_bg_color" "$light_text_style"
  print_option "--sync-neovim-config PROJECT" "Sync Neovim config for the specified project" "$italic_style" "$dark_white_bg_color" "$light_text_style"
  print_option "--launch-postgres" "will launch a postgres database in the network postgres" "$italic_style" "$dark_white_bg_color" "$light_text_style"
  print_option "--help" "Show this help message" "$italic_style" "$dark_gray_bg_color" "$light_text_style"
}

# Function to print an option in a formatted style
print_option() {
  local option="$1"
  local description="$2"
  local styles=("${@:3}")  # Get all parameters starting from the 3rd one

  local formatted_option=$(create_decoration "$option" "${styles[@]}")
  local formatted_description=$(create_decoration "$description" "${styles[@]}")

  echo -e "  $formatted_option\t$formatted_description${reset_style}"
}

help_observer() {
  local command="$1"

  log "DEBUG" "Entering help_observer method..."
  log "DEBUG" "command is  ...$command"

  # Check if the parameter passed is "--help"
  if [ "$command" = "--help" ]; then
    # Show the help message
    log "DEBUG" "Executing show_help"
    show_help
    return 0  # Always return true since showing the help is not an error
  else
    return 1  # Return false if no work to do
  fi
}

# Additional debug logging for the entire script
log "DEBUG" "help_observer initialized. BASE_DIR: $BASE_DIR, DATABASE_FILE: $DATABASE_FILE, LOG_FILE: $LOG_FILE"

