#!/usr/bin/env bash
readonly HISTORY_FILE="${HOME}/.local/state/fzh/.zsh_history_transformed"
readonly FAVOURITES_FILE="${HOME}/.local/state/fzh/history_favourited"

# Load favorites into associative array for O(1) lookup
declare -A favorites
if [[ -f "$FAVOURITES_FILE" ]]; then
    while IFS= read -r fav; do
        favorites["$fav"]=1
    done < "$FAVOURITES_FILE"
fi

# Load commands to delete into associative array for O(1) lookup
declare -A to_delete
for cmd in "$@"; do
    to_delete["$cmd"]=1
done

# Track which commands we've already found and deleted
declare -A deleted

# Process history file in one pass, writing directly to temp file
temp_file=$(mktemp)

while IFS= read -r line; do
    # Extract the command part (everything after the first semicolon)
    if [[ "$line" =~ ^:[[:space:]][0-9]+:[0-9]+\;(.*)$ ]]; then
        command_part="${BASH_REMATCH[1]}"
        
        # Keep if favorited (favorites override delete)
        if [[ -n "${favorites[$command_part]}" ]]; then
            echo "$line"
        # Check if this command should be deleted
        elif [[ -n "${to_delete[$command_part]}" ]]; then
            # Only delete if we haven't already deleted this command
            if [[ -z "${deleted[$command_part]}" ]]; then
                deleted["$command_part"]=1
                # Skip this line (don't echo it)
                continue
            else
                # We already deleted one instance, keep this one
                echo "$line"
            fi
        else
            # Not in delete list, keep it
            echo "$line"
        fi
    else
        # Keep lines that don't match the expected format
        echo "$line"
    fi
done < "$HISTORY_FILE" > "$temp_file"

# Replace original file with filtered results
mv "$temp_file" "$HISTORY_FILE"
