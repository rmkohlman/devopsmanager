
#!/bin/bash

BASE_DIR="$HOME/bin/devman"

# Source the colors.sh library
source "$BASE_DIR/colors.sh"

# Function to create a style
create_style() {
  local styles=("$@")
  local style_code=""

  for style in "${styles[@]}"; do
    local code=$(get_value "$style")
    style_code+="$code"
  done

  echo "$style_code"
}

# Function to create a decoration object
create_decoration() {
  local target="$1"
  local styles=("${@:2}")  # Get all parameters starting from the 2nd one
  local decoration=""

  for style in "${styles[@]}"; do
    decoration+="$style"
  done

  decoration+="$target$(get_value 'RESET')"
  echo -e "$decoration"  # Use -e to interpret escape codes
}

# Function to apply decorations to a string
apply_decorations() {
  local text="$1"
  shift
  local decorations=("$@")

  for decoration in "${decorations[@]}"; do
    text="${text//$decoration}"
  done

  echo -e "$text"  # Use -e to interpret escape codes
}

