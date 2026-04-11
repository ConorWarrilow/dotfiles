# INFO: Fuzzy cd
fcd() {
    local dir
    cd && dir=$(find . -type d 2>/dev/null | fzf --height=40%) && cd "$dir"
}
#
# # INFO: Fuzzy File
# ff() {
#     local orig_dir="$PWD"
#     local file
#     cd ~ &&
#     file=$(fzf --height=40% --preview='batcat --style=numbers --color=always --line-range :500 {}' --preview-window=right:60%) &&
#     "${EDITOR:-nvim}" "$file"
#     cd "$orig_dir"
# }
#
# INFO: Fuzzy File
ffr() {
    local orig_dir="$PWD"
    local file
    file=$(fzf --height=40% --preview='batcat --style=numbers --color=always --line-range :500 {}' --preview-window=right:60%) &&
    "${EDITOR:-nvim}" "$file"
    cd "$orig_dir"
}

fzh_bato6d() {
    local history_file="${1:-$HOME/.zsh_history}"
    tac "$history_file" |
    awk -F ';' '{
        if ($0 ~ /^:/) {
            cmd=substr($0, index($0, ";")+1)
            if (!seen[cmd]++) {
                print NR "\t" cmd
            }
        }
    }' |
    fzf --ansi --with-nth=2 --delimiter='\t' \
        --preview '
            line_num={1}
            cmd={2}
            clean_line_num=$(echo "$line_num" | sed "s/[^0-9]//g")
            raw_line=$(sed -n "${clean_line_num}p" '"$history_file"' 2>>/tmp/fzh_debug.log || echo "")
            if [[ $raw_line =~ "^: ([0-9]+):([0-9]+);(.*)$" ]]; then
                timestamp="${match[1]}"
                duration="${match[2]}"
                if command -v date >/dev/null 2>&1; then
                    human_time=$(date -d "@$timestamp" 2>>/tmp/fzh_debug.log || date -r "$timestamp" 2>>/tmp/fzh_debug.log || echo "Unknown")
                else
                    human_time="Timestamp: $timestamp"
                fi
                echo -e "\033[1;36m=== Command Metadata ===\033[0m"
                echo -e "\033[1;33mTimestamp:\033[0m $human_time"
                echo -e "\033[1;33mDuration:\033[0m ${duration}s"
                echo -e "\033[1;33mHistory Line:\033[0m $clean_line_num"
                echo -e "\033[1;36m========================\033[0m"
            else
                echo "DEBUG: Regex did not match" >> /tmp/fzh_debug.log
                echo -e "\033[1;36m=== Command Info ===\033[0m"
                echo -e "\033[1;33mHistory Line:\033[0m $clean_line_num"
                echo -e "\033[1;33mNo metadata available\033[0m"
                echo -e "\033[1;36m===================\033[0m"
            fi
    echo -e "$cmd" | sed "s/\\\\n/\n/g" | batcat --color=always --language=bash --style=plain' |
    cut -f2 | sed 's/ *$//'
}

fzh_bato6e() {
    local history_file="${1:-$HOME/.zsh_history}"
    local total_lines=$(wc -l <"$history_file")
    tac "$history_file" |
    awk -F ';' '{
        if ($0 ~ /^:/) {
            cmd=substr($0, index($0, ";")+1)
            if (!seen[cmd]++) {
                print NR "\t" cmd
            }
        }
    }' |
    fzf --ansi --with-nth=2 --delimiter='\t' \
        --preview '
            line_num={1}
            cmd={2}
            clean_line_num=$(echo "$line_num" | sed "s/[^0-9]//g")
            # Calculate the correct line number in the original file
            original_line_num=$(('"$total_lines"' - clean_line_num + 1))
            raw_line=$(sed -n "${original_line_num}p" '"$history_file"' 2>>/tmp/fzh_debug.log || echo "")
            if [[ $raw_line =~ "^: ([0-9]+):([0-9]+);(.*)$" ]]; then
                timestamp="${match[1]}"
                duration="${match[2]}"
                if command -v date >/dev/null 2>&1; then
                    human_time=$(date -d "@$timestamp" 2>>/tmp/fzh_debug.log || date -r "$timestamp" 2>>/tmp/fzh_debug.log || echo "Unknown")
                else
                    human_time="Timestamp: $timestamp"
                fi
                echo -e "\033[1;36m=== Command Metadata === === === === === === === === === === === === === === \033[0m"
                echo -e "\033[1;33mTimestamp:\033[0m $human_time"
                echo -e "\033[1;33mHistory Line:\033[0m $original_line_num"
                echo -e "\033[1;36m=== === === === === === === === === === === === === === === === === === === === 033[0m"
            else
                echo "DEBUG: Regex did not match" >> /tmp/fzh_debug.log
                echo -e "\033[1;36m=== Command Info ===\033[0m"
                echo -e "\033[1;33mHistory Line:\033[0m $original_line_num"
                echo -e "\033[1;33mNo metadata available\033[0m"
                echo -e "\033[1;36m===================\033[0m"
            fi

    echo -e "$cmd" | sed "s/\\\\n/\\\\\n/g" | batcat --color=always --language=bash --style=plain' |
    cut -f2 | sed 's/ *$//'
}

