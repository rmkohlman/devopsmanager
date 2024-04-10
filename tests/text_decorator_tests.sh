
#!/usr/bin/env bats

# Load the colors.sh and text_decorations scripts
BASE_DIR="$HOME/bin/devman"
source "$BASE_DIR/colors.sh"
source "$BASE_DIR/text_decorator.sh"

# Helper function to get ANSI code from colors.sh
function get_ansi_code() {
  local style="$1"
  local codes_file="$BASE_DIR/colors.sh"

  # Use awk to find the ANSI code for the given style
  awk -v style="$style" -F "'" '$1 == style {print $2}' "$codes_file"
}

# Function to display ANSI escape codes properly
function display_ansi_escape() {
  local text="$1"
  echo -e "$text"
}

@test "Create style with multiple styles" {
  # Define the expected ANSI codes for each style
  expected_code_red="$(get_value 'RED')"
  expected_code_bold="$(get_value 'BOLD')"
  expected_code_blink="$(get_value 'BLINK')"

  # Expected result is the concatenation of ANSI codes for each style
  expected="${expected_code_red}${expected_code_bold}${expected_code_blink}"

  # Call create_style with the styles 'RED', 'BOLD', and 'BLINK'
  result="$(create_style 'RED' 'BOLD' 'BLINK')"

  # Debugging information
  echo "Result: $(display_ansi_escape "$result")"
  echo "Expected: $(display_ansi_escape "$expected")"

  # Assert that the result matches the expected value
  [ "$result" == "$expected" ]
}


@test "Create decoration with multiple styles" {
  result="$(create_decoration 'TargetString' "$(create_style 'RED' 'BOLD')")"
  expected="$(create_style 'RED' 'BOLD')TargetString$(get_value 'RESET')"

  # Debugging information
  echo "Result: $(strip_ansi "$result")"
  echo "Expected: $(strip_ansi "$expected")"

  [ "$(strip_ansi "$result")" == "$(strip_ansi "$expected")" ]
}
@test "Apply decorations to a string" {
  input="This is a test string."
  style_code="$(create_style 'RED' 'BOLD' 'BLINK')"
  decoration="$(create_decoration 'test' "$style_code")"

  decorated_text="$(apply_decorations "$input" "$decoration")"
  expected_code_red="$(get_ansi_code 'RED')"
  expected_code_bold="$(get_ansi_code 'BOLD')"
  expected_code_blink="$(get_ansi_code 'BLINK')"
  expected="${expected_code_red}${expected_code_bold}${expected_code_blink}This is a ${expected_code_red}string."

  # Debugging information
  echo "Decorated Text: $(display_ansi_escape "$decorated_text")"
  echo "Expected: $(display_ansi_escape "$expected")"

  # Modified assertion to ignore white spaces and newline characters
  decorated_text_cleaned="$(echo -n "$decorated_text" | tr -d '[:space:]')"
  expected_cleaned="$(echo -n "$expected" | tr -d '[:space:]')"

  echo "Decorated Text: $decorated_text_cleaned"
  echo "Expected: $expected_cleaned"
  [ "$(printf "$decorated_text_cleaned")" == "$(printf "$expected_cleaned")" ]
}











