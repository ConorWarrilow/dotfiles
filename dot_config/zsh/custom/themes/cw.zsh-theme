# vim:ft=zsh ts=2 sw=2 sts=2
#
# Original agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
# Pixegami: Modified some elements to suit my Python/Git heavy use.


CURRENT_BG='NONE'

# Special Powerline characters

() {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    # NOTE: This segment separator character is correct.  In 2012, Powerline changed
    # the code points they use for their special characters. This is the new code point.
    # If this is not working for you, you probably have an old version of the
    # Powerline-patched fonts installed. Download and install the new version.
    # Do not submit PRs to change this unless you have reviewed the Powerline code point
    # history and have new information.
    # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
    # what font the user is viewing this source code in. Do not replace the
    # escape sequence with a single literal character.
    # Do not change this! Do not make it '\u2b80'; that is the old, wrong code point.
    SEGMENT_SEPARATOR=$'\ue0b0'
}

SEGMENT_SEPARATOR=$'\ue0b0'   # 
SECOND_SEPARATOR=$'\ue0d7'    # 


# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment_old() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        # This line actually gets used
        echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n "$3"
}


prompt_segment() {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
        # End the previous segment with its separator

        echo -n " %{$bg%F{$CURRENT_BG}%}%{%k%}$SEGMENT_SEPARATOR%{$fg%}"
        # ^ put a space here to add extra space at end of segment
        # Add transparent gap
        #echo -n "%{%k%}"
        # Start new segment with its separator
        echo -n "%{%F{$1}%}\ue0d7%{$bg%}%{$fg%} "
        # ^ put space here for extra space at start of segment
    else
        echo -n "%{$bg%}%{$fg%} "
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n "$3"
}




# End the prompt, closing any open segments
prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
        echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
    else
        echo -n "%{%k%}"
    fi
    echo -n "%{%f%}"
    CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
#
DEVICE_ICON="$DEVICE_ICON"

# Updated 2025/04/05 - Allows me to still hardcode my name for my phone but uses the value of whoami for other devices
prompt_context() {
    #local venv=""
    #[[ -n $VIRTUAL_ENV ]] && venv="($(basename "$VIRTUAL_ENV")) "

    local user
    if [[ $(whoami) == "u0_a7" ]]; then
        user="conor"
    else
        #user=$(whoami)
        user="忍"
    fi
    #prompt_segment 008 006 "${venv}${user}${DEVICE_ICON}"
    prompt_segment 000 006 "$user"
}


# Git: branch/detached head, dirty status
prompt_git() {
    # Checks if the git commands exists, exits if not
    (( $+commands[git] )) || return

    local PL_BRANCH_CHAR
    () {
        local LC_ALL="" LC_CTYPE="en_US.UTF-8"
        PL_BRANCH_CHAR=$'\ue0a0'         # 
    }

    local ref dirty mode repo_path
    # path to .git directory
    repo_path=$(git rev-parse --git-dir 2>/dev/null)

    # Checks if you're inside a working tree of a Git repository. If not, nothing will happen
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        dirty=$(parse_git_dirty)
        ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
        if [[ -n $dirty ]]; then
            prompt_segment red black
        else
            prompt_segment 010 black
        fi

        if [[ -e "${repo_path}/BISECT_LOG" ]]; then
            mode=" <B>"
        elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
            mode=" >M<"
        elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
            mode=" >R>"
        fi

        setopt promptsubst
        autoload -Uz vcs_info

        zstyle ':vcs_info:*' enable git
        zstyle ':vcs_info:*' get-revision true
        zstyle ':vcs_info:*' check-for-changes true
        zstyle ':vcs_info:*' stagedstr '+'
        zstyle ':vcs_info:*' unstagedstr '-'
        zstyle ':vcs_info:*' formats ' %u%c'
        zstyle ':vcs_info:*' actionformats ' %u%c'
        vcs_info
        echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
    fi
}

