#!/usr/bin/env bash
# ============================================================================
#  File name   : install.sh
#  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
#  Repository  : https://github.com/A4sa/dotforge.git
#  Description : Install the Dotforge developer workspace on a Linux machine.
#                Links config files, creates required directories, installs
#                vim-plug + plugins, and optionally installs missing tools.
#
#  USAGE
#  -----
#    ./scripts/install.sh            interactive
#    ./scripts/install.sh -y         answer yes to every question
#    ./scripts/install.sh --no-deps  skip the package check (used by update.sh)
#
#  WHAT THIS SCRIPT DOES
#  ---------------------
#    1. Check required tools (offer to install missing ones: apt/dnf/pacman)
#    2. Back up existing config files that would be replaced
#    3. Symlink vim, tmux and snippet files from the repo into $HOME
#    4. Add ONE marked block to ~/.bashrc that sources shell/bashrc_append
#    5. Create ~/.vim/{undodir,swap,backup,UltiSnips}
#    6. Install vim-plug and the Vim plugins
#    7. Create a ~/.bash_local template (never overwritten)
#
#  SYMLINKS, NOT COPIES
#  --------------------
#    ~/.vimrc, ~/.tmux.conf, ... point into this repo. 'git pull' (or
#    ./scripts/update.sh) updates everything at once, and re-running this
#    script is safe: files that already point into the repo are skipped,
#    so backups only ever contain YOUR original files.
#    Keep the repo where you cloned it (move it → run install.sh again).
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


# ── Options ───────────────────────────────────────────────────────────────────

ASSUME_YES=0
SKIP_DEPS=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes)   ASSUME_YES=1 ;;
        --no-deps)  SKIP_DEPS=1 ;;
        -h|--help)  sed -n '2,35p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)          error "Unknown option: $arg  (see --help)" ;;
    esac
done

# confirm "question" → 0 for yes. Defaults to NO when there is no terminal.
confirm() {
    [ "$ASSUME_YES" = 1 ] && return 0
    [ -t 0 ] || return 1
    local reply
    read -rp "$(echo -e "${YELLOW}[dotforge]${RESET} $1 [y/N] ")" reply
    [[ "$reply" =~ ^[Yy]$ ]]
}


# ── Resolve paths ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFORGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_BASE="$HOME/.dotforge_backup"
BACKUP_DIR="$BACKUP_BASE/$(date +%Y-%m-%d_%H-%M-%S)"
DEST_BASHRC="$HOME/.bashrc"

# repo file → link in $HOME
LINKS=(
    "vim/vimrc|.vimrc"
    "vim/plugin_config.vim|.vim/plugin_config.vim"
    "vim/key_mapping.vim|.vim/key_mapping.vim"
    "vim/snippets/c.snippets|.vim/UltiSnips/c.snippets"
    "vim/snippets/python.snippets|.vim/UltiSnips/python.snippets"
    "vim/snippets/make.snippets|.vim/UltiSnips/make.snippets"
    "tmux/tmux.conf|.tmux.conf"
    "tmux/clip.sh|.local/bin/dotforge-clip"      # tmux copy → desktop clipboard
)

BASHRC_BEGIN="# >>> dotforge >>>"
BASHRC_END="# <<< dotforge <<<"


# ── Dependencies ──────────────────────────────────────────────────────────────
#
# Format:  command[|alternative]:apt-package:dnf-package:pacman-package
# A command is "present" if any of its alternatives is in PATH.

