#!/usr/bin/env bash

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Constants
readonly FZH_STATE_DIR="${HOME}/.local/state/fzh"
readonly RAW_HISTORY_SOURCE="${FZH_SOURCE:-${HOME}/.zsh_history}"

# Initialize state directory
init_state_dir() {
    mkdir -p "$FZH_STATE_DIR"
}

# Validate that the history source file exists
# Returns: 0 if valid, 1 if invalid
validate_history_source() {
    local history_source="$1"
    
    if [[ -z "$history_source" ]]; then
        return 1
    fi
    
    if [[ ! -f "$history_source" ]]; then
        return 1
    fi
    
    return 0
}

# Get the stored line count for a history file
# Args: history_source_path
# Returns: previous line count (0 if no record exists)
get_previous_line_count() {
    local history_source="$1"
    local history_filename
    local length_filepath
    
    history_filename=$(basename "$history_source")
    length_filepath="${FZH_STATE_DIR}/${history_filename}_len.txt"
    
    if [[ ! -f "$length_filepath" ]]; then
        echo "0"
        return
    fi
    
    cat "$length_filepath"
}

# Get current line count and update the stored count
# Args: history_source_path
# Returns: current line count
get_and_update_line_count() {
    local history_source="$1"
    local history_filename
    local length_filepath
    local current_count
    
    history_filename=$(basename "$history_source")
    length_filepath="${FZH_STATE_DIR}/${history_filename}_len.txt"
    current_count=$(wc -l < "$history_source")
    
    echo "$current_count" > "$length_filepath"
    echo "$current_count"
}