prompt_bzr() {
    (( $+commands[bzr] )) || return
    if (bzr status >/dev/null 2>&1); then
        status_mod=`bzr status | head -n1 | grep "modified" | wc -m`
        status_all=`bzr status | head -n1 | wc -m`
        revision=`bzr log | head -n2 | tail -n1 | sed 's/^revno: //'`
        if [[ $status_mod -gt 0 ]] ; then
            prompt_segment yellow black
            echo -n "bzr@""$revision" "✚ "
        else
            if [[ $status_all -gt 0 ]] ; then
                prompt_segment yellow black
                echo -n "bzr@""$revision"

            else
                prompt_segment green black
                echo -n "bzr@""$revision"
            fi
        fi
    fi
}

prompt_hg() {
    (( $+commands[hg] )) || return
    local rev status
    if "$(hg id >/dev/null 2>&1)"; then
        if "$(hg prompt >/dev/null 2>&1)"; then
            if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
                # if files are not added
                prompt_segment red white
                st='±'
            elif [[ -n $(hg prompt "{status|modified}") ]]; then
                # if any modification
                prompt_segment yellow black
                st='±'
            else
                # if working copy is clean
                prompt_segment green black
            fi
            echo -n "$(hg prompt "☿ {rev}@{branch}")" "$st"
        else
            st=""
            rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
            branch=$(hg id -b 2>/dev/null)
            if "$(hg st | grep -q "^\?")"; then
                prompt_segment red black
                st='±'
            elif "$(hg st | grep -q "^[MA]")"; then
                prompt_segment yellow black
                st='±'
            else
                prompt_segment green black
            fi
            echo -n "☿ $rev@$branch" "$st"
        fi
    fi
}

# Dir: current working directory
prompt_dir() {
    # prompt_segment 008 010 $(basename `pwd`)
}

# Virtualenv: current working virtualenv
prompt_virtualenv_old() {
    if [[ -n $CONDA_PROMPT_MODIFIER ]]; then
        prompt_segment 008 005 "${CONDA_PROMPT_MODIFIER:1:-2}"
    fi
}

prompt_virtualenv() {
    if [[ -n $CONDA_PROMPT_MODIFIER ]]; then
        if [[ $CONDA_PROMPT_MODIFIER == "(base) " ]]; then
            prompt_segment 008 005 "B"

        else
            #:1:-2 is using substring slicing; remove the first and last two characters
            prompt_segment 008 005 "${CONDA_PROMPT_MODIFIER:1:-2}"
        fi
    fi
}


prompt_python_venv() {
    if [[ -n $CONDA_PROMPT_MODIFIER ]]; then
        # Conda environment detection
        if [[ $CONDA_PROMPT_MODIFIER == "(base) " ]]; then
            prompt_segment 008 005 ""
        else
            # Remove the first and last two characters from conda prompt
            prompt_segment 008 005 "${CONDA_PROMPT_MODIFIER:1:-2}"
        fi
    elif [[ -n $VIRTUAL_ENV ]]; then
        # UV/pip virtual environment detection
        local venv_name=$(basename "$VIRTUAL_ENV")

        # Check if this is a uv-managed virtual environment
        if [[ -f "$VIRTUAL_ENV/pyvenv.cfg" ]] && grep -q "uv" "$VIRTUAL_ENV/pyvenv.cfg" 2>/dev/null; then
            # UV environment - use cyan color
            prompt_segment 008 003 ""
        else
            # Regular pip/virtualenv environment - use original colors
            prompt_segment 008 004 "$venv_name"
        fi
    fi
}


# was black default not 008 006
# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
    local symbols
    symbols=()
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

    [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}
# old prompt head
#prompt_head() {
#  echo "\r               "  # Clear prevous line
#  echo "\r %{%F{8}%}[%64<..<%~%<<]"  # Print Dir.
#}


