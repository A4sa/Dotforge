#!/usr/bin/env bash
# ============================================================================
#  File name   : install.sh
#  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
#  Repository  : https://github.com/A4sa/dotforge.git
#  Description : Install the dotforge developer workspace on a Linux machine.
#                Copies config files, creates required directories, installs
#                vim-plug, and optionally installs missing dependencies.
#
#  USAGE
#  -----
#    chmod +x scripts/install.sh
#    ./scripts/install.sh
#
#  WHAT THIS SCRIPT DOES
#  ---------------------
#    1. Check required tools are present (ask to install missing ones)
#    2. Backup any existing config files before overwriting
#    3. Copy vim configs  → ~/.vimrc, ~/.vim/
#    4. Copy tmux config  → ~/.tmux.conf
#    5. Copy shell config → ~/.bash_aliases, ~/.bash_functions
#    6. Append dotforge loader to ~/.bashrc
#    7. Create required directories (~/.vim/undodir, ~/.vim/UltiSnips)
#    8. Install vim-plug
#    9. Install Vim plugins headlessly
#   10. Print a summary of what was done
#
#  COPY vs SYMLINK
#  ---------------
#    Files are COPIED, not symlinked.
#    After install, your ~/.vimrc is independent from the dotforge repo.
#    To get updates from the repo, run: ./scripts/update.sh
#
# ============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────

RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'

info()    { echo -e "${CYAN}[dotforge]${RESET} $*"; }
success() { echo -e "${GREEN}[dotforge]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[dotforge]${RESET} $*"; }
error()   { echo -e "${RED}[dotforge] ERROR:${RESET} $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}── $* ──────────────────────────────────────${RESET}"; }
ask()     { echo -e "${YELLOW}[dotforge]${RESET} $*"; }


# ── Resolve paths ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFORGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$HOME/.dotforge_backup/$(date +%Y-%m-%d_%H-%M-%S)"

# Source locations (inside the repo)
VIM_DIR="$DOTFORGE_ROOT/vim"
SHELL_DIR="$DOTFORGE_ROOT/shell"
TMUX_DIR="$DOTFORGE_ROOT/tmux"

# Destination locations (on the machine)
DEST_VIMRC="$HOME/.vimrc"
DEST_VIM="$HOME/.vim"
DEST_TMUX="$HOME/.tmux.conf"
DEST_ALIASES="$HOME/.bash_aliases"
DEST_FUNCTIONS="$HOME/.bash_functions"
DEST_BASHRC="$HOME/.bashrc"


# ── Dependencies ──────────────────────────────────────────────────────────────

# Tools required by dotforge and the plugins it configures
DEPS=(
    "vim-gtk3:vim"            # Vim with +clipboard and +python3 (UltiSnips)
    "tmux:tmux"               # Terminal multiplexer
    "git:git"                 # Version control (Fugitive plugin)
    "curl:curl"               # vim-plug bootstrap
    "fzf:fzf"                 # Fuzzy finder (Ctrl+P in Vim, Ctrl+R in shell)
    "rg:ripgrep"              # Content search (:Rg in Vim)
    "batcat:bat"              # File preview (ff alias) — Ubuntu names it batcat
    "ctags:universal-ctags"   # Code navigation (Tagbar plugin)
    "cscope:cscope"           # Symbol navigation (kernel/BSP)
    "clang-format:clang-format" # C auto-format on save
    "picocom:picocom"         # Serial console
    "xclip:xclip"             # Clipboard bridge for tmux copy-mode
)