DEPS=(
    "vim:vim-gtk3:vim-enhanced:gvim"                 # +python3 (UltiSnips), +clipboard
    "tmux:tmux:tmux:tmux"
    "git:git:git:git"
    "curl:curl:curl:curl"                            # vim-plug bootstrap
    "fzf:fzf:fzf:fzf"                                # Ctrl+P in Vim, Ctrl+R in shell
    "rg:ripgrep:ripgrep:ripgrep"                     # :Rg, fast file lists
    "bat|batcat:bat:bat:bat"                         # previews (Debian names it batcat)
    "ctags:universal-ctags:ctags:ctags"              # Tagbar, :Tags
    "cscope:cscope:cscope:cscope"                    # kernel symbol navigation
    "clang-format:clang-format:clang-tools-extra:clang"
    "clangd:clangd:clang-tools-extra:clang"          # LSP go-to-definition
    "bear:bear:bear:bear"                            # compile_commands.json for non-kernel projects
    "dtc:device-tree-compiler:dtc:dtc"               # dtsdump, DT overlays
    "picocom:picocom:picocom:picocom"                # serial console (con)
    "xclip:xclip:xclip:xclip"                        # tmux/Vim clipboard on X11
)
# Wayland sessions need wl-clipboard: xclip only reaches Wayland apps through
# XWayland, which is unreliable.
[ -n "${WAYLAND_DISPLAY:-}" ] && DEPS+=("wl-copy:wl-clipboard:wl-clipboard:wl-clipboard")

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then echo apt
    elif command -v dnf &>/dev/null; then echo dnf
    elif command -v pacman &>/dev/null; then echo pacman
    else echo none
    fi
}

check_deps() {
    step "Checking dependencies"

    local pm
    pm=$(detect_pkg_manager)
    local -a missing_pkgs=()
    local -A seen=()

    local entry bins pkg found bin
    for entry in "${DEPS[@]}"; do
        IFS=':' read -r bins apt_pkg dnf_pkg pac_pkg <<< "$entry"
        found=""
        IFS='|' read -ra alts <<< "$bins"
        for bin in "${alts[@]}"; do
            command -v "$bin" &>/dev/null && { found="$bin"; break; }
        done
        case "$pm" in
            apt)    pkg="$apt_pkg" ;;
            dnf)    pkg="$dnf_pkg" ;;
            pacman) pkg="$pac_pkg" ;;
            *)      pkg="$apt_pkg" ;;
        esac
        if [ -n "$found" ]; then
            success "Found:   ${found}"
        else
            warn "Missing: ${BOLD}${alts[0]}${RESET} (package: ${pkg})"
            if [ -z "${seen[$pkg]:-}" ]; then
                missing_pkgs+=("$pkg")
                seen[$pkg]=1
            fi
        fi
    done

    # Vim features the config relies on.
    if command -v vim &>/dev/null; then
        local vv
        vv=$(vim --version)
        grep -q '+python3' <<< "$vv" \
            || warn "vim has no +python3 — snippets (UltiSnips) disabled. Install vim-gtk3 / vim-nox."
        grep -q '+clipboard' <<< "$vv" \
            || warn "vim has no +clipboard — <Leader>y/p use only Vim registers. Install vim-gtk3."
    fi

    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        success "All dependencies satisfied."
        return
    fi

    if [ "$pm" = none ]; then
        warn "No apt/dnf/pacman found. Install manually: ${missing_pkgs[*]}"
        return
    fi

    echo ""
    if confirm "Install ${#missing_pkgs[@]} missing package(s) with ${pm}: ${missing_pkgs[*]} ?"; then
        info "Installing missing packages..."
        case "$pm" in
            apt)
                # A broken third-party repo must not abort the whole install.
                sudo apt-get update -qq || warn "apt-get update reported errors — continuing"
                # Install one by one so a single unavailable package
                # (e.g. bear on an old release) doesn't block the rest.
                for pkg in "${missing_pkgs[@]}"; do
                    sudo apt-get install -y "$pkg" || warn "Could not install $pkg"
                done
                ;;
            dnf)
                for pkg in "${missing_pkgs[@]}"; do
                    sudo dnf install -y "$pkg" || warn "Could not install $pkg"
                done
                ;;
            pacman)
                sudo pacman -Syu --needed --noconfirm "${missing_pkgs[@]}" || warn "pacman reported errors"
                ;;
        esac
        success "Package step done."
    else
        warn "Skipping package install. Some features may not work."
    fi
}


# ── Backup & link helpers ─────────────────────────────────────────────────────

