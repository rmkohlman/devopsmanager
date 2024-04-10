#!/bin/bash

# Check if Bats is available in the system PATH
if ! command -v bats &> /dev/null; then
    echo "Error: Bats not found in PATH. Please install Bats or update the PATH."
    exit 1
fi

# Get the script's directory for relative paths
BASE_DIR="$(dirname "$0")"
LOG_FILE="$BASE_DIR/logs/test_log.txt"

mkdir -p "$BASE_DIR/logs"
touch "$LOG_FILE"

# Specify the log file
log_file=$LOG_FILE

# List of test files to run
test_files=(
  "$BASE_DIR/colors_tests.bats"
  "$BASE_DIR/colors_entry_tests.bats"
  # Add more test files as needed
)

print_banner() {
  local text="$1"
  local color="$2"
  echo -e "\033[1;${color}m$text\033[0m"
}

print_banner "==============================" "34"  # Blue color
print_banner "$(date +"[ %Y-%m-%d %H:%M:%S ]") Starting Tests" "33"  # Yellow color
print_banner "==============================" "34"  # Blue color
echo ""

# Run each test file and redirect output to the log file
for test_file in "${test_files[@]}"; do
  bats "$test_file" >> "$log_file" 2>&1
done

print_banner "==============================" "32"  # Green color
print_banner "$(date +"[ %Y-%m-%d %H:%M:%S ]") Ending Tests" "32"  # Green color
print_banner "==============================" "32"  # Green color
echo ""