fzh_bato6ef() {
    local history_file="${1:-$HOME/.zsh_history}"
    local total_lines=$(wc -l <"$history_file")
    tac "$history_file" |
    awk -F ';' '{
        if ($0 ~ /^:/) {
            cmd=substr($0, index($0, ";")+1)
            if (!seen[cmd]++) {
                print NR "\t" cmd
            }
        }
    }' |
    fzf-tmux -p 80%,75% --ansi --with-nth=2 --delimiter='\t' \
        --preview '
            line_num={1}
            cmd={2}
            clean_line_num=$(echo "$line_num" | sed "s/[^0-9]//g")
            # Calculate the correct line number in the original file
            original_line_num=$(('"$total_lines"' - clean_line_num + 1))
            raw_line=$(sed -n "${original_line_num}p" '"$history_file"' 2>>/tmp/fzh_debug.log || echo "")
            if [[ $raw_line =~ "^: ([0-9]+):([0-9]+);(.*)$" ]]; then
                timestamp="${match[1]}"
                duration="${match[2]}"
                if command -v date >/dev/null 2>&1; then
                    human_time=$(date -d "@$timestamp" 2>>/tmp/fzh_debug.log || date -r "$timestamp" 2>>/tmp/fzh_debug.log || echo "Unknown")
                else
                    human_time="Timestamp: $timestamp"
                fi
                echo -e "\033[1;36m=== Command Metadata ===\033[0m"
                echo -e "\033[1;33mTimestamp:\033[0m $human_time"
                echo -e "\033[1;33mDuration:\033[0m ${duration}s"
                echo -e "\033[1;33mHistory Line:\033[0m $original_line_num"
                echo -e "\033[1;36m========================\033[0m"
            else
                echo "DEBUG: Regex did not match" >> /tmp/fzh_debug.log
                echo -e "\033[1;36m=== Command Info ===\033[0m"
                echo -e "\033[1;33mHistory Line:\033[0m $original_line_num"
                echo -e "\033[1;33mNo metadata available\033[0m"
                echo -e "\033[1;36m===================\033[0m"
            fi
    echo -e "$cmd" | sed "s/\\\\n/\\\\\n/g" | batcat --color=always --language=bash --style=plain' |
    cut -f2 | sed 's/ *$//'
}

lines() {

    input_file="${1:-.zsh_history}"
    output_file="$HOME/.local/state/fzh/n_file_lines.txt"

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: File '$input_file' does not exist"
    else
        mkdir -p "$(dirname "$output_file")"
        line_count=$(wc -l <"$input_file")
        echo "$line_count" >"$output_file"
        echo "File '$input_file' has $line_count lines"
        echo "Count saved to '$output_file'"
    fi
}

# INFO: Fuzzy Kill
fkill() {
    ps -ef | sed 1d | fzf --preview 'echo {}' --height=40% | awk '{print $2}' | xargs -r kill -9
}

# INFO: Fuzzy Branch Switch
fbr() {
    git switch "$(git branch | sed 's/^[* ] //' | fzf)"
}
#
# comment out temporarily while developing fzm
# fzg() {
#
#     orig_dir="$PWD"
#     local initial_filter="${1:-}"
#
#     local HEADER="ctrl-d=dots  ctrl-t=text  ctrl-d=dirs"
#
#     #cd ~
#
#     fzf --phony \
    #         --prompt='Search: ' \
    #         --ansi \
    #         --delimiter ':' \
    #         --preview '
