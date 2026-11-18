
```
    ██████╗  ██████╗ ████████╗███████╗ ██████╗ ██████╗  ██████╗ ███████╗
    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝
    ██║  ██║██║   ██║   ██║   █████╗  ██║   ██║██████╔╝██║  ███╗█████╗
    ██║  ██║██║   ██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝
    ██████╔╝╚██████╔╝   ██║   ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗
    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

**A professional, annotated developer workspace for anyone who works on Linux.**
Vim · tmux · Shell · Snippets · Docker — everything configured, everything explained.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)]()
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)]()
[![Editor](https://img.shields.io/badge/Editor-Vim-019733.svg)]()

</div>

## Why dotforge?

Most dotfiles repos are a personal dump — files without explanation, decisions without reasoning. **dotforge is different.** Every setting, every keybinding, every alias is documented with what it does and why it exists.

Linux is one of the most powerful and elegant platforms ever built. Whether you're a **BSP engineer** navigating a kernel tree, a **DevOps engineer** managing infrastructure, an **SDE** building systems software, a **network engineer** running diagnostics, or an **AAOS engineer** integrating Android on embedded targets — if your work happens on Linux, this workspace is for you.

The tools are universal: Vim, tmux, and the shell are available on every Linux machine and most Mac environments. The configuration is opinionated but explained — so you understand what you're getting and can adapt it to your own workflow.

Some aliases and snippets go deeper than the basics — covering cross-compilation toolchains, device tree editing, kernel module workflows, cscope navigation, and ADB — because those are the gaps that generic dotfiles repos don't address. If you don't need them, ignore them. If you do, they're there.

> The name: **dot** (dotfiles) + **forge** (crafted, not collected).

---

## Quick Start

```bash
# 1. Clone the repo (keep it here — your config files link into it)
git clone https://github.com/A4sa/dotforge.git ~/dotforge

# 2. Run the installer
cd ~/dotforge
./scripts/install.sh

# 3. Reload your shell
source ~/.bashrc

