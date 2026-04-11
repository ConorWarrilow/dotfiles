# -------------------------------------------------------------------
# Aliases
# -------------------------------------------------------------------

# INFO: Neovim
alias v='nvim'
alias vn='NVIM_APPNAME=nvim-new nvim'
alias vc='NVIM_APPNAME=nvim-nvchad nvim'
alias vk='NVIM_APPNAME=nvim-kickstart nvim'
alias va='NVIM_APPNAME=nvim-astrovim nvim'
alias vl='NVIM_APPNAME=nvim-lazy nvim'
alias neit="nvim $XDG_CONFIG_HOME/nvim/init.lua"

# INFO: Tmux
alias tn='tmux new -c "$(pwd)" -s'
alias tnw='tmux new-window -n '
alias ta='tmux attach -t '
alias tkw='tmux kill-window -t '
alias tkser='tmux kill-server'
alias tkses='tmux kill-session'
alias tl='tmux list-sessions '
alias td='tmux detach'
alias tsoff='tmux set-option -g status off'
alias tson='tmux set-option -g status on'
alias tss='tmux start-server'
alias tsf='tmux source-file ~/.tmux.conf'

# bat: Ubuntu apt installs as 'batcat', cargo/snap installs as 'bat'
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    alias bat='batcat'
fi

# fd: Ubuntu apt installs as 'fdfind', cargo installs as 'fd'
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd='fdfind'
fi

# kitty image protocol — desktop only
if command -v kitty >/dev/null 2>&1; then
    alias icat='kitty icat'
fi

alias c='clear'
alias s="source $ZDOTDIR/.zshrc"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# INFO: Quick navigation
alias rc="nvim ~/.config/zsh/.zshrc"
alias al="nvim ~/.config/zsh/include/aliases.zsh"
alias fun="nvim ~/.config/zsh/include/functions.zsh"

# INFO: Git aliases
alias grst='git restore --staged '
alias grv='git remote --verbose '
alias gst='git status'
alias gnb='git switch -c'
alias gs='git status'
alias gacp='git add . && git commit -m "auto committed via gacp alias" && git push'
alias gmv='git mv '

# INFO: GH CLI
alias grf='gh repo fork --remote'

# INFO: Network
alias rip='ip route | grep default'
alias mip="hostname -I | awk '{print \$1}'"
alias arch='uname -m && dpkg --print-architecture'

# INFO: eza (modern ls)
alias l='eza \
    --color=always \
    --icons=always \
    --long \
    --all \
    --header \
    --no-user \
    --time-style=relative \
    --sort=Name \
    --extended \
    --group-directories-first \
    --binary \
    --links \
    --hyperlink'

alias lf='l --total-size '
alias lg='l --git --git-repos '
alias lt='l --tree --level 2 '
alias ltt='l --tree --level 3 '
alias lttt='l --tree --level 4 '
alias ltttt='l --tree --level 5 '
alias ltr='l --tree --level 10 '
alias ltg='lt --git --git-repos '
alias lgt='ltg'

# INFO: Python / environments
alias c-de='conda deactivate'
alias senv='source .venv/bin/activate'
alias py='python '
