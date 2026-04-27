#!/usr/bin/env bash
# ============================================================================
#  File name   : update.sh
#  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
#  Repository  : https://github.com/A4sa/dotforge.git
#  Description : Pull the latest dotforge changes and re-copy config files.
#                Backs up existing configs before overwriting.
#
#  USAGE
#  -----
#    ./scripts/update.sh
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


# ── Step 1: Pull latest from git ──────────────────────────────────────────────

step "Pulling latest changes"

cd "$DOTFORGE_ROOT"

if [ ! -d ".git" ]; then
    error "Not a git repository: $DOTFORGE_ROOT"
fi

local_branch=$(git rev-parse --abbrev-ref HEAD)
info "Branch: $local_branch"

# Stash any local uncommitted changes to dotforge files
if ! git diff --quiet; then
    warn "Uncommitted local changes detected — stashing..."
    git stash push -m "dotforge update stash $(date +%Y-%m-%d)"
    STASHED=true
else
    STASHED=false
fi

git pull --rebase origin "$local_branch"
success "Repository updated."

# Restore stashed changes if any
if [ "$STASHED" = true ]; then
    info "Restoring stashed local changes..."
    git stash pop || warn "Could not restore stash — check 'git stash list'"
fi


# ── Step 2: Re-run install to copy updated files ──────────────────────────────

step "Re-applying config files"

info "Running install.sh to copy updated configs..."
bash "$SCRIPT_DIR/install.sh"


# ── Step 3: Update Vim plugins ────────────────────────────────────────────────

step "Updating Vim plugins"

if command -v vim &>/dev/null; then
    info "Running :PlugUpdate headlessly..."
    vim -E -s -u "$HOME/.vimrc" +PlugUpdate +PlugClean! +qall 2>/dev/null || true
    success "Vim plugins updated."
else
    warn "vim not found — skipping plugin update."
fi

echo ""
echo -e "${GREEN}${BOLD}dotforge updated successfully.${RESET}"
echo ""
echo "  Run 'source ~/.bashrc' to reload shell config."
echo ""
