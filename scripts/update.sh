#!/usr/bin/env bash
# ============================================================================
#  File name   : update.sh
#  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
#  Repository  : https://github.com/A4sa/dotforge.git
#  Description : Pull the latest dotforge changes, link any new files and
#                update the Vim plugins.
#
#  USAGE
#  -----
#    ./scripts/update.sh
#
#  Config files are symlinks into this repo, so 'git pull' alone already
#  updates them. This script also links files added since your install and
#  updates/cleans Vim plugins.
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
git rev-parse --git-dir &>/dev/null || error "Not a git repository: $DOTFORGE_ROOT"

branch=$(git branch --show-current)
[ -n "$branch" ] || error "Detached HEAD — check out a branch first (git switch main)."
info "Branch: $branch"

if ! git rev-parse --abbrev-ref '@{u}' &>/dev/null; then
    error "Branch '$branch' has no upstream. Set one: git branch -u origin/$branch"
fi

before=$(git rev-parse HEAD)
# --autostash keeps your local edits (staged or not) across the rebase.
git pull --rebase --autostash
after=$(git rev-parse HEAD)

if [ "$before" = "$after" ]; then
    success "Already up to date."
else
    success "Updated $(git rev-list --count "$before..$after") commit(s):"
    git --no-pager log --oneline "$before..$after" | sed 's/^/    /'
fi


# ── Step 2: Link new files / refresh the ~/.bashrc block ──────────────────────

step "Re-applying links"
# --no-deps: don't ask about packages on every update.
bash "$SCRIPT_DIR/install.sh" --no-deps >/dev/null
success "Links up to date."


# ── Step 3: Update Vim plugins ────────────────────────────────────────────────

step "Updating Vim plugins"

if ! command -v vim &>/dev/null; then
    warn "vim not found — skipping plugin update."
elif [ ! -t 0 ] || [ ! -t 1 ]; then
    warn "No terminal — run :PlugUpdate inside Vim."
else
    info "Running :PlugUpdate and :PlugClean..."
    vim -N -u "$HOME/.vimrc" -i NONE +'PlugUpdate --sync' +'PlugClean!' +'qall!' \
        || warn "Plugin update reported an error — open vim and run :PlugUpdate"
    success "Vim plugins updated."
fi

echo ""
echo -e "${GREEN}${BOLD}dotforge updated successfully.${RESET}"
echo ""
echo "  Run 'source ~/.bashrc' to reload shell config,"
echo "  and Prefix+r inside tmux to reload tmux."
echo ""
