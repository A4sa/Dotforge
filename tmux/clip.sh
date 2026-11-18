#!/bin/sh
# ============================================================================
#  File name   : clip.sh   (installed as ~/.local/bin/dotforge-clip)
#  Description : Read text on stdin and put it on the desktop clipboard.
#                tmux calls it every time you copy (mouse drag, y, Enter).
#
#  WHY A SCRIPT: the tool is chosen at COPY time, from the environment of the
#  moment, not once when tmux started. A tmux server that outlives a login
#  (or started before the display existed) would otherwise keep a stale choice.
#  Order: wl-copy (Wayland) → xclip / xsel (X11) → nothing (tmux buffer only).
# ============================================================================
: "${DISPLAY:=:0}"

if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
    exec wl-copy
elif command -v xclip >/dev/null 2>&1; then
    # Redirect output: xclip stays alive in the background to serve the
    # clipboard, and must not keep tmux's pipe open.
    exec xclip -in -selection clipboard >/dev/null 2>&1
elif command -v xsel >/dev/null 2>&1; then
    exec xsel --input --clipboard >/dev/null 2>&1
fi
# No clipboard tool: swallow the text. It is still in the tmux buffer (Prefix+]).
cat >/dev/null
