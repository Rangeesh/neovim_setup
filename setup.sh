#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Dotfiles Bootstrap Script
# Sets up: Neovim + lazy.nvim + TMUX + WezTerm + OpenCode environment
# Compatible with: macOS (Homebrew) and Ubuntu/Debian (apt)
# ==============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step()  { echo -e "\n${BOLD}==> $1${NC}"; }

# Use sudo only when not already root
SUDO=""
if [[ "$EUID" -ne 0 ]]; then
  SUDO="sudo"
fi

# ----------------------------------------------------------
# Step 1: Detect OS
# ----------------------------------------------------------
step "Detecting platform..."

OS="unknown"
if [[ "$(uname)" == "Darwin" ]]; then
  OS="macos"
  info "macOS $(sw_vers -productVersion) on $(uname -m) detected"
elif [[ -f /etc/debian_version ]]; then
  OS="ubuntu"
  info "Ubuntu/Debian $(cat /etc/debian_version) on $(uname -m) detected"
else
  error "Unsupported OS. This script supports macOS and Ubuntu/Debian."
  exit 1
fi

# ----------------------------------------------------------
# Step 2: Install packages
# ----------------------------------------------------------
step "Installing packages..."

if [[ "$OS" == "macos" ]]; then
  # ---- macOS: Homebrew ----
  if ! command -v brew &>/dev/null; then
    error "Homebrew is not installed. Install it first: https://brew.sh"
    exit 1
  fi
  info "Homebrew $(brew --version | head -1 | awk '{print $2}') found"

  BREW_PACKAGES=(neovim ripgrep fd bat git-delta tree-sitter tree-sitter-cli)
  for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      info "$pkg is already installed"
    else
      info "Installing $pkg..."
      brew install "$pkg"
    fi
  done

elif [[ "$OS" == "ubuntu" ]]; then
  # ---- Ubuntu/Debian: apt ----

  # Add Neovim PPA for 0.11+
  if ! apt-cache policy neovim 2>/dev/null | grep -q "0\.11\|0\.12"; then
    info "Adding Neovim unstable PPA (needed for v0.11+)..."
    $SUDO apt-get install -y software-properties-common
    $SUDO add-apt-repository -y ppa:neovim-ppa/unstable
  fi

  info "Updating apt cache..."
  $SUDO apt-get update -y

  APT_PACKAGES=(neovim tmux ripgrep fd-find bat git curl build-essential unzip xclip python3-venv)
  for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
      info "$pkg is already installed"
    else
      info "Installing $pkg..."
      $SUDO apt-get install -y "$pkg"
    fi
  done

  # Ubuntu names fd and bat differently -- create symlinks
  mkdir -p "$HOME/.local/bin"
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    info "Symlinked fdfind -> fd"
  fi
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    info "Symlinked batcat -> bat"
  fi

  # Ensure ~/.local/bin is in PATH
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    # Add to shell rc if not already there
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
      if [ -f "$rc" ] && ! grep -q '.local/bin' "$rc"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        info "Added ~/.local/bin to PATH in $(basename "$rc")"
      fi
    done
  fi

  # Install Node.js if missing (needed for Mason LSP servers + tree-sitter-cli)
  if ! command -v node &>/dev/null; then
    info "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | $SUDO bash -
    $SUDO apt-get install -y nodejs
    info "Node.js $(node --version) installed"
  else
    info "Node.js $(node --version) already installed"
  fi

  # Install tree-sitter-cli via npm
  if ! command -v tree-sitter &>/dev/null; then
    info "Installing tree-sitter-cli via npm..."
    $SUDO npm install -g tree-sitter-cli
    info "tree-sitter $(tree-sitter --version) installed"
  else
    info "tree-sitter $(tree-sitter --version) already installed"
  fi

  # Install git-delta (not in default apt repos, use GitHub release)
  if ! command -v delta &>/dev/null; then
    info "Installing git-delta..."
    DELTA_VERSION="0.18.2"
    ARCH=$(dpkg --print-architecture)
    curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_${ARCH}.deb" -o /tmp/git-delta.deb
    $SUDO dpkg -i /tmp/git-delta.deb
    rm -f /tmp/git-delta.deb
    info "git-delta installed"
  else
    info "git-delta already installed"
  fi
fi

# ----------------------------------------------------------
# Step 3: Install Python tools (ruff, black)
# ----------------------------------------------------------
step "Installing Python tools..."

for tool in ruff black; do
  if command -v "$tool" &>/dev/null; then
    info "$tool is already installed"
  else
    info "Installing $tool..."
    pip3 install --user "$tool" 2>/dev/null || pip3 install "$tool" 2>/dev/null || warn "$tool install failed (will be installed via Mason)"
  fi
done