# Back up a file or directory, keeping its path relative to $HOME, so that
# uninstall.sh can put it back exactly where it was.
backup_path() {
    local target="$1"
    [ -e "$target" ] || [ -L "$target" ] || return 0
    local rel="${target#"$HOME"/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    cp -a "$target" "$BACKUP_DIR/$rel"
    info "Backed up: ~/${rel} → ${BACKUP_DIR/#$HOME/\~}/"
}

# Symlink a repo file into $HOME. Skips links that are already correct.
link_file() {
    local src="$DOTFORGE_ROOT/$1"
    local dst="$HOME/$2"

    if [ ! -f "$src" ]; then
        warn "Source not found, skipping: $src"
        return
    fi
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        info "Already linked: ~/$2"
        return
    fi

    mkdir -p "$(dirname "$dst")"
    backup_path "$dst"
    rm -rf "$dst"
    ln -s "$src" "$dst"
    success "Linked: ~/$2 → $1"
}


# ── Install steps ─────────────────────────────────────────────────────────────

install_links() {
    step "Linking config files"
    mkdir -p "$HOME/.vim"/{undodir,swap,backup,UltiSnips}
    chmod 700 "$HOME/.vim"/{undodir,swap,backup}

    local pair
    for pair in "${LINKS[@]}"; do
        link_file "${pair%%|*}" "${pair##*|}"
    done
}

# Older dotforge versions COPIED shell files into $HOME. Ubuntu's stock
# ~/.bashrc also sources ~/.bash_aliases, so those stale copies would load
# on top of the repo version. Move them out of the way.
migrate_legacy() {
    local f
    for f in "$HOME/.bash_aliases" "$HOME/.bash_functions"; do
        if [ -f "$f" ] && [ ! -L "$f" ] && grep -q "github.com/A4sa" "$f" 2>/dev/null; then
            backup_path "$f"
            rm -f "$f"
            info "Removed old dotforge copy: ~/${f##*/} (now loaded from the repo)"
        fi
    done
}

install_bashrc_block() {
    step "Configuring ~/.bashrc"

    touch "$DEST_BASHRC"
    local loader="$DOTFORGE_ROOT/shell/bashrc_append"
    local block
    block=$(printf '%s\n[ -f "%s" ] && source "%s"\n%s' \
        "$BASHRC_BEGIN" "$loader" "$loader" "$BASHRC_END")

    if grep -qF "$BASHRC_BEGIN" "$DEST_BASHRC"; then
        # Block exists — rewrite it only if the repo path changed.
        if grep -qF "source \"$loader\"" "$DEST_BASHRC"; then
            info "dotforge block already in ~/.bashrc — skipping."
            return
        fi
        backup_path "$DEST_BASHRC"
        sed -i "/^${BASHRC_BEGIN}\$/,/^${BASHRC_END}\$/d" "$DEST_BASHRC"
    else
        backup_path "$DEST_BASHRC"
    fi

    # Remove the block written by older versions ("# Dotforge — load ...").
    if grep -q '^# Dotforge — load developer workspace' "$DEST_BASHRC"; then
        sed -i '/^# Dotforge — load developer workspace$/,/^fi$/d' "$DEST_BASHRC"
        info "Replaced the old-style dotforge block."
    fi

    printf '\n%s\n' "$block" >> "$DEST_BASHRC"
    success "dotforge loader added to ~/.bashrc"
}

install_vim_plug() {
    step "Installing vim-plug"

    local plug_path="$HOME/.vim/autoload/plug.vim"
    if [ -f "$plug_path" ]; then
        info "vim-plug already installed — skipping download."
        return
    fi
    if ! command -v curl &>/dev/null; then
        warn "curl not found — Vim will download vim-plug on first start once curl exists."
        return
    fi
    if curl -fsSLo "$plug_path" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
        success "vim-plug installed: $plug_path"
    else
        warn "vim-plug download failed — Vim will retry on first start."
    fi
}