#         FILE={1}
#         LINE={2}
#         START=$(( LINE > 20 ? LINE - 10 : 1 ))
#         END=$(( LINE + 10 ))
#         [[ -n "$FILE" && -n "$LINE" ]] && \
    #         batcat --style=numbers --color=always --highlight-line="$LINE" --line-range=$START:$END "$FILE" || echo "No match."
#     ' \
    #         --bind "change:reload:sleep 0.1; rg --hidden --color=always --no-heading --line-number --ignore-case {q} || true" \
    #         --bind 'enter:execute(nvim +{2} {1})' \
    #         --bind "ctrl-d:reload:rg --color=always --no-heading --line-number --ignore-case {q} || true" \
    #         --header="$HEADER" \
    #         --height=100% \
    #         --preview-window=top:60% \
    #         --query="$initial_filter" \
    #         --disabled \
    #         --bind "start:reload:rg --hidden --color=always --no-heading --line-number --ignore-case '$initial_filter' || true"
#
#     #cd "$orig_dir"
#
# }
#
fzgt() {

    orig_dir="$PWD"
    local initial_filter="${1:-}"

    local HEADER="ctrl-d=dots  ctrl-t=text  ctrl-d=dirs"

    #cd ~

    fzf-tmux -p --phony \
        --prompt='Search: ' \
        --ansi \
        --delimiter ':' \
        --preview '
        FILE={1}
        LINE={2}
        START=$(( LINE > 20 ? LINE - 10 : 1 ))
        END=$(( LINE + 10 ))
        [[ -n "$FILE" && -n "$LINE" ]] && \
        batcat --style=numbers --color=always --highlight-line="$LINE" --line-range=$START:$END "$FILE" || echo "No match."
    ' \
        --bind "change:reload:sleep 0.1; rg --hidden --color=always --no-heading --line-number --ignore-case {q} || true" \
        --bind 'enter:execute(nvim +{2} {1})' \
        --bind "ctrl-d:reload:rg --color=always --no-heading --line-number --ignore-case {q} || true" \
        --header="$HEADER" \
        --height=100% \
        --preview-window=top:60% \
        --query="$initial_filter" \
        --disabled \
        --bind "start:reload:rg --hidden --color=always --no-heading --line-number --ignore-case '$initial_filter' || true"

    #cd "$orig_dir"

}

fzgc() {

    orig_dir="$PWD"
    local initial_filter="${1:-}"

    local HEADER="ctrl-d=dots  ctrl-t=text  ctrl-d=dirs"

    cd ~

    fzf --phony \
        --prompt='hiddens' \
        --ansi \
        --delimiter ':' \
        --preview '
        FILE={1}
        LINE={2}
        START=$(( LINE > 20 ? LINE - 10 : 1 ))
        END=$(( LINE + 10 ))
        [[ -n "$FILE" && -n "$LINE" ]] && \
        batcat --style=numbers --color=always --highlight-line="$LINE" --line-range=$START:$END "$FILE" || echo "No match."
    ' \
        --bind "change:reload:sleep 0.1; rg --hidden --color=always --no-heading --line-number --ignore-case {q} || true" \
        --bind "ctrl-t:transform:[[ !{fzf:prompt} =~ hiddens ]] &&

		echo 'unbind(change)+change-prompt(2. hiddens> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f' ||
    echo 'rebind(change)+change-prompt(1. nhids> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r'"

    --bind 'enter:execute(nvim +{2} {1})' \
        --bind "ctrl-d:reload:rg --color=always --no-heading --line-number --ignore-case {q} || true" \
        --header="$HEADER" \
        --height=100% \
        --preview-window=top:60% \
        --query="$initial_filter" \
        --disabled \
        --bind "start:reload:rg --hidden --color=always --no-heading --line-number --ignore-case '$initial_filter' || true"

    cd "$orig_dir"

}

