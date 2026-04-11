# -------------------------------------------------------------------
# Dotfiles test container
#
# Two build targets:
#
#   files  — fast (~30s): renders all templates and checks output files
#            exist with correct content. Does NOT run install scripts.
#
#            docker build --target files -t dotfiles-test .
#            docker run --rm dotfiles-test
#
#   full   — slow (~10min): runs the complete bootstrap including all
#            run_once_ install scripts, just like a real fresh machine.
#
#            docker build --target full -t dotfiles-full .
#            docker run --rm -it dotfiles-full
#
# Both targets build from chezmoi_dots/ as the context:
#   docker build --target files -t dotfiles-test -f Dockerfile .
# -------------------------------------------------------------------

# ===================================================================
# Base: shared setup for both targets
# ===================================================================
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      curl \
      git \
      sudo \
      zsh \
      ca-certificates \
      locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8

# Create a non-root user with passwordless sudo (mirrors a real user account)
RUN useradd -m -s /bin/bash -u 1000 testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy the chezmoi source (this directory) into the container.
# The COPY runs as root; we chown so testuser can read it.
COPY --chown=testuser:testuser . /home/testuser/.local/share/chezmoi

USER testuser
WORKDIR /home/testuser

# Install chezmoi into ~/.local/bin
RUN sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/testuser/.local/bin
ENV PATH="/home/testuser/.local/bin:${PATH}"

# Pre-seed chezmoi.toml so chezmoi never hits interactive prompts.
# github_token is set to a placeholder — the template falls back to
# promptSecretOnce which reads from this file, not from AWS.
RUN mkdir -p /home/testuser/.config/chezmoi \
    && cat > /home/testuser/.config/chezmoi/chezmoi.toml <<'EOF'
[data]
  profile      = "desktop"
  name         = "Test User"
  email        = "test@example.com"
  isDesktop    = true
  isServer     = false
  isWork       = false
  isTermux     = false
  github_token = "ghp_placeholder_not_real"

[awsSecretsManager]
  region = "us-east-1"
EOF

# ===================================================================
# Target: files
# Applies only file/template rendering; skips all run_once_ scripts.
# ===================================================================
FROM base AS files

# GIT_CONFIG_GLOBAL=/dev/null stops git reading ~/.gitconfig during apply.
# Without it, chezmoi writes the gitconfig (which has an insteadOf rule that
# rewrites https://github.com → git@github.com:), then immediately uses git
# to fetch .chezmoiexternal repos — triggering SSH which isn't in the image.
RUN echo ">>> Applying dotfiles (files only, no scripts)..." \
    && GIT_CONFIG_GLOBAL=/dev/null chezmoi apply --no-tty --exclude scripts 2>&1