# Transform the raw history file starting from a specific line
# Args: raw_history_source, starting_line
transform_history_file() {
    local raw_history_source="$1"
    local starting_line="$2"
    local history_filename
    local transformed_filepath
    local script_dir

    history_filename=$(basename "$raw_history_source")
    transformed_filepath="${FZH_STATE_DIR}/${history_filename}_transformed"
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # Runs synchronously
    "${script_dir}/fzh_history_generator.sh" "$raw_history_source" "$transformed_filepath" "$starting_line" >/dev/null 2>&1
    "${script_dir}/clean_history_entries.sh" &
}
show_fzh_menu_old() {
    initial_filter="${*:-}"

    local history_file="$HOME/.local/state/fzh/.zsh_history_transformed"
    local total_lines
    total_lines=$(wc -l <"$history_file")
    HEADER="header placeholder"

    # Remove unused RELOAD variable or use it if needed
    #RELOAD='reload:rg --color=always --smart-case {q} || :'
    # ENTER_EXECUTOR="var='something'
    #                 echo '$var'"
    #T_EXECUTOR="echo 'pressed ctrl-t' && echo '$FZF_ACTION'"
    #B_EXECUTOR="echo '$FZF_PROMPT'"

    CAT_TO_CLIPBOARD='echo {2} > /tmp/fzf_clipboard'
    ECHO_FROM_CLIPBOARD='cat /tmp/fzf_clipboard'
    #FZF_ACTION
    #RELOAD_AWK_CMD="(tac \"$history_file\" 2>/dev/null | awk -F ';' '{ if (\$0 ~ /^:/) { raw_cmd = substr(\$0, index(\$0, \";\") +1); clean_cmd = raw_cmd; gsub(/\\\\\\\\n/, \"\", clean_cmd); gsub(/  +/, \" \", clean_cmd); if (!seen[raw_cmd]++) { print NR \"\\t\" raw_cmd \"\\t\" clean_cmd } } }' | rg --color=always --colors 'match:fg:4' -- \"$initial_filter\") || true"
                #--bind "ctrl-x:execute:printf '%s\n' {+2} > /tmp/fzf_test_output" \
    RELOAD_AWK_CMD="(tac \"$history_file\" 2>/dev/null | awk -F ';' '{ if (\$0 ~ /^:/) { raw_cmd = substr(\$0, index(\$0, \";\") +1); clean_cmd = raw_cmd; gsub(/\\\\n/, \"\", clean_cmd); gsub(/  +/, \" \", clean_cmd); if (!seen[raw_cmd]++) { print NR \"\\t\" raw_cmd \"\\t\" clean_cmd } } }' | rg --color=always --colors 'match:fg:4' -- \"$initial_filter\") || true"
    output=$(
        tac "$history_file" |
            awk -F ';' '{
            if ($0 ~ /^:/) {
            raw_cmd = substr($0, index($0, ";")+1)
            clean_cmd = raw_cmd
            gsub(/\\n/, "", clean_cmd)
            gsub(/  +/, " ", clean_cmd)   # <-- replace 2+ spaces with single space
            if (!seen[raw_cmd]++) {
                print NR "\t" raw_cmd "\t" clean_cmd
            }
        }
    }' | rg --color=always --colors 'match:fg:4' -- "$initial_filter" |
            fzf --ansi --with-nth=3 --delimiter='\t' \
                --multi \
                --header="$HEADER" \
                --bind 'tab:toggle+down' \
                --bind 'ctrl-space:toggle-all' \
                --bind "ctrl-b:execute:echo " \
                --bind 'ctrl-y:execute(env | grep "^FZF_" | sort)' \
                --bind 'enter:execute(nvim +{2} {1})' \
                --bind "ctrl-f:execute:echo {1} {2} {} > /tmp/fzf_test_output" \
                --bind "ctrl-g:execute:echo {1} > /tmp/fzf_test_output" \
                --bind "ctrl-t:execute:echo {2} > /tmp/fzf_test_output" \
                --bind "ctrl-h:execute-silent:bash -c 'echo {2} > /tmp/fzf_clipboard'" \
                --bind "ctrl-q:execute:bash -c 'echo Copied: \$(cat /tmp/fzf_clipboard)'" \
                --bind "ctrl-e:execute:bash -c 'echo Ctrl-B full line: {}'" \
                --bind "ctrl-x:execute-silent(~/.config/fzm/delete_history_entries.sh {+2})+reload($RELOAD_AWK_CMD)+clear-selection" \
                --bind "ctrl-r:execute-silent(~/.config/fzm/clean_history_entries.sh)" \
                --bind "ctrl-u:execute:$CAT_TO_CLIPBOARD" \
                --bind "ctrl-i:execute:$ECHO_FROM_CLIPBOARD" \
                --bind "ctrl-o:reload: echo header 2;" \
                --preview " \
            line_num={1}
            cmd={2}
            clean_line_num=\$(echo \"\$line_num\" | sed 's/[^0-9]//g')
            # Calculate the correct line number in the original file
            original_line_num=\$((${total_lines} - \$clean_line_num + 1))
            raw_line=\$(sed -n \"\${original_line_num}p\" \"${history_file}\" 2>>/tmp/fzh_debug.log || echo \"\")
            if [[ \$raw_line =~ ^:\ ([0-9]+):([0-9]+)\;(.*)\$ ]]; then
                timestamp=\"\${match[1]}\"
                duration=\"\${match[2]}\"
                if command -v date >/dev/null 2>&1; then
                    human_time=\$(date -d \"@\$timestamp\" 2>>/tmp/fzh_debug.log || date -r \"\$timestamp\" 2>>/tmp/fzh_debug.log || echo \"Unknown\")
                else
                    human_time=\"Timestamp: \$timestamp\"
                fi
                echo -e \"\033[1;36m=== Command Metadata ===\033[0m\"
                echo -e \"\033[1;33mTimestamp:\033[0m \$human_time\"
                echo -e \"\033[1;33mHistory Line:\033[0m \$original_line_num\"
                echo -e \"\033[1;36m========================\033[0m\"
            else
                echo \"DEBUG: Regex did not match\" >> /tmp/fzh_debug.log
                echo -e \"\033[1;36m=== Command Info ===\033[0m\"
                echo -e \"\033[1;33mHistory Line:\033[0m \$original_line_num\"
                echo -e \"\033[1;33mNo metadata available\033[0m\"
                echo -e \"\033[1;36m===================\033[0m\"
            fi
            echo -e \"\$cmd\" | sed 's/\\\\n/\\\\\\n/g' | batcat --color=always --language=bash --style=plain" |
            cut -f2 | sed 's/ *$//'
    )
    #echo "$PATH"
}

show_fzh_menu_older() {
    initial_filter="${*:-}"

    local history_file="$HOME/.local/state/fzh/.zsh_history_transformed"
    local favorites_file="$HOME/.local/state/fzh/history_favourited"
    local total_lines
    total_lines=$(wc -l <"$history_file")
    HEADER="header placeholder | Ctrl-F: Toggle Favorite"

    # Create favorites file if it doesn't exist
    mkdir -p "$(dirname "$favorites_file")"
    touch "$favorites_file"

    CAT_TO_CLIPBOARD='echo {2} > /tmp/fzf_clipboard'
    ECHO_FROM_CLIPBOARD='cat /tmp/fzf_clipboard'

    # Script to toggle favorite status
    TOGGLE_FAVORITE="bash -c '
        cmd=\"\$1\"
        fav_file=\"$favorites_file\"
        if grep -Fxq \"\$cmd\" \"\$fav_file\" 2>/dev/null; then
            # Remove from favorites
            grep -Fxv \"\$cmd\" \"\$fav_file\" > \"\${fav_file}.tmp\" || touch \"\${fav_file}.tmp\"
            mv \"\${fav_file}.tmp\" \"\$fav_file\"
            echo \"Removed from favorites\"
        else
            # Add to favorites
            echo \"\$cmd\" >> \"\$fav_file\"
            echo \"Added to favorites\"
        fi
    ' _ {2}"
    RELOAD_AWK_CMD="(tac \"$history_file\" 2>/dev/null | awk -F ';' -v fav_file=\"$favorites_file\" '
    BEGIN {
        while ((getline line < fav_file) > 0) {
            favorites[line] = 1
        }
        close(fav_file)
    }
    {
        if (\$0 ~ /^:/) {
            raw_cmd = substr(\$0, index(\$0, \";\") +1)
            clean_cmd = raw_cmd
            gsub(/\\\\n/, \"\", clean_cmd)
            gsub(/  +/, \" \", clean_cmd)
            if (!seen[raw_cmd]++) {
                # Mark favorites with ★ prefix
                if (raw_cmd in favorites) {
                    print NR \"\\t\" raw_cmd \"\\t[ FAV ] \" clean_cmd
                } else {
                    print NR \"\\t\" raw_cmd \"\\t\" clean_cmd
                }
            }
        }
    }' | rg --color=always --colors 'match:fg:4' -- \"$initial_filter\") || true"

    output=$(
        tac "$history_file" |
            awk -F ';' -v fav_file="$favorites_file" '
            BEGIN {
                # Load favorites into an array
                while ((getline line < fav_file) > 0) {
                    favorites[line] = 1
                }
                close(fav_file)
            }
            {
                if ($0 ~ /^:/) {
                    raw_cmd = substr($0, index($0, ";")+1)
                    clean_cmd = raw_cmd
                    gsub(/\\n/, "", clean_cmd)
                    gsub(/  +/, " ", clean_cmd)
                    if (!seen[raw_cmd]++) {
                        # Mark favorites with ★ prefix
                        if (raw_cmd in favorites) {
                            print NR "\t" raw_cmd "\t[ FAV ] " clean_cmd
                        } else {
                            print NR "\t" raw_cmd "\t" clean_cmd
                        }
                    }
                }
            }' | rg --color=always --colors 'match:fg:4' -- "$initial_filter" |
            fzf --ansi --with-nth=3 --delimiter='\t' \
                --multi \
                --header="$HEADER" \
                --bind 'tab:toggle+down' \
                --bind 'ctrl-space:toggle-all' \
                --bind "ctrl-b:execute:echo " \
                --bind 'ctrl-y:execute(env | grep "^FZF_" | sort)' \
                --bind 'enter:execute(nvim +{2} {1})' \
                --bind "ctrl-f:execute($TOGGLE_FAVORITE)+reload($RELOAD_AWK_CMD)" \
                --bind "ctrl-g:execute:echo {1} > /tmp/fzf_test_output" \
                --bind "ctrl-t:execute:echo {2} > /tmp/fzf_test_output" \
                --bind "ctrl-h:execute-silent:bash -c 'echo {2} > /tmp/fzf_clipboard'" \
                --bind "ctrl-q:execute:bash -c 'echo Copied: \$(cat /tmp/fzf_clipboard)'" \
                --bind "ctrl-e:execute:bash -c 'echo Ctrl-B full line: {}'" \
                --bind "ctrl-x:execute-silent(~/.config/fzm/delete_history_entries.sh {+2})+reload($RELOAD_AWK_CMD)+clear-selection" \
                --bind "ctrl-r:execute-silent(~/.config/fzm/clean_history_entries.sh)" \
                --bind "ctrl-u:execute:$CAT_TO_CLIPBOARD" \
                --bind "ctrl-i:execute:$ECHO_FROM_CLIPBOARD" \
                --bind "ctrl-o:reload: echo header 2;" \
                --preview " \
            line_num={1}
            cmd={2}
            fav_file=\"$favorites_file\"
            is_fav=\$(grep -Fxq \"\$cmd\" \"\$fav_file\" 2>/dev/null && echo \"yes\" || echo \"no\")
            clean_line_num=\$(echo \"\$line_num\" | sed 's/[^0-9]//g')
            # Calculate the correct line number in the original file
            original_line_num=\$((${total_lines} - \$clean_line_num + 1))
            raw_line=\$(sed -n \"\${original_line_num}p\" \"${history_file}\" 2>>/tmp/fzh_debug.log || echo \"\")
            if [[ \$raw_line =~ ^:\ ([0-9]+):([0-9]+)\;(.*)\$ ]]; then
                timestamp=\"\${match[1]}\"
                duration=\"\${match[2]}\"
                if command -v date >/dev/null 2>&1; then
                    human_time=\$(date -d \"@\$timestamp\" 2>>/tmp/fzh_debug.log || date -r \"\$timestamp\" 2>>/tmp/fzh_debug.log || echo \"Unknown\")
                else
                    human_time=\"Timestamp: \$timestamp\"
                fi
                echo -e \"\033[1;36m=== Command Metadata ===\033[0m\"
                echo -e \"\033[1;33mTimestamp:\033[0m \$human_time\"
                echo -e \"\033[1;33mHistory Line:\033[0m \$original_line_num\"
                if [[ \$is_fav == \"yes\" ]]; then
                    echo -e \"\033[1;35mFavorite:\033[0m ★ Yes\"
                fi
                echo -e \"\033[1;36m========================\033[0m\"
            else
                echo \"DEBUG: Regex did not match\" >> /tmp/fzh_debug.log
                echo -e \"\033[1;36m=== Command Info ===\033[0m\"
                echo -e \"\033[1;33mHistory Line:\033[0m \$original_line_num\"
                if [[ \$is_fav == \"yes\" ]]; then
                    echo -e \"\033[1;35mFavorite:\033[0m ★ Yes\"
                fi
                echo -e \"\033[1;33mNo metadata available\033[0m\"
                echo -e \"\033[1;36m===================\033[0m\"
            fi
            echo -e \"\$cmd\" | sed 's/\\\\n/\\\\\\n/g' | batcat --color=always --language=bash --style=plain" |
            cut -f2 | sed 's/ *$//'
    )
}
show_fzh_menu() {
    initial_filter="${*:-}"

    local history_file="$HOME/.local/state/fzh/.zsh_history_transformed"
    local favorites_file="$HOME/.local/state/fzh/history_favourited"
    local total_lines
    total_lines=$(wc -l <"$history_file")
    HEADER="header placeholder | Ctrl-F: Toggle Favorite"

    # Create favorites file if it doesn't exist
    mkdir -p "$(dirname "$favorites_file")"
    touch "$favorites_file"

    CAT_TO_CLIPBOARD='echo {2} > /tmp/fzf_clipboard'
    ECHO_FROM_CLIPBOARD='cat /tmp/fzf_clipboard'

    # Script to toggle favorite status
    TOGGLE_FAVORITE="bash -c '
        cmd=\"\$1\"
        fav_file=\"$favorites_file\"
        if grep -Fxq \"\$cmd\" \"\$fav_file\" 2>/dev/null; then
            # Remove from favorites
            grep -Fxv \"\$cmd\" \"\$fav_file\" > \"\${fav_file}.tmp\" || touch \"\${fav_file}.tmp\"
            mv \"\${fav_file}.tmp\" \"\$fav_file\"
            echo \"Removed from favorites\"
        else
            # Add to favorites
            echo \"\$cmd\" >> \"\$fav_file\"
            echo \"Added to favorites\"
        fi
    ' _ {2}"
    
    RELOAD_AWK_CMD="(tac \"$history_file\" 2>/dev/null | awk -F ';' -v fav_file=\"$favorites_file\" '
    BEGIN {
        while ((getline line < fav_file) > 0) {
            favorites[line] = 1
        }
        close(fav_file)
        fav_count = 0
        reg_count = 0
    }
    {
        if (\$0 ~ /^:/) {
            raw_cmd = substr(\$0, index(\$0, \";\") +1)
            clean_cmd = raw_cmd
            gsub(/\\\\n/, \"\", clean_cmd)
            gsub(/  +/, \" \", clean_cmd)
            if (!seen[raw_cmd]++) {
                # Store favorites and regulars separately
                if (raw_cmd in favorites) {
                    fav_lines[fav_count++] = NR \"\\t\" raw_cmd \"\\t \" clean_cmd
                } else {
                    reg_lines[reg_count++] = NR \"\\t\" raw_cmd \"\\t\" clean_cmd
                }
            }
        }
    }
    END {
        # Output favorites at the top
        for (i = 0; i < fav_count; i++) {
            print fav_lines[i]
        }
        # Then output regular commands
        for (i = 0; i < reg_count; i++) {
            print reg_lines[i]
        }
    }' | rg --color=always --colors 'match:fg:4' -- \"$initial_filter\") || true"

    output=$(
        tac "$history_file" |
            awk -F ';' -v fav_file="$favorites_file" '
            BEGIN {
                # Load favorites into an array
                while ((getline line < fav_file) > 0) {
                    favorites[line] = 1
                }
                close(fav_file)
                fav_count = 0
                reg_count = 0
            }
            {
                if ($0 ~ /^:/) {
                    raw_cmd = substr($0, index($0, ";")+1)
                    clean_cmd = raw_cmd
                    gsub(/\\n/, "", clean_cmd)
                    gsub(/  +/, " ", clean_cmd)
                    if (!seen[raw_cmd]++) {
                        # Store favorites and regulars separately
                        if (raw_cmd in favorites) {
                            fav_lines[fav_count++] = NR "\t" raw_cmd "\t " clean_cmd
                        } else {
                            reg_lines[reg_count++] = NR "\t" raw_cmd "\t" clean_cmd
                        }
                    }
                }
            }
            END {
                # Output favorites at the top
                for (i = 0; i < fav_count; i++) {
                    print fav_lines[i]
                }
                # Then output regular commands
                for (i = 0; i < reg_count; i++) {
                    print reg_lines[i]
                }
            }' | rg --color=always --colors 'match:fg:4' -- "$initial_filter" |
            fzf --ansi --with-nth=3 --delimiter='\t' \
                --multi \
                --header="$HEADER" \
                --bind 'tab:toggle+down' \
                --bind 'ctrl-space:toggle-all' \
                --bind "ctrl-b:execute:echo " \
                --bind 'ctrl-y:execute(env | grep "^FZF_" | sort)' \
                --bind 'enter:execute(nvim +{2} {1})' \
                --bind "ctrl-f:execute($TOGGLE_FAVORITE)+reload($RELOAD_AWK_CMD)" \
                --bind "ctrl-g:execute:echo {1} > /tmp/fzf_test_output" \
                --bind "ctrl-t:execute:echo {2} > /tmp/fzf_test_output" \
                --bind "ctrl-h:execute-silent:bash -c 'echo {2} > /tmp/fzf_clipboard'" \
                --bind "ctrl-q:execute:bash -c 'echo Copied: \$(cat /tmp/fzf_clipboard)'" \
                --bind "ctrl-e:execute:bash -c 'echo Ctrl-B full line: {}'" \
                --bind "ctrl-x:execute-silent(~/.config/fzm/delete_history_entries.sh {+2})+reload($RELOAD_AWK_CMD)+clear-selection" \
                --bind "ctrl-r:execute-silent(~/.config/fzm/clean_history_entries.sh)" \
                --bind "ctrl-u:execute:$CAT_TO_CLIPBOARD" \
                --bind "ctrl-i:execute:$ECHO_FROM_CLIPBOARD" \
                --bind "ctrl-o:reload: echo header 2;" \
                --preview " \
            line_num={1}
            cmd={2}
            fav_file=\"$favorites_file\"
            is_fav=\$(grep -Fxq \"\$cmd\" \"\$fav_file\" 2>/dev/null && echo \"yes\" || echo \"no\")
            clean_line_num=\$(echo \"\$line_num\" | sed 's/[^0-9]//g')
            # Calculate the correct line number in the original file
            original_line_num=\$((${total_lines} - \$clean_line_num + 1))
            raw_line=\$(sed -n \"\${original_line_num}p\" \"${history_file}\" 2>>/tmp/fzh_debug.log || echo \"\")
            if [[ \$raw_line =~ ^:\ ([0-9]+):([0-9]+)\;(.*)\$ ]]; then
                timestamp=\"\${match[1]}\"
                duration=\"\${match[2]}\"
                if command -v date >/dev/null 2>&1; then
                    human_time=\$(date -d \"@\$timestamp\" 2>>/tmp/fzh_debug.log || date -r \"\$timestamp\" 2>>/tmp/fzh_debug.log || echo \"Unknown\")
                else
                    human_time=\"Timestamp: \$timestamp\"
                fi
                echo -e \"\033[1;36m=== Command Metadata ===\033[0m\"
                echo -e \"\033[1;33mTimestamp:\033[0m \$human_time\"
                echo -e \"\033[1;33mHistory Line:\033[0m \$original_line_num\"
                if [[ \$is_fav == \"yes\" ]]; then
                    echo -e \"\033[1;35mFavorite:\033[0m ★ Yes\"
                fi
                echo -e \"\033[1;36m========================\033[0m\"
            else
                echo \"DEBUG: Regex did not match\" >> /tmp/fzh_debug.log
                echo -e \"\033[1;36m=== Command Info ===\033[0m\"
                echo -e \"\033[1;33mHistory Line:\033[0m \$original_line_num\"
                if [[ \$is_fav == \"yes\" ]]; then
                    echo -e \"\033[1;35mFavorite:\033[0m ★ Yes\"
                fi
                echo -e \"\033[1;33mNo metadata available\033[0m\"
                echo -e \"\033[1;36m===================\033[0m\"
            fi
            echo -e \"\$cmd\" | sed 's/\\\\n/\\\\\\n/g' | batcat --color=always --language=bash --style=plain" |
            cut -f2 | sed 's/ *$//'
    )
}
main() {
    local initial_filter="${*}"
    local previous_count
    local current_count
    local starting_line
    local history_filename
    local transformed_filepath
    
    # Initialize
    init_state_dir
    
    # Validate source
    if ! validate_history_source "$RAW_HISTORY_SOURCE"; then
        exit 0
    fi
    
    # Get line counts
    previous_count=$(get_previous_line_count "$RAW_HISTORY_SOURCE")
    current_count=$(get_and_update_line_count "$RAW_HISTORY_SOURCE")
    
    # Calculate starting line for transformation
    starting_line=$((previous_count + 1))
    
    # Transform history file
    transform_history_file "$RAW_HISTORY_SOURCE" "$starting_line"
    
    # Prepare transformed file path
    history_filename=$(basename "$RAW_HISTORY_SOURCE")
    transformed_filepath="${FZH_STATE_DIR}/${history_filename}_transformed"
    
    # Show menu
    show_fzh_menu "$initial_filter"
}

main "$@"