prompt_head() {
    echo "\r               "  # Clear prevous line
    if [[ $PWD != $HOME ]]; then
        local git_segment=""
        #    if git rev-parse --is-inside-work-tree &>/dev/null; then
        #      local repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
        #      (( $+commands[commitchecker] )) || color="004"
        #      color=$(commitchecker)
        #      git_segment="%F{"$color"}[${repo_name}]%f "

        local current_commit_hash=$(git rev-parse HEAD 2> /dev/null)
        if [[ -n $current_commit_hash ]]; then

            local current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
            if [[ $current_branch == 'HEAD' ]]; then
                git_segment="head"
            else
                git_segment="noth"
            fi
            local number_of_logs="$(git log --pretty=oneline -n1 2> /dev/null | wc -l)"
            if [[ $number_of_logs -eq 0 ]]; then
                git_segment+="init"
            else
                git_segment+="nt-just-init"
            fi

        fi
        echo "\r${git_segment}%F{8}[%64<..<%~%<<]%f"

    fi
}

prompt_head() {
    echo "\r               "  # Clear prevous line
    echo "\r%F{8}[%64<..<%~%<<]%f"
}


#SEGMENT_SEPARATOR_RIGHT=$'\uE0B6'  # Powerline right-side triangle
#prompt_segment_right() {
#  local bg fg
#  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
#  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
#
#  # Use previous background for correct triangle color
#  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
#    # End previous with a separator into the new color
#    echo -n "%{%K{$CURRENT_BG}%F{$1}%}$SEGMENT_SEPARATOR_RIGHT"
#  fi
#
#  echo -n "%{$bg$fg%} $3 "  # actual content
#  CURRENT_BG=$1
#}



#
#prompt_head() {
#  local width=${COLUMNS:-$(tput cols)}
#  local path="%64<..<%~%<<"
#  local left="%F{8}["
#  local right="]%f"
#
#  # Render left side path
#  local rendered_path
#  zformat -f rendered_path "$path"
#  local plain_path=${(S%%)rendered_path}
#  local prompt_length=$(( $#left + $#plain_path + $#right ))
#
#  # --- Build right-aligned segment string ---
#  CURRENT_BG='NONE'
#  local seg_time=$(prompt_segment_right 004 000 "%*")             # Current time
#  local seg_date=$(prompt_segment_right 005 000 "%D{%Y-%m-%d}")   # Current date
#  local seg_host=$(prompt_segment_right 006 000 "%m")             # Hostname
#  local segments="$seg_time$seg_date$seg_host%{%k%f%}"            # Reset at end
#
#  # Strip formatting to measure width
#  local plain_segments=${(S%%)segments}
#  local seg_width=${#plain_segments}
#
#  # Space between left prompt and right segments
#  local space_between=$(( width - prompt_length - seg_width ))
#
#  echo -n "\r               "  # Clear previous line
#  echo -n "\r$left$rendered_path$right"
#  printf "%*s" "$space_between" ""
#  echo "$segments"
#}








function get_current_action () {
    local info="$(git rev-parse --git-dir 2>/dev/null)"
    if [ "$info" != "" ]; then
        local action
        if [ -f "$info/rebase-merge/interactive" ]; then
            action="rebase -i"
        elif [ -d "$info/rebase-merge" ]; then
            action="rebase -m"
        else
            if [ -d "$info/rebase-apply" ]; then
                if [ -f "$info/rebase-apply/rebasing" ]; then
                    action="rebase"
                elif [ -f "$info/rebase-apply/applying" ]; then
                    action="am"
                else
                    action="am/rebase"
                fi
            elif [ -f "$info/MERGE_HEAD" ]; then
                action="merge"
            elif [ -f "$info/CHERRY_PICK_HEAD" ]; then
                action="cherry-pick"
            elif [ -f "$info/BISECT_LOG" ]; then
                action="bisect"
            fi
        fi

        if [[ -n $action ]]; then echo "$action"; fi
    fi
}