# ---------------------------------------------------------------
# Assertions — each line is a test case
# A failing test prints FAIL and exits non-zero so docker build fails.
# ---------------------------------------------------------------
RUN set -e; \
    pass() { printf '\033[32m  PASS\033[0m %s\n' "$1"; }; \
    fail() { printf '\033[31m  FAIL\033[0m %s\n' "$1"; exit 1; }; \
    \
    echo ""; \
    echo "=== File existence ==="; \
    [ -f ~/.zshenv ]                          && pass ".zshenv"                          || fail ".zshenv missing"; \
    [ -f ~/.tmux.conf ]                        && pass ".tmux.conf"                       || fail ".tmux.conf missing"; \
    [ -f ~/.gitconfig ]                        && pass ".gitconfig"                       || fail ".gitconfig missing"; \
    [ -f ~/.gitignore_global ]                 && pass ".gitignore_global"                || fail ".gitignore_global missing"; \
    [ -f ~/.sqliterc ]                         && pass ".sqliterc"                        || fail ".sqliterc missing"; \
    [ -f ~/.env ]                              && pass ".env"                             || fail ".env missing"; \
    [ -f ~/.config/zsh/.zshrc ]                && pass ".config/zsh/.zshrc"              || fail ".config/zsh/.zshrc missing"; \
    [ -f ~/.config/zsh/include/aliases.zsh ]   && pass "aliases.zsh"                     || fail "aliases.zsh missing"; \
    [ -f ~/.config/zsh/include/functions.zsh ] && pass "functions.zsh"                   || fail "functions.zsh missing"; \
    [ -f ~/.config/zsh/include/work.zsh ]      && pass "work.zsh"                        || fail "work.zsh missing"; \
    [ -f ~/.config/zsh/custom/themes/cw.zsh-theme ] && pass "cw.zsh-theme"              || fail "cw.zsh-theme missing"; \
    [ -f ~/.config/nvim/init.lua ]             && pass "nvim init.lua"                   || fail "nvim init.lua missing"; \
    [ -f ~/.config/btop/btop.conf ]            && pass "btop.conf"                       || fail "btop.conf missing"; \
    [ -f ~/.config/bat/config ]                && pass "bat config"                      || fail "bat config missing"; \
    [ -f ~/.config/kitty/kitty.conf ]          && pass "kitty.conf"                      || fail "kitty.conf missing"; \
    [ -f ~/.config/Code/User/settings.json ]   && pass "vscode settings.json"            || fail "vscode settings.json missing"; \
    [ -f ~/.config/Code/User/keybindings.json ] && pass "vscode keybindings.json"        || fail "vscode keybindings.json missing"; \
    [ -f ~/.config/Code/User/extensions.txt ]  && pass "vscode extensions.txt"           || fail "vscode extensions.txt missing"; \
    [ -x ~/.local/bin/fzm ]                    && pass "fzm is executable"               || fail "fzm not executable or missing"; \
    \
    echo ""; \
    echo "=== Template rendering ==="; \
    grep -q "Test User" ~/.gitconfig           && pass ".gitconfig has correct name"     || fail ".gitconfig name wrong"; \
    grep -q "test@example.com" ~/.gitconfig    && pass ".gitconfig has correct email"    || fail ".gitconfig email wrong"; \
    grep -q "ZDOTDIR" ~/.zshenv                && pass ".zshenv sets ZDOTDIR"            || fail ".zshenv missing ZDOTDIR"; \
    grep -q "isDesktop.*true\|desktop" ~/.config/zsh/.zshrc 2>/dev/null \
      || grep -q "nvm" ~/.config/zsh/.zshrc    && pass ".zshrc contains desktop section" || fail ".zshrc missing desktop section"; \
    grep -q "/home/testuser/.config/btop/themes" ~/.config/btop/btop.conf \
                                               && pass "btop.conf path templated"        || fail "btop.conf still has hardcoded path"; \
    \
    echo ""; \
    echo "=== Profile gating (.chezmoiignore) ==="; \
    [ -f ~/.config/kitty/kitty.conf ]          && pass "kitty present on desktop"        || fail "kitty missing on desktop profile"; \
    [ -f ~/.config/Code/User/settings.json ]   && pass "vscode present on desktop"       || fail "vscode missing on desktop profile"; \
    [ ! -f ~/.config/termux/termux.properties ] && pass "termux absent on desktop"       || fail "termux should be absent on desktop profile"; \
    \
    echo ""; \
    echo "=== .env secrets ==="; \
    grep -q "GITHUB_TOKEN" ~/.env              && pass ".env has GITHUB_TOKEN"           || fail ".env missing GITHUB_TOKEN"; \
    grep -qv "awsSecretsManager" ~/.env        && pass ".env is rendered (not raw tmpl)" || fail ".env looks unrendered"; \
    \
    echo ""; \
    echo "All tests passed."

CMD ["bash", "--login"]

# ===================================================================
# Target: full
# Runs the complete bootstrap including all install scripts.
# Takes significantly longer (~10 min) but tests the real thing.
# ===================================================================
FROM base AS full

# Pre-install a few things that the scripts expect to already be
# present on a base Ubuntu system (the scripts themselves install the
# rest, but sudo/curl/git need to be there before script 00 runs).
RUN sudo apt-get update -qq && sudo apt-get install -y --no-install-recommends \
      lsb-release \
      gnupg \
      apt-transport-https \
    && sudo rm -rf /var/lib/apt/lists/*

RUN echo ">>> Applying dotfiles (full install including scripts)..." \
    && GIT_CONFIG_GLOBAL=/dev/null chezmoi apply --no-tty 2>&1

# Spot-check a few things that only exist after scripts run
RUN set -e; \
    pass() { printf '\033[32m  PASS\033[0m %s\n' "$1"; }; \
    fail() { printf '\033[31m  FAIL\033[0m %s\n' "$1"; exit 1; }; \
    \
    echo "=== Post-install checks ==="; \
    [ -d ~/.config/.oh-my-zsh ]                && pass "oh-my-zsh installed"            || fail "oh-my-zsh missing"; \
    command -v zsh >/dev/null                  && pass "zsh available"                   || fail "zsh not on PATH"; \
    [ -d ~/.tmux/plugins/tpm ]                 && pass "TPM cloned"                     || fail "TPM missing (chezmoi external)"; \
    [ -d ~/.config/zsh/custom/plugins/zsh-syntax-highlighting ] \
                                               && pass "zsh-syntax-highlighting cloned"  || fail "zsh-syntax-highlighting missing"; \
    \
    echo "All post-install checks passed."

CMD ["bash", "--login"]