fzga() {
    orig_dir="$PWD"
    local initial_filter="${1:-}"
    local include_hidden=true

    cd ~
    local running=true

    while [ "$running" = true ]; do
        local rg_args="--color=always --no-heading --line-number --ignore-case"
        "$include_hidden" && rg_args="--hidden $rg_args"

        local hidden_status="[hidden: $("$include_hidden" && echo on || echo off)]"
        local HEADER="ctrl-d=toggle_hidden  ctrl-t=text  $hidden_status"

        result=$(
            FZF_DEFAULT_COMMAND="rg $rg_args '$initial_filter' || true" \
                fzf --phony \
                --prompt='Search: ' \
                --ansi \
                --delimiter ':' \
                --preview '
          FILE={1}
          LINE={2}
          START=$(( LINE > 20 ? LINE - 10 : 1 ))
          END=$(( LINE + 10 ))
          [[ -n "$FILE" && -n "$LINE" ]] && \
          batcat --style=numbers --color=always --highlight-line="$LINE" --line-range=$START:$END "$FILE" || echo "No match."
            ' \
                --bind "change:reload:rg $rg_args {q} || true" \
                --bind "enter:execute(nvim +{2} {1})+accept" \
                --bind "ctrl-d:abort" \
                --bind "ctrl-a:abort; export mode=0" \
                --header="$HEADER" \
                --height=100% \
                --preview-window=top:60% \
                --query="$initial_filter" \
                --disabled \
                --bind "start:reload:rg $rg_args '$initial_filter' || true"
        )
        if [[ mode -eq 0 ]]; then
            running=false
        fi
        # Toggle hidden file inclusion
        include_hidden=$([ "$include_hidden" = true ] && echo false || echo true)
    done

    cd "$orig_dir"
}

#
# # Exit loop if user made a selection
# if [[ $? -eq 0 ]]; then
#     break
# fi
#
fzga() {
    orig_dir="$PWD"
    local initial_filter="${1:-}"
    local include_hidden=true

    cd ~
    while true; do
        local rg_args="--color=always --no-heading --line-number --ignore-case"
        "$include_hidden" && rg_args="--hidden $rg_args"
        local hidden_status="[hidden: $("$include_hidden" && echo on || echo off)]"
        local HEADER="ctrl-d=toggle_hidden  ctrl-t=text  $hidden_status"

        FZF_DEFAULT_COMMAND="rg $rg_args '$initial_filter' || true" \
            result=$(
            fzf --phony \
                --prompt='Search: ' \
                --ansi \
                --delimiter ':' \
                --preview '
              FILE={1}
              LINE={2}
              START=$(( LINE > 20 ? LINE - 10 : 1 ))
              END=$(( LINE + 10 ))
              [[ -n "$FILE" && -n "$LINE" ]] && \
              batcat --style=numbers --color=always --highlight-line="$LINE" --line-range=$START:$END "$FILE" || echo "No match."
            ' \
                --bind "change:reload:rg $rg_args {q} || true" \
                --bind "enter:execute(nvim +{2} {1})+accept" \
                --bind "ctrl-d:abort" \
                --bind "ctrl-a:abort" \
                --header="$HEADER" \
                --height=100% \
                --preview-window=top:60% \
                --query="$initial_filter" \
                --disabled \
                --bind "start:reload:rg $rg_args '$initial_filter' || true"
        )

        fzf_exit=$?
        if [[ $fzf_exit -eq 130 ]]; then
            break
        fi

        # Toggle hidden
        include_hidden=$([ "$include_hidden" = true ] && echo false || echo true)
    done

    cd "$orig_dir"
}

fzgb() {
    orig_dir="$PWD"
    local initial_filter="${1:-}"
    cd ~

    # Files to track state
    echo "$initial_filter" >/tmp/fzga-hidden-query
    echo true >/tmp/fzga-hidden-flag

    RG_BASE="rg --color=always --no-heading --line-number --ignore-case"
    RG_HIDDEN="--hidden"

    fzf --ansi --disabled --query "$initial_filter" \
        --prompt='🔍 RG [hidden: on]> ' \
        --delimiter ':' \
        --header='ctrl-d: toggle hidden files' \
        --height=100% \
        --preview '
      FILE={1}
      LINE={2}
      START=$(( LINE > 20 ? LINE - 10 : 1 ))
      END=$(( LINE + 10 ))
      [[ -n "$FILE" && -n "$LINE" ]] && \
      batcat --style=numbers --color=always --highlight-line="$LINE" --line-range=$START:$END "$FILE" || echo "No match."
    ' \
        --preview-window=top:60% \
        --bind "start:reload:$RG_BASE $RG_HIDDEN {q} || true" \
        --bind "change:reload:$RG_BASE $(cat /tmp/fzga-hidden-flag | grep true >/dev/null && echo "$RG_HIDDEN") {q} || true" \
        --bind "ctrl-d:transform: \
      if [[ $(cat /tmp/fzga-hidden-flag) == true ]]; then \
        echo false > /tmp/fzga-hidden-flag; \
        echo 'change-prompt(🔍 RG [hidden: off]> )+reload:$RG_BASE {q} || true'; \
      else \
        echo true > /tmp/fzga-hidden-flag; \
        echo 'change-prompt(🔍 RG [hidden: on]> )+reload:$RG_BASE $RG_HIDDEN {q} || true'; \
        fi" \
        --bind "enter:become(nvim +{2} {1})"

    cd "$orig_dir"
}