check_deps() {
    step "Checking dependencies"

    local missing=()
    local missing_pkgs=()

    for entry in "${DEPS[@]}"; do
        local bin="${entry%%:*}"
        local pkg="${entry##*:}"
        if ! command -v "$bin" &>/dev/null; then
            missing+=("$bin")
            missing_pkgs+=("$pkg")
            warn "Missing: ${BOLD}${bin}${RESET} (package: ${pkg})"
        else
            success "Found:   ${bin}"
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        success "All dependencies satisfied."
        return
    fi

    echo ""
    ask "Missing ${#missing[@]} package(s): ${missing_pkgs[*]}"
    ask "Install them now with apt? [y/N]"
    read -r confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        info "Installing missing packages..."
        sudo apt-get update -qq 2>&1 | grep -v "^W:" || true
        sudo apt-get install -y "${missing_pkgs[@]}"

        # bat is installed as batcat on Ubuntu — create symlink
        if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
            sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
            info "Created symlink: bat → batcat"
        fi

        success "Packages installed."
    else
        warn "Skipping package install. Some features may not work."
        warn "Install manually: sudo apt install ${missing_pkgs[*]}"
    fi
}


# ── Backup ────────────────────────────────────────────────────────────────────

backup_file() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$target" "$BACKUP_DIR/"
        info "Backed up: ${target} → ${BACKUP_DIR}/"
    fi
}


# ── Copy helpers ──────────────────────────────────────────────────────────────

copy_file() {
    local src="$1"
    local dst="$2"

    if [ ! -f "$src" ]; then
        warn "Source not found, skipping: $src"
        return
    fi

    backup_file "$dst"
    cp "$src" "$dst"
    success "Copied: $(basename "$src") → $dst"
}

copy_dir() {
    local src="$1"
    local dst="$2"

    if [ ! -d "$src" ]; then
        warn "Source directory not found, skipping: $src"
        return
    fi

    backup_file "$dst"
    cp -r "$src" "$dst"
    success "Copied: $(basename "$src")/ → $dst/"
}


# ── Install steps ─────────────────────────────────────────────────────────────

install_vim() {
    step "Installing Vim config"

    # Create ~/.vim directory structure
    mkdir -p "$DEST_VIM"
    mkdir -p "$DEST_VIM/undodir"       # persistent undo (set undodir in vimrc)
    mkdir -p "$DEST_VIM/UltiSnips"     # snippet files

    # Copy main vimrc
    copy_file "$VIM_DIR/vimrc"             "$DEST_VIMRC"

    # Copy plugin and key mapping files into ~/.vim/
    copy_file "$VIM_DIR/plugin_config.vim" "$DEST_VIM/plugin_config.vim"
    copy_file "$VIM_DIR/key_mapping.vim"   "$DEST_VIM/key_mapping.vim"

    # Copy UltiSnips snippets
    copy_file "$VIM_DIR/snippets/c.snippets"      "$DEST_VIM/UltiSnips/c.snippets"
    copy_file "$VIM_DIR/snippets/python.snippets"  "$DEST_VIM/UltiSnips/python.snippets"

    success "Vim config installed."
}

install_vim_plug() {
    step "Installing vim-plug"

    local plug_path="$DEST_VIM/autoload/plug.vim"

    if [ -f "$plug_path" ]; then
        info "vim-plug already installed — skipping download."
        return
    fi

    if ! command -v curl &>/dev/null; then
        warn "curl not found — cannot install vim-plug. Install curl first."
        return
    fi

    mkdir -p "$DEST_VIM/autoload"
    curl -fLo "$plug_path" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    success "vim-plug installed: $plug_path"
}

install_vim_plugins() {
    step "Installing Vim plugins"

    if ! command -v vim &>/dev/null; then
        warn "vim not found — skipping plugin install."
        return
    fi

    info "Running :PlugInstall headlessly (this may take a minute)..."
    vim -E -s -u "$DEST_VIMRC" +PlugInstall +qall 2>/dev/null || true

    success "Vim plugins installed."
}

install_tmux() {
    step "Installing tmux config"

    copy_file "$TMUX_DIR/tmux.conf" "$DEST_TMUX"

    success "tmux config installed."
}

install_shell() {
    step "Installing shell config"

    copy_file "$SHELL_DIR/bash_aliases"   "$DEST_ALIASES"
    copy_file "$SHELL_DIR/bash_functions" "$DEST_FUNCTIONS"

    success "Shell config installed."
}