# ----------------------------------------------------------
# Step 4: Nerd Font (macOS only -- remote uses local terminal font)
# ----------------------------------------------------------
if [[ "$OS" == "macos" ]]; then
  step "Checking for Nerd Fonts..."

  if ls "$HOME/Library/Fonts"/JetBrainsMonoNerdFont-Regular.ttf &>/dev/null; then
    info "Nerd Font found in ~/Library/Fonts/"
  elif ls "$HOME/.local/share/fonts"/JetBrainsMonoNerdFont-Regular.ttf &>/dev/null; then
    info "Nerd Font found in ~/.local/share/fonts/, copying to ~/Library/Fonts/ for macOS apps..."
    mkdir -p "$HOME/Library/Fonts"
    cp "$HOME/.local/share/fonts"/JetBrainsMonoNerdFont-*.ttf "$HOME/Library/Fonts/"
    info "Fonts copied to ~/Library/Fonts/"
  else
    warn "No Nerd Font found. Installing via Homebrew..."
    brew install --cask font-jetbrains-mono-nerd-font || warn "Font install failed, install manually"
  fi
else
  info "Skipping Nerd Font install (remote machine -- your local terminal handles font rendering)"
fi

# ----------------------------------------------------------
# Step 5: Symlink configs
# ----------------------------------------------------------
step "Creating symlinks..."

# Neovim
if [ -d "$HOME/.config/nvim" ] || [ -L "$HOME/.config/nvim" ]; then
  if [ -L "$HOME/.config/nvim" ]; then
    info "Removing existing nvim symlink"
    rm "$HOME/.config/nvim"
  else
    warn "Backing up existing nvim config to ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  fi
fi
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
info "Linked: ~/.config/nvim -> $DOTFILES_DIR/nvim"

# TMUX
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  warn "Backing up existing .tmux.conf to ~/.tmux.conf.bak"
  mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
fi
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
info "Linked: ~/.tmux.conf -> $DOTFILES_DIR/tmux/.tmux.conf"

# WezTerm (macOS only -- no GUI on remote)
if [[ "$OS" == "macos" ]]; then
  if [ -f "$HOME/.wezterm.lua" ] && [ ! -L "$HOME/.wezterm.lua" ]; then
    warn "Backing up existing .wezterm.lua to ~/.wezterm.lua.bak"
    mv "$HOME/.wezterm.lua" "$HOME/.wezterm.lua.bak"
  fi
  ln -sf "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
  info "Linked: ~/.wezterm.lua -> $DOTFILES_DIR/wezterm/.wezterm.lua"
fi

# OpenCode
mkdir -p "$HOME/.opencode/config"
rm -f "$HOME/.opencode/config/opencode.json"
if [[ "$OS" == "macos" ]]; then
  cp "$DOTFILES_DIR/opencode/opencode.json" "$HOME/.opencode/config/opencode.json"
else
  # Remote machines use env vars for credentials (via ada cred serve + SSH port forwarding)
  cp "$DOTFILES_DIR/opencode/opencode.remote.json" "$HOME/.opencode/config/opencode.json"

  # Install opencode-remote wrapper script that fetches creds from ada cred serve
  cp "$DOTFILES_DIR/opencode/opencode-remote" "$HOME/.local/bin/opencode-remote"
  chmod +x "$HOME/.local/bin/opencode-remote"
  info "Installed opencode-remote wrapper to ~/.local/bin/opencode-remote"
fi
info "Copied OpenCode config to ~/.opencode/config/opencode.json"

# On remote/Ubuntu, add AWS env vars to shell RC for tools that support credential chain
if [[ "$OS" == "ubuntu" ]]; then
  AWS_ENVS='# AWS region for Bedrock
export AWS_REGION="us-east-1"'

  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q 'AWS_REGION.*us-east-1' "$rc"; then
      echo "" >> "$rc"
      echo "$AWS_ENVS" >> "$rc"
      info "Added AWS_REGION to $(basename "$rc")"
    fi
  done
fi

# ----------------------------------------------------------
# Step 6: Install TMUX Plugin Manager (tpm)
# ----------------------------------------------------------
step "Setting up TMUX plugins..."

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
  info "tpm already installed, updating..."
  git -C "$TPM_DIR" pull --quiet || warn "Could not update tpm (network issue?)"
else
  info "Cloning tpm..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install tmux plugins non-interactively
if [ -f "$TPM_DIR/bin/install_plugins" ]; then
  info "Installing tmux plugins..."
  TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins" "$TPM_DIR/bin/install_plugins" || warn "tmux plugin install had issues (may need tmux running)"
fi

# ----------------------------------------------------------
# Step 7: Headless Neovim install (plugins, parsers, LSPs)
# ----------------------------------------------------------
step "Installing Neovim plugins, treesitter parsers, and LSP servers..."

info "This will take a few minutes (downloading plugins, compiling parsers, installing LSPs)..."