install_vim_plugins() {
    step "Installing Vim plugins"

    if ! command -v vim &>/dev/null; then
        warn "vim not found — skipping plugin install."
        return
    fi
    # vim-plug needs a real terminal (it does not run in 'vim -es' mode).
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        warn "No terminal — plugins will install on the first 'vim' start."
        return
    fi
    info "Running :PlugInstall (this may take a minute)..."
    vim -N -u "$HOME/.vimrc" -i NONE +'PlugInstall --sync' +'qall!' </dev/tty >/dev/tty 2>&1 \
        || warn "PlugInstall reported an error — open vim and run :PlugInstall"
    success "Vim plugins installed."
}

create_bash_local_template() {
    step "Creating ~/.bash_local template"

    local bash_local="$HOME/.bash_local"
    if [ -f "$bash_local" ]; then
        # shellcheck disable=SC2088  # literal '~' is for display
        info "~/.bash_local already exists — skipping."
        return
    fi

    cat > "$bash_local" << 'EOF'
# ============================================================================
#  ~/.bash_local — machine-specific config (NOT committed to the repo)
#
#  Sourced LAST by dotforge's bashrc_append, so anything here overrides it.
# ============================================================================

# Project directories — uncomment and edit to match your machine
# alias sdk='cd ~/path/to/your/sdk'
# alias work='cd ~/Workspace/'

# Device Tree shortcuts
# alias dts='vim ./arch/arm64/boot/dts/vendor/your-board.dts'

# Cross-compile toolchain.
# Prefer a per-tree .envrc with direnv (export ARCH=... CROSS_COMPILE=...):
# an ARCH exported in every shell also breaks native builds.
# xc arm64 aarch64-linux-gnu

# Default serial console for 'con' (by-id names survive re-plugging):
# alias con='con usb-FTDI_FT232R_USB_UART_A12345-if00-port0 1500000'

# Environment setup scripts
# alias yocto='source poky/oe-init-build-env build'
EOF

    success "Created ~/.bash_local template — edit it with your project paths."
}

check_git_identity() {
    if ! git config user.name &>/dev/null; then
        warn "git user.name is not set — snippets fill MODULE_AUTHOR from it:"
        warn "  git config --global user.name  \"Your Name\""
        warn "  git config --global user.email \"you@example.com\""
    fi
}


# ── Summary ───────────────────────────────────────────────────────────────────

print_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}============================================${RESET}"
    echo -e "${GREEN}${BOLD}  dotforge installed successfully           ${RESET}"
    echo -e "${GREEN}${BOLD}============================================${RESET}"
    echo ""
    echo -e "  ${BOLD}Linked into \$HOME (→ $DOTFORGE_ROOT):${RESET}"
    local pair
    for pair in "${LINKS[@]}"; do
        printf '    ~/%-32s → %s\n' "${pair##*|}" "${pair%%|*}"
    done
    echo "    ~/.bashrc  (one marked block sources shell/bashrc_append)"
    echo ""
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "  ${BOLD}Your previous files were backed up to:${RESET}"
        echo "    $BACKUP_DIR"
        echo ""
    fi
    echo -e "  ${BOLD}Next steps:${RESET}"
    echo "    source ~/.bashrc           Activate shell config now"
    echo "    vim                        Open Vim"
    echo "    tmux new -s dev            Start a tmux session (Prefix+A: BSP layout)"
    echo "    vim ~/.bash_local          Add your project paths"
    echo ""
    echo -e "  ${BOLD}Update:${RESET}     ./scripts/update.sh"
    echo -e "  ${BOLD}Uninstall:${RESET}  ./scripts/uninstall.sh"
    echo ""
}


# ── Main ──────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BOLD}dotforge — Developer Workspace Installer${RESET}"
    echo -e "──────────────────────────────────────────"
    echo -e "  Repo   : $DOTFORGE_ROOT"
    echo -e "  User   : ${USER:-$(id -un)}"
    echo -e "  Home   : $HOME"

    [ "$SKIP_DEPS" = 1 ] || check_deps
    install_links
    migrate_legacy
    install_bashrc_block
    create_bash_local_template
    install_vim_plug
    install_vim_plugins
    check_git_identity
    print_summary
}

main
