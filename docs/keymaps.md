# dotforge Key Map Cheatsheet

Vim leader is **Space**. tmux prefix is **Ctrl+B**.
Source of truth: [`vim/key_mapping.vim`](../vim/key_mapping.vim), [`vim/plugin_config.vim`](../vim/plugin_config.vim) (LSP), [`tmux/tmux.conf`](../tmux/tmux.conf).

## Vim

### Files and buffers

| Key | Mode | Action |
|---|---|---|
| `Ctrl+S` | N / I / V | Save (only if changed) |
| `Ctrl+Q` | N | Close window |
| `Space w` | N | Save all buffers |
| `Space q` | N | Quit Vim |
| `Space x` | N | Save and close |
| `Tab` / `Shift+Tab` | N | Next / previous buffer (a terminal sends `Tab` and `Ctrl+I` as the same key, so this replaces jump-forward; use `Space ]` if you need `Ctrl+I`) |
| `Space ]` / `Space [` | N | Next / previous buffer |
| `Space 1` … `Space 9` | N | Jump to buffer tab N (airline numbers) |
| `Space d` | N | Close buffer, keep the window layout |
| `Space D` | N | Force-close buffer (discard changes) |
| `F2` | N | Toggle line numbers |
| `F3` | N | Toggle visible tabs / trailing whitespace |
| `F7` | N | Toggle spell check |

### Windows

| Key | Mode | Action |
|---|---|---|
| `Space v` / `Space s` | N | Vertical / horizontal split |
| `Ctrl+H/J/K/L` | N | Move to the left / down / up / right window |
| `Ctrl+Arrows` | N | Resize window |
| `Space o` | N | Close all other windows |
| `Space =` | N | Equalize window sizes |

### Editing

| Key | Mode | Action |
|---|---|---|
| `jk` / `jj` | I | Exit insert mode |
| `Ctrl+Z` | I | Undo and return to normal mode |
| `Alt+J` / `Alt+K` | N / V | Move line / selection down / up |
| `<` / `>` | V | Indent, keeping the selection |
| `Y` | N | Yank to end of line |
| `H` / `L` | N / V | First / last non-blank character |
| `Space j` / `Space k` | N | 10 lines down / up |
| `Space y` | V | Copy selection to system clipboard |
| `Space Y` / `Space yy` | N | Copy to end of line / whole line to clipboard |
| `Space p` / `Space P` | N | Paste clipboard after / before |
| `Space p` | V | Paste over selection, keep register |
| `Space S` | N | Substitute word under cursor in the file |
| `Space F` | N | Format buffer (clang-format etc.) |
| `Space c Space` | N / V | Toggle comment (NERDCommenter) |
| `Space cc` / `Space cu` | N / V | Comment / uncomment |
| `cs"'` / `ds"` / `ysiw)` | N | Change / delete / add surroundings (vim-surround) |

### Search and navigation

| Key | Mode | Action |
|---|---|---|
| `Space /` | N | Clear search highlight |
| `Space *` | N | Search word in the whole project → quickfix |
| `Ctrl+P` / `Space ff` | N | Find file |
| `Space fg` | N | Find git-tracked file |
| `Space b` / `Space fb` | N | Open buffers |
| `Space fr` | N | Recent files |
| `Space fl` | N | Lines in this buffer |
| `Space fh` | N | Vim help |
| `Space fc` / `Space fC` | N | Git commits (repo / this file) |
| `Space rg` | N | Ripgrep (type a pattern) |
| `Space rw` | N | Ripgrep word under cursor |
| `Ctrl+F` | N | Toggle NERDTree |
| `Space nf` / `Space nr` | N | Reveal file in NERDTree / refresh tree |
| `F8` | N | Toggle Tagbar |
| `Space tb` | N | Focus Tagbar |
| `Space tg` / `Space tf` | N | Search tags in project / this file |

### cscope (build the DB with `mkidx`, then `:CscopeReload`)

| Key | Action |
|---|---|
| `Ctrl+\ s` | All references to the symbol |
| `Ctrl+\ g` / `Ctrl+\ d` | Global definition |
| `Ctrl+\ c` | Callers of this function |
| `Ctrl+\ e` | Functions called by this function |
| `Ctrl+\ a` | Places where the symbol is assigned |
| `Ctrl+\ t` | Text string |
| `Ctrl+\ i` | Files that #include this header |
| `Ctrl+\ f` | Open file under cursor |

### LSP (only in buffers with clangd / pylsp attached)

| Key | Action |
|---|---|
| `gd` / `gD` | Definition / declaration |
| `gr` | References |
| `gi` | Implementation |
| `K` | Hover documentation |
| `Space rn` | Rename symbol |
| `Space la` | Code action |
| `]d` / `[d` | Next / previous diagnostic |
| `Space ld` | All diagnostics in this file |