git_info() {
    # Check if we're in a git repo
    local current_commit_hash=$(git rev-parse HEAD 2> /dev/null)
    if [[ -n $current_commit_hash ]]; then
        local is_a_git_repo=true
    else
        return
    fi

    # Branch information
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

    if [[ $current_branch == 'HEAD' ]]; then
        local detached=true
    fi

    # Check repository state
    local number_of_logs="$(git log --pretty=oneline -n1 2> /dev/null | wc -l)"
    if [[ $number_of_logs -eq 0 ]]; then
        local just_init=true
    else
        # only continue if we didn't just init
        local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
        if [[ -n "$upstream" && "$upstream" != "@{upstream}" ]]; then
            local has_upstream=true
        fi

        # Get current action (rebase, merge, etc.)
        local action="$(get_current_action)"

        local git_status="$(git status --porcelain 2> /dev/null)"

        if [[ $git_status =~ ($'\n'|^).M ]]; then
            local has_modifications=true
        fi

        if [[ $git_status =~ ($'\n'|^)M ]]; then
            local has_modifications_cached=true

        fi

        if [[ $git_status =~ ($'\n'|^)A ]]; then
            local has_adds=true
        fi

        if [[ $git_status =~ ($'\n'|^).D ]]; then
            local has_deletions=true
        fi

        if [[ $git_status =~ ($'\n'|^)D ]]; then
            local has_deletions_cached=true
        fi

        if [[ $git_status =~ ($'\n'|^)[MAD] && ! $git_status =~ ($'\n'|^).[MAD\?] ]]; then
            local ready_to_commit=true
        fi

        # Untracked files
        local number_of_untracked_files=$(\grep -c "^??" <<< "$git_status")
        if [[ $number_of_untracked_files -gt 0 ]]; then
            local has_untracked_files=true
        fi

        # NEW: Unmerged files (files with conflicts)
        local number_of_unmerged_files=$(\grep -c "^UU\|^AA\|^DD\|^U.\|^.U" <<< "$git_status")
        if [[ $number_of_unmerged_files -gt 0 ]]; then
            local has_unmerged_files=true
        fi

        # NEW: Number of staged files
        local number_of_staged_files=$(\grep -c "^[MADRC]" <<< "$git_status")
        if [[ $number_of_staged_files -gt 0 ]]; then
            local has_staged_files=true
        fi

        # NEW: Number of changed but unstaged files
        local number_of_unstaged_files=$(\grep -c "^.[MADRC]" <<< "$git_status")
        if [[ $number_of_unstaged_files -gt 0 ]]; then
            local has_unstaged_files=true
        fi

        # Tag information
        local tag_at_current_commit=$(git describe --exact-match --tags "$current_commit_hash" 2> /dev/null)
        if [[ -n $tag_at_current_commit ]]; then
            local is_on_a_tag=true
        fi

        # Commits ahead/behind upstream
        if [[ $has_upstream == true ]]; then
            local commits_ahead commits_behind
            read -r commits_ahead commits_behind <<<"$(git rev-list --left-right --count "$current_commit_hash...$upstream" 2> /dev/null)"

            if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then
                local has_diverged=true
            fi

            if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then
                local should_push=true
            fi
        fi

        # Rebase configuration
        local will_rebase=$(git config --get branch."$current_branch".rebase 2> /dev/null)

        local number_of_stashes="$(git stash list 2> /dev/null | wc -l)"
        if [[ $number_of_stashes -gt 0 ]]; then
            local has_stashes=true
        fi
    fi
}



## Main prompt
build_prompt() {
    RETVAL=$?
    prompt_head
    prompt_status
    prompt_python_venv
    prompt_context
    # prompt_dir
    prompt_git
    #    prompt_bzr
    #    prompt_hg
    prompt_end
    #git_info
}

PROMPT='%{%f%b%k%}$(build_prompt) '



print_prompt() {
    print -P "$PROMPT"
}