fzgext() {
    rm -f /tmp/rg-fzf-{r,f}
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "

    INITIAL_QUERY="${*:-}"
    fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
      echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
    echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --bind 'ctrl-g:transform:[[ ! $FZF_PROMPT =~ three ]] &&
      echo "rebind(change)+change-prompt(3. three> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
    echo "unbind(change)+change-prompt(4. four> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --prompt '1. ripgrep> ' \
        --delimiter : \
        --header 'CTRL-T: Switch between ripgrep/fzf' \
        --preview 'batcat --style=numbers --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(nvim {1} +{2})'
}
# batcat --style=numbers --color=always --highlight-line="$LINE" --line-range=$START:$END "$FILE" || echo "No match."

fzgext2() {
    rm -f /tmp/rg-fzf-{r,f}
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    INITIAL_QUERY="${*:-}"
    fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
          echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
    echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --bind 'ctrl-g:transform:[[ ! $FZF_PROMPT =~ three ]] &&
          echo "rebind(change)+change-prompt(3. three> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
    echo "unbind(change)+change-prompt(4. four> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --prompt '1. ripgrep> ' \
        --delimiter : \
        --header 'CTRL-T: Switch between ripgrep/fzf | CTRL-G: Switch modes' \
        --preview 'case "$FZF_PROMPT" in
            "1. ripgrep> ") batcat --style=numbers,changes --color=always --theme=GitHub {1} --highlight-line {2} ;;
            "2. fzf> ") batcat --style=header,grid --color=always --theme=Monokai {1} --highlight-line {2} ;;
            "3. three> ") batcat --style=plain --color=always --theme=base16 {1} --highlight-line {2} ;;
            "4. four> ") batcat --style=full --color=always --theme=Dracula {1} --highlight-line {2} ;;
            *) batcat --style=numbers --color=always {1} --highlight-line {2} ;;
    esac' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(nvim {1} +{2})'
}

fzgext3() {
    rm -f /tmp/rg-fzf-{r,f}
    RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
    HIST_PREFIX="HISTTIMEFORMAT= history | sed 's/^ *[0-9]* *//' | grep -i --color=always "
    FIND_PREFIX="find . -type f -name '*' | grep -i --color=always "
    LS_PREFIX="ls -la | grep -i --color=always "
    INITIAL_QUERY="${*:-}"

    fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:$RG_PREFIX {q}" \
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
        --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
          echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
    echo "unbind(change)+change-prompt(2. history> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --bind 'ctrl-g:transform:[[ ! $FZF_PROMPT =~ find ]] &&
          echo "rebind(change)+change-prompt(3. find> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
    echo "unbind(change)+change-prompt(4. ls> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
        --bind 'change:reload:
          case "$FZF_PROMPT" in
            "1. ripgrep> ") sleep 0.1; rg --column --line-number --no-heading --color=always --smart-case {q} || true ;;
            "2. history> ") HISTTIMEFORMAT= history | sed "s/^ *[0-9]* *//" | grep -i --color=always {q} || true ;;
            "3. find> ") find . -type f -name "*{q}*" 2>/dev/null | head -100 || true ;;
            "4. ls> ") ls -la | grep -i --color=always {q} || true ;;
            *) rg --column --line-number --no-heading --color=always --smart-case {q} || true ;;
    esac' \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --prompt '1. ripgrep> ' \
        --delimiter : \
        --header 'CTRL-T: ripgrep/history | CTRL-G: find/ls | Different modes, different searches!' \
        --preview 'case "$FZF_PROMPT" in
            "1. ripgrep> ") batcat --style=numbers,changes --color=always --theme=GitHub {1} --highlight-line {2} 2>/dev/null || echo "Preview: {}" ;;
            "2. history> ") echo "Command: {}" | batcat --style=plain --color=always --theme=Monokai --language=bash 2>/dev/null || echo "Command: {}" ;;
            "3. find> ") batcat --style=plain --color=always --theme=base16 {} 2>/dev/null || file {} 2>/dev/null || echo "File: {}" ;;
            "4. ls> ") batcat --style=full --color=always --theme=Dracula {9} 2>/dev/null || echo "Details: {}" ;;
            *) batcat --style=numbers --color=always {} 2>/dev/null || echo "Preview: {}" ;;
    esac' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:transform:
          case "$FZF_PROMPT" in
            "1. ripgrep> ") echo "become(nvim {1} +{2})" ;;
            "2. history> ") echo "become(eval \"{}\")" ;;
            "3. find> ") echo "become(nvim {})" ;;
            "4. ls> ") echo "become(nvim {9})" ;;
            *) echo "become(nvim {})" ;;
    esac'
}