### Git

| Key | Action |
|---|---|
| `Space gs` | Status (`-` stage, `cc` commit, `=` inline diff) |
| `Space gd` | Side-by-side diff against the index |
| `Space gb` | Blame |
| `Space gl` | Log of this file → quickfix |
| `Space gw` | Stage this file |
| `]h` / `[h` | Next / previous changed hunk |
| `Space hp` / `Space hs` / `Space hu` | Preview / stage / undo hunk |

### Quickfix, build and kernel

| Key | Action |
|---|---|
| `]q` / `[q` | Next / previous quickfix entry |
| `]Q` / `[Q` | Last / first quickfix entry |
| `]l` / `[l` | Next / previous location-list entry |
| `Space co` / `Space cq` | Open / close quickfix |
| `Space m` / `F5` | `make`; quickfix opens on errors |
| `Space cp` | `:Checkpatch` the current file |

### Terminal and config

| Key | Action |
|---|---|
| `Space tt` / `Space tv` | Terminal below / to the right |
| `Esc Esc` | Leave terminal-job mode |
| `Space ev` / `Space ek` | Edit vimrc / key mappings |

### Commands

| Command | Action |
|---|---|
| `:Checkpatch` | checkpatch.pl on the file → quickfix |
| `:CscopeReload` | Reconnect to `cscope.out` after `mkidx` |
| `:FormatOnSave` | Toggle clang-format on save (needs `.clang-format`) |
| `:StripTrailing` | Remove trailing whitespace |
| `:Reload` | Re-source vimrc |
| `:UltiSnipsEdit` | Edit snippets for this filetype |

## tmux

| Key | Action |
|---|---|
| `Prefix h` / `Prefix "` | Split: new pane below |
| `Prefix v` / `Prefix %` | Split: new pane to the right |
| `Alt+Arrow` | Move between panes (no prefix) |
| `Prefix Shift+Arrow` | Resize pane (repeatable) |
| `Prefix z` | Zoom pane |
| `Prefix q` | Show pane numbers |
| `Prefix x` | Kill pane (confirm) |
| `Prefix c` | New window in the current directory |
| `Prefix p` / `Prefix n` | Previous / next window |
| `Shift+Left` / `Shift+Right` | Previous / next window (no prefix) |
| `Alt+1` … `Alt+9` | Go to window N (no prefix) |
| `Prefix <` / `Prefix >` | Move window left / right |
| `Prefix ,` | Rename window |
| `Prefix X` | Kill window (confirm) |
| `Prefix A` | BSP layout: vim / build / serial console |
| `Prefix B` | Two ADB shells |
| `Prefix L` | Toggle logging this pane to `~/tmux_logs/` |
| `Prefix K` | Clear scrollback |
| `Prefix [` / wheel | Enter copy mode (see below) |
| `Prefix d` | Detach |
| `Prefix s` / `Prefix S` | Choose / create session |
| `Prefix $` | Rename session (shown in the status bar) |
| `Prefix r` | Reload config |
| `Prefix e` | Edit `~/.tmux.conf` |

### Copy and paste in tmux

Copying goes through `~/.local/bin/dotforge-clip`, which uses `wl-copy` (Wayland), `xclip` or `xsel` (X11). On Wayland install `wl-clipboard`.

**With the mouse** — drag inside ONE pane; the selection never crosses a pane border.

| Action | Result |
|---|---|
| Drag | Select text in this pane; it is copied when you let go and stays highlighted |
| Double-click / triple-click | Select and copy a word / a line |
| `q` or `Esc` | Leave copy mode |

> Do not hold **Shift** while dragging. Shift bypasses tmux and uses the terminal's own selection, which spans every pane and is not copied by tmux. Panes running a program that grabs the mouse (`htop`, Vim, Claude Code) get the drag instead of tmux.

**With the keyboard** — `Prefix [`, then:

| Key | Action |
|---|---|
| `h j k l` / arrows | Move the cursor |
| `v` | Start selecting (like Vim visual) |
| `Ctrl+V` | Toggle rectangular (block) selection |
| `/` `?` `n` `N` | Search forward / backward / next / previous |
| `y` or `Enter` | Copy the selection and leave copy mode |
| `q` or `Esc` | Leave copy mode |

**Pasting**

| Key | Action |
|---|---|
| `Prefix ]` | Paste the last thing copied in tmux (works without a clipboard tool) |
| `Prefix P` | Paste the desktop clipboard into the pane |
| `Ctrl+Shift+V` | Paste the desktop clipboard (terminal shortcut) |
