#!/usr/bin/env bash
# ============================================================================
#  File name   : uninstall.sh
#  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
#  Repository  : https://github.com/A4sa/dotforge.git
#  Description : Remove all files installed by dotforge and restore backups
#                if they exist.
#
#  USAGE
#  -----
#    ./scripts/uninstall.sh
#
#  WHAT THIS SCRIPT REMOVES
#  ------------------------
#    ~/.vimrc
#    ~/.vim/plugin_config.vim
#    ~/.vim/key_mapping.vim
#    ~/.vim/UltiSnips/c.snippets
#    ~/.vim/UltiSnips/python.snippets
#    ~/.vim/undodir/
#    ~/.vim/plugged/          (installed plugins)
#    ~/.vim/autoload/plug.vim (vim-plug)
#    ~/.tmux.conf
#    ~/.bash_aliases
#    ~/.bash_functions
#    dotforge loader block from ~/.bashrc
#
#  WHAT THIS SCRIPT DOES NOT REMOVE
#  ---------------------------------
#    ~/.bash_local            (your private machine config — never touched)
#    The dotforge repo itself (just rm -rf dotforge/ manually if needed)
#    System packages (vim, tmux, fzf etc — installed separately)
#
# ============================================================================

set -euo pipefail

RESET='\033[0m'; BOLD='\033[1m'
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; RED='\033[0;31m'

info()    { echo -e "${CYAN}[dotforge]${RESET} $*"; }
success() { echo -e "${GREEN}[dotforge]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[dotforge]${RESET} $*"; }
error()   { echo -e "${RED}[dotforge] ERROR:${RESET} $*" >&2; exit 1; }
step()    { echo -e "\n${BOLD}── $* ──────────────────────────────────────${RESET}"; }

BACKUP_BASE="$HOME/.dotforge_backup"
DEST_BASHRC="$HOME/.bashrc"


# ── Confirmation ──────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}dotforge — Uninstaller${RESET}"
echo -e "───────────────────────"
echo ""
warn "This will remove all dotforge config files from your home directory."
warn "Your ~/.bash_local will NOT be touched."
echo ""
read -rp "Are you sure you want to uninstall dotforge? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { info "Uninstall cancelled."; exit 0; }
echo ""


# ── Remove helper ─────────────────────────────────────────────────────────────

remove_file() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
        success "Removed: $target"
    else
        info "Not found (skipping): $target"
    fi
}


# ── Step 1: Remove Vim config files ───────────────────────────────────────────

step "Removing Vim config"

remove_file "$HOME/.vimrc"
remove_file "$HOME/.vim/plugin_config.vim"
remove_file "$HOME/.vim/key_mapping.vim"
remove_file "$HOME/.vim/UltiSnips/c.snippets"
remove_file "$HOME/.vim/UltiSnips/python.snippets"
remove_file "$HOME/.vim/undodir"
remove_file "$HOME/.vim/plugged"
remove_file "$HOME/.vim/autoload/plug.vim"


# ── Step 2: Remove tmux config ────────────────────────────────────────────────

step "Removing tmux config"
remove_file "$HOME/.tmux.conf"


# ── Step 3: Remove shell config files ─────────────────────────────────────────

step "Removing shell config"
remove_file "$HOME/.bash_aliases"
remove_file "$HOME/.bash_functions"


# ── Step 4: Remove dotforge block from ~/.bashrc ──────────────────────────────

step "Cleaning ~/.bashrc"

if grep -qF "# dotforge" "$DEST_BASHRC" 2>/dev/null; then
    # Remove the dotforge block — from the marker line to the fi line after it
    sed -i '/# dotforge/,/^fi$/d' "$DEST_BASHRC"
    # Also remove any blank line left behind just before the block
    sed -i '/^$/N;/^\n$/d' "$DEST_BASHRC"
    success "dotforge loader removed from ~/.bashrc"
else
    info "No dotforge block found in ~/.bashrc — skipping."
fi


# ── Step 5: Restore backups (optional) ────────────────────────────────────────

step "Checking for backups"

if [ -d "$BACKUP_BASE" ]; then
    # Find the most recent backup
    latest_backup=$(ls -td "$BACKUP_BASE"/*/  2>/dev/null | head -1)

    if [ -n "$latest_backup" ]; then
        info "Found backup: $latest_backup"
        read -rp "  Restore most recent backup? [y/N] " restore_confirm

        if [[ "$restore_confirm" =~ ^[Yy]$ ]]; then
            for f in "$latest_backup"/*; do
                filename=$(basename "$f")
                dest="$HOME/$filename"
                cp -r "$f" "$dest"
                success "Restored: $dest"
            done
        else
            info "Backup not restored. Available at: $latest_backup"
        fi
    fi
else
    info "No backups found."
fi


# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}============================================${RESET}"
echo -e "${GREEN}${BOLD}  dotforge uninstalled successfully        ${RESET}"
echo -e "${GREEN}${BOLD}============================================${RESET}"
echo ""
echo "  Removed: Vim config, tmux config, shell aliases and functions"
echo "  Kept:    ~/.bash_local (your private machine config)"
echo "  Kept:    System packages (vim, tmux, fzf, etc.)"
echo ""
echo "  Run 'source ~/.bashrc' to reload your shell."
echo ""
echo "  To reinstall: ./scripts/install.sh"
echo ""
