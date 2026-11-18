#!/usr/bin/env bash
# ============================================================================
#  File name   : uninstall.sh
#  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
#  Repository  : https://github.com/A4sa/dotforge.git
#  Description : Remove everything dotforge installed and optionally restore
#                your original files from a backup.
#
#  USAGE
#  -----
#    ./scripts/uninstall.sh
#
#  WHAT THIS SCRIPT REMOVES
#  ------------------------
#    Symlinks that point into this repo (~/.vimrc, ~/.tmux.conf,
#      ~/.vim/*.vim, ~/.vim/UltiSnips/*.snippets) — never a real file
#    ~/.vim/plugged/ and ~/.vim/autoload/plug.vim   (asks first)
#    The marked dotforge block in ~/.bashrc         (nothing else is touched)
#
#  WHAT THIS SCRIPT DOES NOT REMOVE
#  ---------------------------------
#    ~/.bash_local            (your private machine config)
#    ~/.vim/undodir, swap     (your undo history and swap files)
#    The dotforge repo itself (rm -rf it manually if needed)
#    System packages
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFORGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEST_BASHRC="$HOME/.bashrc"
BASHRC_BEGIN="# >>> dotforge >>>"
BASHRC_END="# <<< dotforge <<<"

# Current backup location, plus the one used by older versions.
BACKUP_BASES=("$HOME/.dotforge_backup" "$HOME/.Dotforge_backup")


# ── Confirmation ──────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}dotforge — Uninstaller${RESET}"
echo -e "───────────────────────"
echo ""
warn "This removes dotforge's links and its ~/.bashrc block."
warn "Your ~/.bash_local and undo history are NOT touched."
echo ""
read -rp "Are you sure you want to uninstall dotforge? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { info "Uninstall cancelled."; exit 0; }


# ── Step 1: Remove links that point into the repo ─────────────────────────────

step "Removing config links"

# Remove a path only if it is a symlink into this repo — a real file there
# is yours (or a restored backup) and is left alone.
remove_link() {
    local target="$1"
    if [ -L "$target" ]; then
        case "$(readlink -f "$target")" in
            "$DOTFORGE_ROOT"/*)
                rm -f "$target"
                success "Removed: ${target/#$HOME/\~}"
                return ;;
        esac
        info "Not a dotforge link (kept): ${target/#$HOME/\~}"
    elif [ -e "$target" ]; then
        info "Real file, not a dotforge link (kept): ${target/#$HOME/\~}"
    fi
}

for f in .vimrc .tmux.conf .vim/plugin_config.vim .vim/key_mapping.vim \
         .vim/UltiSnips/c.snippets .vim/UltiSnips/python.snippets \
         .vim/UltiSnips/make.snippets; do
    remove_link "$HOME/$f"
done

echo ""
read -rp "  Also remove Vim plugins (~/.vim/plugged, vim-plug)? [y/N] " rm_plugins
if [[ "$rm_plugins" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.vim/plugged" "$HOME/.vim/autoload/plug.vim"
    success "Removed Vim plugins."
fi


# ── Step 2: Remove the dotforge block from ~/.bashrc ──────────────────────────

step "Cleaning ~/.bashrc"

if [ -f "$DEST_BASHRC" ] && grep -qF "$BASHRC_BEGIN" "$DEST_BASHRC"; then
    cp -a "$DEST_BASHRC" "$DEST_BASHRC.dotforge-uninstall.bak"
    sed -i "/^${BASHRC_BEGIN}\$/,/^${BASHRC_END}\$/d" "$DEST_BASHRC"
    success "dotforge block removed (previous copy: ~/.bashrc.dotforge-uninstall.bak)"
elif [ -f "$DEST_BASHRC" ] && grep -q '^# Dotforge — load developer workspace' "$DEST_BASHRC"; then
    cp -a "$DEST_BASHRC" "$DEST_BASHRC.dotforge-uninstall.bak"
    sed -i '/^# Dotforge — load developer workspace$/,/^fi$/d' "$DEST_BASHRC"
    success "Old-style dotforge block removed."
else
    info "No dotforge block found in ~/.bashrc — skipping."
fi


# ── Step 3: Restore backups (optional) ────────────────────────────────────────

step "Checking for backups"

backups=()
for base in "${BACKUP_BASES[@]}"; do
    [ -d "$base" ] || continue
    while IFS= read -r d; do backups+=("$d"); done < <(find "$base" -mindepth 1 -maxdepth 1 -type d | sort)
done

if [ ${#backups[@]} -eq 0 ]; then
    info "No backups found."
else
    echo "  Backups (oldest first — #1 holds your files from BEFORE dotforge):"
    for i in "${!backups[@]}"; do
        printf '    %d) %s\n' "$((i + 1))" "${backups[$i]/#$HOME/\~}"
        (cd "${backups[$i]}" && find . -mindepth 1 \( -type f -o -type l \) | sed 's|^\./|         ~/|')
    done
    echo ""
    read -rp "  Restore which backup? [1-${#backups[@]}, Enter = none] " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#backups[@]} ]; then
        src="${backups[$((choice - 1))]}"
        # Paths inside the backup are relative to $HOME. Old flat backups
        # (no directories) are put back at the paths the old installer used.
        while IFS= read -r rel; do
            rel="${rel#./}"
            case "$rel" in
                plugin_config.vim|key_mapping.vim) dest="$HOME/.vim/$rel" ;;
                c.snippets|python.snippets)        dest="$HOME/.vim/UltiSnips/$rel" ;;
                *)                                 dest="$HOME/$rel" ;;
            esac
            mkdir -p "$(dirname "$dest")"
            cp -a "$src/$rel" "$dest"
            success "Restored: ${dest/#$HOME/\~}"
        done < <(cd "$src" && find . -mindepth 1 \( -type f -o -type l \))
    else
        info "No backup restored. They remain in: ${BACKUP_BASES[0]/#$HOME/\~}"
    fi
fi


# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}============================================${RESET}"
echo -e "${GREEN}${BOLD}  dotforge uninstalled                      ${RESET}"
echo -e "${GREEN}${BOLD}============================================${RESET}"
echo ""
echo "  Kept:    ~/.bash_local, ~/.vim/undodir, system packages"
echo ""
echo "  Open a new terminal (or 'exec bash') to drop the loaded aliases."
echo "  To reinstall: ./scripts/install.sh"
echo ""