# 4. Open Vim
vim
```

The installer checks dependencies (apt / dnf / pacman), backs up any file it replaces, **symlinks** the configs into `$HOME`, adds one marked block to `~/.bashrc`, installs the Vim plugins and creates a `~/.bash_local` template for your private paths. Running it again is safe.

---

## What's Inside

| Component | File(s) | What it configures |
|---|---|---|
| **Vim** | `vim/vimrc` | Core editor — persistent undo, swap recovery, kernel-tree detection |
| **Plugins** | `vim/plugin_config.vim` | Plugin list + all plugin config in one file (incl. clangd LSP) |
| **Keymaps** | `vim/key_mapping.vim` | Every binding documented with WHY — full list in [`docs/keymaps.md`](docs/keymaps.md) |
| **Snippets** | `vim/snippets/` | UltiSnips for kernel C (v6.11+ APIs), Makefiles and Python |
| **tmux** | `tmux/tmux.conf` | Multiplexer tuned for embedded workflows, BSP / ADB layouts |
| **Aliases** | `shell/bash_aliases` | Short commands for daily Linux work |
| **Functions** | `shell/bash_functions` | `xc`, `con`, `mkidx`, `kccdb`, `kcheck`, `dtsdump`, `rmmod_insmod` … |
| **Shell env** | `shell/bashrc_append` | Prompt, history, completion, fzf / zoxide / direnv |
| **Docker** | `docker/docker.sh` | Install Docker on Ubuntu, Debian, Fedora, Arch (+ derivatives) |
| **Scripts** | `scripts/` | install · update · uninstall |

---

## The Workspace Layout

```
┌─ GNOME Terminal ──────────────────────────────────────────────────┐
│ ┌─ tmux session ─────────────────────────────────────────────────┐ │
│ │  [1:bsp]  [2:adb]   ← named windows                            │ │
│ │ ┌──────────────────────────┬─────────────────────┐             │ │
│ │ │                          │  mkl  (make + log)  │             │ │
│ │ │   Vim + NERDTree         │                     │             │ │
│ │ │   cscope / clangd nav    ├─────────────────────┤             │ │
│ │ │   DTS editing            │  con  (serial)      │             │ │
│ │ │                          │                     │             │ │
│ │ └──────────────────────────┴─────────────────────┘             │ │
│ └────────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
```

> **Prefix+A** builds this layout. The build and console commands are typed but not run — add the target / port and press Enter.

<!-- Screenshots: add images to assets/screenshots/ and reference them here. -->

---

## Installation

### Requirements

| Tool | Required by | apt package |
|---|---|---|
| `vim` (+python3, +clipboard) | Vim, UltiSnips | `vim-gtk3` |
| `tmux` | Terminal multiplexer | `tmux` |
| `git`, `curl` | Fugitive, vim-plug | `git curl` |
| `fzf`, `rg` | Fuzzy finder, `:Rg` | `fzf ripgrep` |
| `bat` | File preview | `bat` |
| `ctags`, `cscope` | Tagbar, kernel symbol navigation | `universal-ctags cscope` |
| `clang-format`, `clangd` | Formatting, LSP | `clang-format clangd` |
| `bear` | `compile_commands.json` for non-kernel projects | `bear` |
| `dtc` | `dtsdump` | `device-tree-compiler` |
| `picocom` | Serial console (`con`) | `picocom` |
| `xclip` | Clipboard on X11 | `xclip` |

`install.sh` detects missing tools and offers to install them (`-y` to answer yes, `--no-deps` to skip).

### How files are installed

| In `$HOME` | Points to |
|---|---|
| `~/.vimrc` | `vim/vimrc` |
| `~/.vim/plugin_config.vim`, `~/.vim/key_mapping.vim` | `vim/*.vim` |
| `~/.vim/UltiSnips/*.snippets` | `vim/snippets/*.snippets` |
| `~/.tmux.conf` | `tmux/tmux.conf` |
| `~/.bashrc` | gets one block between `# >>> dotforge >>>` and `# <<< dotforge <<<` |

Everything is a symlink into the repo, so a `git pull` updates all of it. Your previous files are saved under `~/.dotforge_backup/<date>/` with their original paths.

Machine-local overrides that are never touched: `~/.bash_local`, `~/.vimrc.local`, `~/.tmux.local.conf`.

### Install Docker (any distro)

```bash
./docker/docker.sh
```

Detects Ubuntu, Debian, Fedora or Arch (and derivatives such as Mint or Pop!_OS) and installs Docker Engine from Docker's official repository — not the outdated distro package.

### Update

```bash
cd ~/dotforge && ./scripts/update.sh
```

Pulls the latest commits (keeping local edits via autostash), links any new files and updates the Vim plugins.

### Uninstall

```bash
cd ~/dotforge && ./scripts/uninstall.sh
```

Removes only the symlinks that point into the repo and the marked `~/.bashrc` block, then offers to restore a backup (backup #1 is your setup from before dotforge). Never touches `~/.bash_local`, your undo history or system packages.

---

## Vim Configuration

### Plugin Stack

| Plugin | Purpose |
|---|---|
| `gruvbox` | Warm, low-fatigue colour scheme |
| `vim-airline` | Statusline — mode, branch, hunks, numbered buffer tabs |
| `vim-devicons` | File-type icons (needs a Nerd Font) |
| `NERDTree` | Sidebar file explorer with build-artifact filtering |
| `Tagbar` | Function/struct/enum outline panel (requires ctags) |
| `fzf` + `fzf.vim` | Fuzzy search files, buffers, symbols, git log |
| `vim-fugitive` | Full git workflow inside Vim |
| `vim-gitgutter` | Changed-line signs, hunk preview / stage / undo |
| `vim-surround` | Change / add / delete surrounding quotes and brackets |
| `auto-pairs` | Auto-close brackets, parens, quotes |
| `NERDCommenter` | Toggle comments for any filetype |
| `vim-autoformat` | `:Autoformat` with clang-format (manual, or opt-in on save) |
| `vim-markdown` | Enhanced Markdown — syntax, concealment |
| `UltiSnips` | Snippet engine for kernel C, Makefiles and Python |
| `vim-lsp` | clangd / pylsp — loaded only when a server is installed |

Device Tree syntax (`.dts`, `.dtsi`, `.dtso`, `.its`) is built into Vim.

### Everyday features

- **Never lose work** — persistent undo across sessions, swap files in `~/.vim/swap` for crash / SSH-drop recovery.
- **Kernel-style detection** — files in a Linux / U-Boot tree (found by `Kbuild` + `MAINTAINERS`), or an out-of-tree module (`obj-m` Makefile), automatically get 8-wide hard tabs and a 100-column marker. Mark any vendor tree with `touch .kernel-style`.
- **Visible whitespace** — tabs, trailing spaces and non-breaking spaces are shown, so a tab/space mix in a patch is caught before `checkpatch`.
- **`:Checkpatch`** (`Space cp`) — runs the kernel's `checkpatch.pl` on the file; findings go to the quickfix list.
- **cscope** connects to the nearest `cscope.out` above the file; rebuild with `mkidx`, reconnect with `:CscopeReload`.
- **LSP** (clangd) — `gd`, `gr`, `K`, `]d` — once a `compile_commands.json` exists (`kccdb`).
- **Big files** (logs, `System.map` > 10 MB) open fast — syntax and undo are switched off for them.
- **`:FormatOnSave`** — opt-in clang-format on save, only in projects that have a `.clang-format`.

### Key Mappings — Quick Reference

> Leader key is `Space`. Full list: [`docs/keymaps.md`](docs/keymaps.md)

| Key | Action |
|---|---|
| `Ctrl+S` | Save (normal / insert / visual) |
| `Space /` | Clear search highlights |
| `Space v` / `Space s` | Vertical / horizontal split |
| `Ctrl+H/J/K/L` | Move between Vim splits |
| `Tab` / `S-Tab` | Next / previous buffer |
| `Space 1`…`9` | Jump to buffer tab N |
| `Space y` / `Space p` | Yank / paste system clipboard |
| `Space gs` / `gd` / `gb` | Git status / diff / blame (Fugitive) |
| `]h` / `[h` | Next / previous changed hunk |
| `Ctrl+F` | Toggle NERDTree |
| `F8` | Toggle Tagbar |
| `Ctrl+P` | fzf file search |
| `Space rg` / `Space rw` | Ripgrep / ripgrep word under cursor |
| `Space *` | Project-wide search for word → quickfix |
| `Ctrl+\` c / d / s / a | cscope: callers / definition / references / assignments |
| `]q` / `[q` | Next / previous quickfix entry |
| `Space m` / `F5` | Run make, open quickfix on errors |
| `Space cp` | checkpatch the current file |
| `Space tt` | Terminal split |

### Filetype Rules

| Filetype | Indent | Tabs | Notes |
|---|---|---|---|
| C / C++ | 4 | Spaces | Application / userspace code |
| C, asm, DTS, Kconfig, Makefile in a kernel tree | 8 | Hard tabs | Detected automatically |
| Makefile | 8 | Hard tabs | Required — spaces break `make` |
| Device Tree (`.dts .dtsi .dtso .its`) | 8 | Hard tabs | DT coding style |
| Kconfig | 8 | Hard tabs | Help text: tab + 2 spaces |
| Python | 4 | Spaces | PEP 8, 88 columns |
| git commit | — | — | 72-column wrap, spell check |

Projects with a `.editorconfig` get their own rules automatically.

### cscope Integration

```bash
mkidx            # kernel/U-Boot tree: 'make cscope tags' for the current $ARCH only
                 # anywhere else: indexes C/C++/asm, skipping .git, build/, out/
```

Vim connects to the nearest `cscope.out` in the current directory or any parent.

---

## tmux Configuration

### Why tmux for embedded work?

Sessions persist after you close the terminal. Start a 2-hour kernel build, disconnect, go home, SSH back in — your build is still running and your Vim is still open exactly where you left it.

### Built-in Layouts

**Prefix+A** — BSP development window

```
┌──────────────────┬──────────────┐
│                  │  mkl         │
│   vim            │  build pane  │
│                  ├──────────────┤
│                  │  con         │
│                  │  serial pane │
└──────────────────┴──────────────┘
```

**Prefix+B** — Dual ADB shell

```
┌──────────────────┬──────────────────┐
│  adb devices -l  │  adb devices -l  │
│  device A        │  device B        │
└──────────────────┴──────────────────┘
```

### Status Bar

```
( TMUX)( bsp)  (1 vim)(2 build 󱅫)        main  linux ( 0.42 │ 󰍛 37%)( edgeverse)( 23:10)
```

| Segment | Shows |
|---|---|
| Mode | `TMUX` green · `PREFIX` red after Ctrl+B · `COPY` yellow · `ZOOM` peach |
| Session | Session name — name it with `tmux new -s bsp` or rename with `Prefix+$` |
| Windows | `index name`; active window in mauve; 󰁓 zoomed, 󱅫 new output in a background window (build finished) |
| Git / dir | Branch and directory of the active pane |
| Load / RAM | 1-minute load average (compare with `nproc`) and used memory |
| Host / time | Hostname (which machine you are on over SSH) and clock |

Each pane also shows its number, command and directory on its top border. Colours are Catppuccin Mocha, defined once as `@c_*` options at the top of the theme section. Icons need a Nerd Font; without one, put `set -g @df_plain 1` in `~/.tmux.local.conf`.

### Key Reference

| Key | Action |
|---|---|
| `Prefix+h` / `Prefix+v` | Split pane below / to the right |
| `Alt+Arrow` | Move between panes (no prefix) |
| `Prefix+Shift+Arrow` | Resize pane |
| `Prefix+z` | Zoom current pane |
| `Shift+Left/Right` | Previous / next window (no prefix) |
| `Alt+1`…`9` | Jump to window (no prefix) |
| `Prefix+A` / `Prefix+B` | BSP layout / dual ADB layout |
| `Prefix+L` | Toggle logging this pane to `~/tmux_logs/` |
| `Prefix+K` | Clear scrollback |
| `Prefix+[` / mouse wheel | Copy mode (`v` select, `y` copy to clipboard) |
| Mouse drag | Select + copy inside one pane (never use Shift+drag — it selects across all panes) |
| `Prefix+d` | Detach session (keeps running) |
| `Prefix+s` | Choose session |
| `Prefix+r` | Reload `~/.tmux.conf` |

The clipboard works over SSH too (OSC 52). Inside tmux, `ssh` sends `TERM=xterm-256color` so BusyBox / Buildroot targets don't complain about an unknown terminal.

---

## Shell Configuration

### Prompt

```
user@host:~/linux (main) [arm64] ✗2 $
```

Git branch, the active cross-compile `ARCH` (so you never build for the wrong target), the exit code of the last command when it failed, and a green / red `$`.

### Aliases — Highlights

```bash
make            # make -j$(nproc)    — always parallel (\make for serial)
mkl             # make + tee build.log; buildlogerr shows the errors
mkidx           # rebuild cscope + ctags index (ARCH-aware in kernel trees)
con             # serial console: con [dev|index|by-id] [baud] [-l to log]
lsserial        # list serial ports with driver (ftdi_sio, cp210x, ch341…) and by-id name
dmw             # follow the kernel log live
ff / vf         # fzf with bat preview / open the pick in Vim
glg             # git log --oneline --graph --decorate --all
apti / aptr      # sudo apt install / remove  (not named 'install': that is a real command)
dkrun           # docker run --rm -it as YOUR user with $PWD mounted
```

History: Up/Down search by what you've typed so far; every command is saved immediately (`hsync` merges other panes' history).

### Functions

| Function | Usage | Purpose |
|---|---|---|
| `xc` | `xc arm64` / `xc arm arm-linux-gnueabihf` / `xc arm64 llvm` | Set cross-compile toolchain (checks the compiler exists) |
| `xc-show` / `xc-clear` | | Show / clear `ARCH`, `CROSS_COMPILE`, `LLVM` |
| `con` | `con 1 1500000 -l` | picocom on `/dev/ttyUSB1` at 1.5 Mbaud, logged |
| `lsserial` | | Serial ports, adapter driver, by-id name, dialout check |
| `mkl` | `mkl O=out Image dtbs` | make with `build.log`, exit status kept |
| `mkidx` | | cscope + ctags (kernel: current `$ARCH` only) |
| `kccdb` | `kccdb` / `kccdb O=out` | `compile_commands.json` for clangd |
| `kcheck` | `kcheck` / `kcheck HEAD~3` / `kcheck file.c` | checkpatch on commits / files / patches |
| `dtsdump` | `dtsdump board.dtb` / `dtsdump` | Decompile a DTB, or the board's live device tree |
| `kgrep` | `kgrep USB_SERIAL` / `kgrep -r USB_SERIAL` | Search `.config` (honours `KBUILD_OUTPUT`) or the running kernel |
| `modcheck` | `modcheck i2c_dev` | Loaded, built-in (`=y`), or available? |
| `rmmod_insmod` | `rmmod_insmod out/my_drv.ko debug=1` | Reload a module with params, show the kernel log |
| `dlog` | `dlog i2c` / `dlog -f 'usb\|xhci'` | Filter (or follow) dmesg |
| `adbpush` / `adbpull` | `adbpush ./bin /data/local/tmp/` | Push (keeps +x) / pull via ADB |
| `sysinfo` | | OS, board (DT model), kernel, CPU, cores, RAM, disk, target |
| `myip` / `portscan` / `portinfo` | | Network helpers |
| `up` / `mkcd` / `fcd` / `va` | | Navigation, venv activation |
| `extract` | `extract rootfs.img.zst` | Any archive; keeps the original for single-file formats |
| `gsync` | | Fetch + rebase onto the branch's upstream (autostash) |

Every function prints its usage with `-h`.

### Machine-Local Config

Project-specific paths (SDK roots, board aliases, toolchain setup) live in `~/.bash_local` — not in the repo, loaded last so it overrides anything:

```bash
# ~/.bash_local
alias sdk='cd ~/path/to/your/sdk'
alias con='con usb-FTDI_FT232R_USB_UART_A12345-if00-port0 1500000'
```

For per-board toolchains, prefer [direnv](https://direnv.net): put `export ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-` in the board tree's `.envrc`.

---

## UltiSnips Snippets

Author name and e-mail come from `git config user.name` / `user.email`.

### C Snippets (`vim/snippets/c.snippets`) — kernel v6.11+ APIs

| Trigger | Expands to |
|---|---|
| `fhdr` | SPDX header (`//` in .c, `/* */` in .h) + copyright |
| `hguard` / `hguardcpp` | Header guard (filename auto-filled) / with `extern "C"` |
| `kmod` | Minimal kernel module with `pr_fmt` |
| `platdrv` | Platform driver: MMIO, `devm_clk_get_enabled`, reset, IRQ |
| `i2cdrv` | I2C driver: regmap, supply regulator, reset GPIO, chip-ID probe |
| `spidrv` | SPI driver with regmap (mode taken from DT) |
| `irqh` | Hard IRQ handler + `devm_request_irq` |
| `irqth` | Threaded IRQ for I2C/SPI devices (`IRQF_ONESHOT`) |
| `dtnode` / `dti2c` / `dtspi` | DTS MMIO / I2C / SPI device nodes |
| `dtgpio` / `dtpinctrl` / `dtovl` | GPIO property / pinctrl / overlay skeleton |
| `deve` / `devi` / `devd` / `devw` | `dev_err` / `dev_info` / `dev_dbg` / `dev_warn` |
| `deprobe` | `return dev_err_probe(...)` |
| `regr` / `regw` / `regupd` / `regpoll` | regmap read / write / update bits / poll with timeout |
| `retcheck` | Return value error check pattern |
| `bfield` | `BIT()`, `GENMASK()`, `FIELD_GET/PREP` |
| `mutex` / `spinl` | Scoped `guard(mutex)` / IRQ-safe spinlock |
| `waitq` / `compl` | Wait queue / completion with timeout |
| `dma` | DMA mask + `dmam_alloc_coherent` |
| `miscdev` / `cdev` | misc device / character device with error unwinding |

### Makefile Snippets (`vim/snippets/make.snippets`)

| Trigger | Expands to |
|---|---|
| `kmod_make` | Out-of-tree module Makefile (cross-compile ready, `install` target) |

### Python Snippets (`vim/snippets/python.snippets`)

| Trigger | Expands to |
|---|---|
| `fhdr` | Script header with shebang + docstring |
| `main` | argparse CLI entry point |
| `log` / `logsetup` | Module logger / console + file logging |
| `serial` | pyserial `SerialComm` class (prompt matching, login, `run()`) |
| `ssh` | paramiko SSH wrapper (handles empty-password Yocto images) |
| `sub` / `shell` | `subprocess.run` helper / one-liner |
| `regparse` / `bitmask` | Register bitfield parser / mask helpers |
| `retry` | Retry decorator for flaky hardware ops |
| `test` / `fixture` / `param` | pytest module / fixture / parametrize |
| `timer` | Elapsed time context manager |

---

## Project Structure

```
dotforge/
├── docker/
│   └── docker.sh               detect distro + install Docker Engine
├── docs/
│   └── keymaps.md              full keybinding cheatsheet (Vim + tmux)
├── scripts/
│   ├── install.sh              one-command workspace setup (symlinks)
│   ├── update.sh               pull + link new files + update plugins
│   └── uninstall.sh            clean removal with backup restore
├── shell/
│   ├── bash_aliases            short command aliases
│   ├── bash_functions          shell functions (xc, con, mkidx, kccdb...)
│   └── bashrc_append           prompt, history, integrations; loads the rest
├── tmux/
│   └── tmux.conf               tmux config for embedded workflows
├── vim/
│   ├── vimrc                   core Vim configuration
│   ├── plugin_config.vim       plugin list + all plugin configuration
│   ├── key_mapping.vim         all keybindings, annotated
│   └── snippets/
│       ├── c.snippets          kernel driver + DT patterns
│       ├── make.snippets       kernel module Makefile
│       └── python.snippets     embedded automation patterns
└── README.md
```

---

## Contributing

Issues and pull requests are welcome.

If you're adding a new alias or function, follow the documentation style in the existing files — every entry needs a WHAT and a WHY. A setting without a reason isn't documentation, it's just noise.

Before opening a PR:

```bash
shellcheck shell/* scripts/*.sh docker/docker.sh
```

In Vim files, keep comments on their own line above a mapping — a `"` after a `:map` command becomes part of the mapping.

---

## Author

**Abdul Sattar**  
Lead ARAS Engineer

[abdul.linuxdev@gmail.com](mailto:abdul.linuxdev@gmail.com)  
[github.com/A4sa](https://github.com/A4sa)

---

## License

MIT — see [`LICENSE`](LICENSE) for details.

---

<div align="center">
<sub>Built for engineers who live in the terminal.</sub>
</div>
