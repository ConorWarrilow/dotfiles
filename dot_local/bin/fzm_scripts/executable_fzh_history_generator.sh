#!/usr/bin/env bash

# ZSH History Prettifier
#
# This script processes a .zsh_history file and creates a prettified version where:
# - Backslash line continuations are converted to \n
# - Tab characters are converted to \t
# - Each command is on a single line
# - Can start processing from a specific line number
# - Appends to output file instead of overwriting

#set -euo pipefail
set -ux
#echo "made it in the file"
# Function to display usage
usage() {
    echo "Usage: $0 <input_file> [output_file] [start_line]"
    echo "  input_file:  Input .zsh_history file"
    echo "  output_file: Output file (default: input_file.pretty)"
    echo "  start_line:  Line number to start processing from (default: 1)"
    echo ""
    echo "Note: Output will be appended to the output file (using >>)"
    exit 1
}

# Function to process a command string
process_command() {
    local command="$1"
    local result=""
    local line
    local processed_lines=()
    local i=0

    # Read command into array, splitting on actual newlines
    while IFS= read -r line || [[ -n "$line" ]]; do
        processed_lines+=("$line")
    done <<<"$command"

    # Process each line
    for ((i = 0; i < ${#processed_lines[@]}; i++)); do
        line="${processed_lines[i]}"

        if [[ $i -eq 0 ]]; then
            # First line - check if it ends with backslash continuation
            if [[ "$line" =~ \\\\$ ]]; then
                # Double backslash at end - this is one backslash + continuation
                result+="${line%\\\\}\\"
            elif [[ "$line" =~ \\$ ]]; then
                # Single backslash at end - this is just continuation
                result+="${line%\\}"
            else
                result+="$line"
            fi
        else
            # Continuation line - add \n to represent the line break
            if [[ "$line" =~ \\\\$ ]]; then
                # Double backslash at end - this is one backslash + continuation
                result+="\\n${line%\\\\}\\"
            elif [[ "$line" =~ \\$ ]]; then
                # Single backslash at end - this is just continuation
                result+="\\n${line%\\}"
            else
                # No continuation backslash
                result+="\\n$line"
            fi
        fi
    done

    echo "$result"
}

# Main processing function
process_zsh_history() {
    local input_file="$1"
    local output_file="$2"
    local start_line="$3"
    local temp_file
    temp_file=$(mktemp)

    # Check if input file exists
    if [[ ! -f "$input_file" ]]; then
        echo "Error: File '$input_file' not found." >&2
        return 1
    fi

    # Validate start_line
    if ! [[ "$start_line" =~ ^[0-9]+$ ]] || [[ "$start_line" -lt 0 ]]; then
        echo "Error: start_line must be a positive integer." >&2
        return 1
    fi

    # Process the file starting from the specified line
    local line
    local line_number=0
    local in_command=false
    local current_prefix=""
    local current_command=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_number++))

        # Skip lines before start_line
        if [[ $line_number -lt $start_line ]]; then
            continue
        fi

        # Check if this is a history entry (starts with : timestamp:exit_code;)
        if [[ "$line" =~ ^:\ [0-9]+:[0-9]+\; ]]; then
            # If we were processing a previous command, finish it
            if [[ "$in_command" == true ]]; then
                local processed_command
                processed_command=$(process_command "$current_command")
                # Replace tabs with \t
                processed_command="${processed_command//$'\t'/\\t}"
                processed_command="$(echo "$processed_command" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
                echo "$current_prefix$processed_command" >>"$temp_file"
            fi

            # Start new command
            in_command=true
            # Extract prefix and command
            current_prefix=$(echo "$line" | grep -o '^: [0-9]*:[0-9]*;')
            current_command="${line#$current_prefix}"
        else
            # This is a continuation line
            if [[ "$in_command" == true ]]; then
                if [[ -n "$current_command" ]]; then
                    current_command+=$'\n'"$line"
                else
                    current_command="$line"
                fi
            else
                # Non-history line, keep as is (shouldn't happen in proper zsh_history)
                echo "$line" >>"$temp_file"
            fi
        fi
    done <"$input_file"

    # Process the last command if we were in one
    if [[ "$in_command" == true ]]; then
        local processed_command
        processed_command=$(process_command "$current_command")
        # Replace tabs with \t
        processed_command="${processed_command//$'\t'/\\t}"
        processed_command="$(echo "$processed_command" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        echo "$current_prefix$processed_command" >>"$temp_file"
    fi

    # Append temp file contents to output file
    if cat "$temp_file" >>"$output_file"; then
        #echo "Successfully processed $input_file (starting from line $start_line) -> $output_file (appended)"
        rm -f "$temp_file"
        return 0
    else
        echo "Error writing to file '$output_file'" >&2
        rm -f "$temp_file"
        return 1
    fi
}

# Main script
main() {
    # Check arguments
    if [[ $# -lt 1 ]] || [[ $# -gt 3 ]]; then
        usage
    fi
    #    echo "main of pretty"

    local input_file="$1"
    local output_file="${2:-${input_file}.pretty}"
    local start_line="${3:-1}"

    if process_zsh_history "$input_file" "$output_file" "$start_line"; then
        #        echo "exiting 0"
        exit 0
    else
        #        echo "exiting 1"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
