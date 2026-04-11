#!/usr/bin/env bash
readonly HISTORY_FILE="${HOME}/.local/state/fzh/.zsh_history_transformed"

temp_file=$(mktemp)
result_file=$(mktemp)

# We'll use an associative array to track commands we've seen
declare -A seen_commands

# Read the file **from bottom to top** so the first time we see a command
# is its most recent occurrence
tac "$HISTORY_FILE" | while IFS= read -r line; do
    if [[ "$line" =~ ^:[[:space:]][0-9]+:[0-9]+\;(.*)$ ]]; then
        command_part="${BASH_REMATCH[1]}"
        if [[ -z "${seen_commands[$command_part]}" ]]; then
            # First time seeing this command, keep it
            echo "$line" >> "$temp_file"
            seen_commands["$command_part"]=1
        fi
        # Otherwise, skip duplicates
    else
        # Lines that don't match expected format are kept
        echo "$line" >> "$temp_file"
    fi
done

# Now reverse temp_file to restore original order
tac "$temp_file" > "$result_file"

# Replace the original file
mv "$result_file" "$HISTORY_FILE"
rm "$temp_file"