fzgext4() {
    rm -f /tmp/rg-fzf-{r,f}
    INITIAL_QUERY="${*:-}"

    fzf --ansi --disabled --query "$INITIAL_QUERY" \
        --bind "start:reload:rg --column --line-number --no-heading --color=always --smart-case {q}" \
        --bind "change:reload:sleep 0.1; rg --column --line-number --no-heading --color=always --smart-case {q} || true" \
        --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
          echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r+reload(rg --column --line-number --no-heading --color=always --smart-case {q} || true)" ||
    echo "rebind(change)+change-prompt(2. history> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f+reload(HISTTIMEFORMAT= history | sed \"s/^ *[0-9]* *//\" | grep -i --color=always {q} || true)"' \
        --bind 'ctrl-g:transform:[[ ! $FZF_PROMPT =~ find ]] &&
          echo "rebind(change)+change-prompt(3. find> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r+reload(find . -type f -name \"*{q}*\" 2>/dev/null | head -100 || true)" ||
    echo "unbind(change)+change-prompt(4. ls> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f+reload(ls -la | grep -i --color=always {q} || true)"' \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --prompt '1. ripgrep> ' \
        --delimiter : \
        --header 'CTRL-T: ripgrep/history | CTRL-G: find/ls | Different modes, different searches!' \
        --preview 'case "$FZF_PROMPT" in
            "1. ripgrep> ") batcat --style=numbers,changes --color=always --theme=GitHub {1} --highlight-line {2} 2>/dev/null || echo "Preview: {}" ;;
            "2. history> ") echo "Command: {}" | batcat --style=plain --color=always --theme=Monokai --language=bash 2>/dev/null || echo "Command: {}" ;;
            "3. find> ") batcat --style=plain --color=always --theme=base16 {} 2>/dev/null || file {} 2>/dev/null || echo "File: {}" ;;
            "4. ls> ") batcat --style=full --color=always --theme=Dracula {9} 2>/dev/null || echo "Details: {}" ;;
            *) batcat --style=numbers --color=always {} 2>/dev/null || echo "Preview: {}" ;;
    esac' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:transform:
          case "$FZF_PROMPT" in
            "1. ripgrep> ") echo "become(nvim {1} +{2})" ;;
            "2. history> ") echo "become(eval \"{}\")" ;;
            "3. find> ") echo "become(nvim {})" ;;
            "4. ls> ") echo "become(nvim {9})" ;;
            *) echo "become(nvim {})" ;;
    esac'
}

fzkb() {
    orig_dir="$PWD"
    local initial_filter="${1:-}"
    local HEADER="ctrl-g=gsettings  ctrl-k=keybinding search  ctrl-d=dconf"
    cd ~
    fzf --phony \
        --prompt='Keybinding Search: ' \
        --ansi \
        --delimiter ':' \
        --preview '
FILE={1}
LINE={2}
if [[ -n "$FILE" && -n "$LINE" && "$LINE" =~ ^[0-9]+$ ]]; then
  LINE_NUM=$((LINE))
  if [[ "$LINE_NUM" -gt 10 ]]; then
    START=$((LINE_NUM - 5))
  else
    START=1
  fi
  END=$((LINE_NUM + 5))
  batcat --style=numbers --color=always --highlight-line="$LINE_NUM" --line-range=$START:$END "$FILE"
else
  echo "No preview available."
fi
    ' \
        --bind "change:reload:sleep 0.1; rg --color=always --no-heading --line-number --ignore-case {q} ~/.keybindings_dump.txt || true" \
        --bind 'enter:execute(echo "Selected line: {+}" | less)' \
        --bind "ctrl-g:reload:gsettings list-recursively | tee ~/.keybindings_dump.txt | rg --color=always --no-heading --line-number --ignore-case {q} || true" \
        --bind "ctrl-d:reload:dconf dump / | tee ~/.keybindings_dump.txt | rg --color=always --no-heading --line-number --ignore-case {q} || true" \
        --bind "ctrl-k:reload:gsettings list-recursively | grep -i keybinding | tee ~/.keybindings_dump.txt | rg --color=always --no-heading --line-number --ignore-case {q} || true" \
        --header="$HEADER" \
        --height=100% \
        --preview-window=top:60% \
        --query="$initial_filter" \
        --disabled \
        --bind "start:reload:gsettings list-recursively | grep -i keybinding | tee ~/.keybindings_dump.txt | rg --color=always --no-heading --line-number --ignore-case '$initial_filter' || true"
    cd "$orig_dir"
}