# Pre-clone lazy.nvim from bash to guarantee it exists before Neovim starts.
# init.lua also clones it, but vim.fn.system() can silently fail in headless mode.
LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_DIR" ]; then
  info "Cloning lazy.nvim..."
  git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_DIR"
else
  info "lazy.nvim already cloned"
fi

# Step 7a: Sync plugins via lazy.nvim
# init.lua prepends lazy.nvim to rtp and calls require("lazy").setup().
# We then call sync() via Lua API (more reliable than the :Lazy ex command).
info "Syncing plugins..."
nvim --headless -c "lua require('lazy').sync({wait=true})" -c "qa" 2>&1 || true

# Step 7b: Install treesitter parsers
# Now that nvim-treesitter is downloaded, the config in treesitter.lua
# calls install.install(parsers) on startup. Just let it run + wait.
info "Compiling treesitter parsers (this takes ~60s)..."
nvim --headless -c "sleep 60" -c "qa" 2>&1 || true

# Step 7c: Install Mason packages (LSPs, formatters, debug adapters)
# Mason is now downloaded and loaded, so MasonInstall works.
info "Installing LSP servers and tools via Mason..."
nvim --headless -c "MasonInstall pyright clangd lua-language-server ruff black debugpy" -c "sleep 90" -c "qa" 2>&1 || true

info "Neovim setup complete"

# ----------------------------------------------------------
# Step 10: Install OpenCode if missing
# ----------------------------------------------------------
if ! command -v opencode &>/dev/null; then
  step "Installing OpenCode..."
  if command -v npm &>/dev/null; then
    $SUDO npm install -g opencode-ai 2>/dev/null || npm install -g opencode-ai 2>/dev/null || warn "OpenCode install failed. Install manually: https://opencode.ai"
  else
    warn "npm not available. Install OpenCode manually: https://opencode.ai"
  fi
else
  info "OpenCode already installed"
fi

# ----------------------------------------------------------
# Done!
# ----------------------------------------------------------
step "Setup complete!"

echo ""
echo -e "${BOLD}What's ready:${NC}"
echo "  - Neovim $(nvim --version | head -1)"
echo "  - TMUX $(tmux -V)"
if [[ "$OS" == "macos" ]]; then
  echo "  - WezTerm config at ~/.wezterm.lua"
fi
echo "  - Configs in ~/dotfiles/ (symlinked to proper locations)"
echo ""
echo -e "${BOLD}Quick start:${NC}"
if [[ "$OS" == "macos" ]]; then
  echo "  1. Open WezTerm (restart it to pick up new config)"
  echo "  2. Start tmux:          tmux new -s dev"
else
  echo "  1. Start tmux:          tmux new -s dev"
fi
echo "  3. Open Neovim:         nvim"
echo "  4. Split for OpenCode:  prefix(Ctrl+a) + |"
echo "  5. Run OpenCode:        opencode"
echo ""
echo -e "${BOLD}Or use sidekick.nvim inside Neovim:${NC}"
echo "  <Space>aa  - Toggle OpenCode panel"
echo "  <Space>ff  - Find files"
echo "  <Space>fl  - Live grep"
echo "  <Space>e   - File explorer"
echo ""
echo -e "${BOLD}Key bindings cheatsheet:${NC}"
echo "  <Space>    - Leader key"
echo "  <Space>ff  - Find files (Ctrl+P equivalent)"
echo "  <Space>fl  - Live grep (Ctrl+Shift+F equivalent)"
echo "  <Space>fb  - Search current buffer"
echo "  <Space>fs  - Document symbols"
echo "  gd         - Go to definition"
echo "  gr         - Find references"
echo "  K          - Hover docs"
echo "  ]f / [f    - Next/prev function"
echo "  ]d / [d    - Next/prev diagnostic"
echo "  <Space>aa  - Toggle OpenCode"
echo "  Ctrl+h/j/k/l - Navigate between panes (vim + tmux)"
echo ""
echo -e "${BOLD}Git conflict & diff:${NC}"
echo "  co / ct / cb / c0 - Accept ours/theirs/both/none (in conflict)"
echo "  ]x / [x           - Next/prev conflict"
echo "  <Space>gd          - Open diffview"
echo "  <Space>gf          - File history"
echo ""
echo -e "${BOLD}Debugging (Python):${NC}"
echo "  <Space>db  - Toggle breakpoint"
echo "  <Space>dB  - Conditional breakpoint"
echo "  <Space>dc  - Continue / Start debugging"
echo "  <Space>di  - Step into"
echo "  <Space>do  - Step over"
echo "  <Space>dO  - Step out"
echo "  <Space>du  - Toggle DAP UI"
echo "  <Space>dt  - Terminate debug session"
echo ""
if [[ "$OS" == "macos" ]]; then
  info "Restart WezTerm to apply the new terminal config."
else
  info "SSH in from WezTerm for Nerd Font icon support."
fi
info "Happy coding!"