install_bashrc_append() {
    step "Configuring ~/.bashrc"

    local marker="# dotforge"
    local loader="source \"\$HOME/dotforge/shell/bashrc_append\""

    # Check if already added
    if grep -qF "$marker" "$DEST_BASHRC" 2>/dev/null; then
        info "dotforge already present in ~/.bashrc — skipping."
        return
    fi

    # Append the loader block
    cat >> "$DEST_BASHRC" << EOF

${marker} — load developer workspace
if [ -f "${SHELL_DIR}/bashrc_append" ]; then
    source "${SHELL_DIR}/bashrc_append"
fi
EOF

    success "dotforge loader appended to ~/.bashrc"
    info "Run 'source ~/.bashrc' to activate in this session."
}

create_bash_local_template() {
    step "Creating ~/.bash_local template"

    local bash_local="$HOME/.bash_local"

    if [ -f "$bash_local" ]; then
        info "~/.bash_local already exists — skipping."
        return
    fi

    cat > "$bash_local" << 'EOF'
# ============================================================================
#  ~/.bash_local — machine-specific config (NOT committed to the repo)
#
#  Add your personal project paths, toolchain settings, and private aliases
#  here. This file is sourced automatically by bashrc_append.
# ============================================================================

# Project directories — uncomment and edit to match your machine
# alias sdk='cd ~/path/to/your/sdk'
# alias work='cd ~/Workspace/'

# Device Tree shortcuts
# alias dts='vim ./boards/your-board/bsp/your-board.dts'

# Cross-compile toolchain (auto-set on login)
# xc arm64 aarch64-linux-gnu

# Environment setup scripts
# alias snpe='source bin/envsetup.sh'
EOF

    success "Created ~/.bash_local template — edit it with your project paths."
}


# ── Summary ───────────────────────────────────────────────────────────────────

print_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}============================================${RESET}"
    echo -e "${GREEN}${BOLD}  dotforge installed successfully          ${RESET}"
    echo -e "${GREEN}${BOLD}============================================${RESET}"
    echo ""
    echo -e "  ${BOLD}Installed:${RESET}"
    echo "    ~/.vimrc                   Vim config"
    echo "    ~/.vim/plugin_config.vim   Plugin declarations + config"
    echo "    ~/.vim/key_mapping.vim     All key mappings"
    echo "    ~/.vim/UltiSnips/          C and Python snippets"
    echo "    ~/.vim/undodir/            Persistent undo storage"
    echo "    ~/.tmux.conf               tmux config"
    echo "    ~/.bash_aliases            Shell aliases"
    echo "    ~/.bash_functions          Shell functions"
    echo "    ~/.bash_local              Machine-specific template"
    echo ""
    if [ -d "$BACKUP_DIR" ]; then
    echo -e "  ${BOLD}Backups saved to:${RESET}"
    echo "    $BACKUP_DIR"
    echo ""
    fi
    echo -e "  ${BOLD}Next steps:${RESET}"
    echo "    source ~/.bashrc           Activate shell config now"
    echo "    vim                        Open Vim (plugins ready)"
    echo "    tmux new -s dev            Start a tmux session"
    echo "    nano ~/.bash_local         Add your project paths"
    echo ""
    echo -e "  ${BOLD}To update later:${RESET}"
    echo "    ./scripts/update.sh"
    echo ""
    echo -e "  ${BOLD}To uninstall:${RESET}"
    echo "    ./scripts/uninstall.sh"
    echo ""
}


# ── Main ──────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BOLD}dotforge — Developer Workspace Installer${RESET}"
    echo -e "──────────────────────────────────────────"
    echo -e "  Repo   : $DOTFORGE_ROOT"
    echo -e "  User   : $USER"
    echo -e "  Home   : $HOME"
    echo ""

    check_deps
    install_vim
    install_vim_plug
    install_vim_plugins
    install_tmux
    install_shell
    install_bashrc_append
    create_bash_local_template
    print_summary
}

main "$@"