# insted of no match put some kind of image or whatever
# search contents as well as file names or directories. depending on what you're doing you're either cded to it or go into nvim etc
#
# turn it into a tmux plugin or whatever
# enable/disable dotfiles
# search certain file types
# doesn't like brackets for some reason, tried info() and success() from install_rust and didn't work
#
#
#
#
#
#
#

# Combined fuzzy finder with dynamic mode switching
fzf_combined() {
    local mode="${1:-dir}" # Default to directory mode
    local orig_dir="$PWD"
    local selection

    while true; do
        if [[ "$mode" == "dir" ]]; then
            # Directory mode
            selection=$(find . -type d 2>/dev/null |
                fzf --height=40% \
                    --prompt="DIR> " \
                    --header="CTRL-F: Files | ENTER: CD | ESC: Exit" \
                    --bind="ctrl-f:transform:echo '__SWITCH_TO_FILE__'" \
                    --preview="ls -la {}" \
                --preview-window=right:50%)
        else
            # File mode
            cd ~ 2>/dev/null
            selection=$(find . -type f 2>/dev/null |
                fzf --height=40% \
                    --prompt="FILE> " \
                    --header="CTRL-D: Dirs | ENTER: Edit | ESC: Exit" \
                    --bind="ctrl-d:transform:echo '__SWITCH_TO_DIR__'" \
                    --preview='batcat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo "Cannot preview file"' \
                --preview-window=right:60%)
        fi

        # Handle the selection
        case "$selection" in
            "__SWITCH_TO_FILE__")
                mode="file"
                cd "$orig_dir"
                continue
                ;;
            "__SWITCH_TO_DIR__")
                mode="dir"
                cd "$orig_dir"
                continue
                ;;
            "")
                # User pressed ESC or no selection
                cd "$orig_dir"
                break
                ;;
            *)
                # User made a selection
                if [[ "$mode" == "dir" ]]; then
                    cd "$selection" 2>/dev/null && break
                else
                    "${EDITOR:-nvim}" "$selection"
                    cd "$orig_dir"
                    break
                fi
                ;;
        esac
    done
}

gitsum() {
    # Check if we're inside a git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Not a git repository!"
        return 1
    fi

    echo "=== Git Repository Summary ==="
    echo

    # Current branch
    local_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Current branch: $local_branch"

    # Remote tracking branch
    tracking_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [ "$tracking_branch" != "" ]; then
        echo "Tracking remote branch: $tracking_branch"
    else
        echo "Tracking remote branch: (none)"
    fi

    echo

    # Remote URLs
    echo "Remotes:"
    git remote -v
    echo

    # Local branches
    echo "Local branches:"
    git branch
    echo

    # Remote branches
    echo "Remote branches:"
    git branch -r
    echo

    # Status
    echo "Git status:"
    git status -sb
    echo

    # Recent commits (last 5)
    echo "Recent commits (last 5):"
    git log --oneline --decorate --graph -5
    echo

    # Commits ahead/behind remote
    if [ "$tracking_branch" != "" ]; then
        ahead=$(git rev-list --count HEAD.."$tracking_branch")
        behind=$(git rev-list --count "$tracking_branch"..HEAD)
        echo "Commits ahead of remote: $behind"
        echo "Commits behind remote: $ahead"
        echo
    fi

    # Unmerged branches (optional)
    echo "Unmerged branches into current:"
    git branch --no-merged
    echo

    # Show staged/unstaged files summary
    echo "Staged changes:"
    git diff --cached --name-status
    echo
    echo "Unstaged changes:"
    git diff --name-status
    echo

    echo "=== End of Summary ==="
}
