
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
# 1. Clone the repo
git clone https://github.com/A4sa/dotforge.git ~/dotforge

# 2. Run the installer
cd ~/dotforge
chmod +x scripts/install.sh
./scripts/install.sh

# 3. Reload your shell
source ~/.bashrc

# 4. Open Vim — plugins install automatically on first launch
vim
```

That's it. The installer handles dependencies, copies configs, installs vim-plug, and creates a `~/.bash_local` template for your private project paths.

---

## What's Inside

| Component | File(s) | What it configures |
|---|---|---|
| **Vim** | `vim/vimrc` | Core editor — 13 annotated sections |
| **Plugins** | `vim/plugin_config.vim` | Plugin list + all plugin config in one file |
| **Keymaps** | `vim/key_mapping.vim` | Every binding documented with WHY |
| **Snippets** | `vim/snippets/` | UltiSnips for C (kernel drivers) and Python |
| **tmux** | `tmux/tmux.conf` | Multiplexer tuned for embedded workflows |
| **Aliases** | `shell/bash_aliases` | Short commands for daily Linux work |
| **Functions** | `shell/bash_functions` | Shell functions: `xc`, `dlog`, `adbpush`, `kgrep` |
| **Shell env** | `shell/bashrc_append` | One-line loader for the full shell setup |
| **Docker** | `docker/docker.sh` | Install Docker on Ubuntu, Debian, Fedora, Arch |
| **Scripts** | `scripts/` | install · update · uninstall |

---

## The Workspace Layout

```
┌─ GNOME Terminal ──────────────────────────────────────────────────┐
│ ┌─ tmux session: "bsp-dev" ───────────────────────────────────┐   │
│ │  [1:vim]  [2:build]  [3:adb]   ← named windows              │   │
│ │ ┌──────────────────┬──────────────┬──────────────┐          │   │
│ │ │                  │              │               │          │   │
│ │ │   Vim + NERDTree │  make -j8    │  dmesg -w     │          │   │
│ │ │   cscope nav     │  build log   │  kernel log   │          │   │
│ │ │   DTS editing    │              │               │          │   │
│ │ │                  │              │               │          │   │
│ │ └──────────────────┴──────────────┴──────────────┘          │   │
│ └─────────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────────┘
```

> **Prefix+A** builds this 3-pane BSP layout automatically.

![dotforge workspace](assets/screenshots/workspace-overview.png)

<details>
<summary>More Screenshots</summary>

**Vim + NERDTree + Tagbar**
![Vim IDE](assets/screenshots/vim-ide.png)

**tmux BSP Layout (Prefix+A)**
![tmux layout](assets/screenshots/tmux-bsp-layout.png)

**fzf File Search**
![fzf search](assets/screenshots/fzf-search.png)

</details>

---

## Installation

### Requirements

| Tool | Required by | Install |
|---|---|---|
| `vim-gtk3` | Vim (+clipboard, +python3) | `sudo apt install vim-gtk3` |
| `tmux` | Terminal multiplexer | `sudo apt install tmux` |
| `git` | Fugitive plugin | `sudo apt install git` |
| `curl` | vim-plug bootstrap | `sudo apt install curl` |
| `fzf` | Fuzzy finder | `sudo apt install fzf` |
| `ripgrep` | `:Rg` search in Vim | `sudo apt install ripgrep` |
| `bat` | File preview in shell | `sudo apt install bat` |
| `universal-ctags` | Tagbar plugin | `sudo apt install universal-ctags` |
| `cscope` | Kernel symbol navigation | `sudo apt install cscope` |
| `clang-format` | Auto-format on save | `sudo apt install clang-format` |
| `xclip` | tmux clipboard bridge | `sudo apt install xclip` |
| `picocom` | Serial console | `sudo apt install picocom` |

The `install.sh` script detects missing tools and asks if it should install them automatically.

### Fresh Machine Setup

```bash
git clone https://github.com/A4sa/dotforge.git ~/dotforge
cd ~/dotforge && ./scripts/install.sh
source ~/.bashrc
```

### Install Docker (any distro)

```bash
cd ~/dotforge/docker
chmod +x docker.sh
./docker.sh
```

Automatically detects Ubuntu, Debian, Fedora, or Arch and installs Docker Engine from the official repository — not the outdated distro-packaged version.

### Update

```bash
cd ~/dotforge && ./scripts/update.sh
```

Pulls the latest commits, re-copies updated configs, and upgrades Vim plugins.

### Uninstall

```bash
cd ~/dotforge && ./scripts/uninstall.sh
```

Cleanly removes every installed file. Offers to restore backups. Never touches `~/.bash_local` or system packages.

---

## Vim Configuration

### Plugin Stack

| Plugin | Purpose |
|---|---|
| `vim-airline` | Statusline — mode, branch, filename, line/column |
| `vim-devicons` | File-type icons in NERDTree and the tabline |
| `NERDTree` | Sidebar file explorer with build-artifact filtering |
| `Tagbar` | Function/struct/enum outline panel (requires ctags) |
| `fzf` + `fzf.vim` | Fuzzy search files, buffers, symbols, git log |
| `vim-fugitive` | Full git workflow inside Vim |
| `vim-gitgutter` | Live git diff signs in the sign column |
| `auto-pairs` | Auto-close brackets, parens, quotes with FlyMode |
| `NERDCommenter` | Toggle comments for any filetype |
| `vim-autoformat` | clang-format on save for `.c` and `.h` files |
| `vim-markdown` | Enhanced Markdown — syntax, folding, concealment |
| `vim-dt` | Device Tree Source (`.dts`/`.dtsi`) highlighting |
| `UltiSnips` | Snippet engine for C kernel patterns and Python |

### Key Mappings — Quick Reference

> Leader key is `Space`. Full annotated reference: [`vim/key_mapping.vim`](vim/key_mapping.vim)

| Key | Action |
|---|---|
| `Space /` | Clear search highlights |
| `Space v` | Vertical split |
| `Space s` | Horizontal split |
| `Ctrl+H/J/K/L` | Move between Vim splits |
| `Tab` / `S-Tab` | Next / previous buffer |
| `Space y` | Yank to system clipboard |
| `Space p` | Paste from system clipboard |
| `Space gs` | Git status (Fugitive) |
| `Space gd` | Git diff split |
| `Space gb` | Git blame |
| `Ctrl+F` | Toggle NERDTree |
| `Space nf` | Find current file in NERDTree |
| `F8` | Toggle Tagbar |
| `Ctrl+P` | fzf file search |
| `Space rg` | Ripgrep content search |
| `Space rw` | Ripgrep word under cursor |
| `Ctrl+\` c | cscope: find all callers |
| `Ctrl+\` d | cscope: find definition |
| `Ctrl+\` i | cscope: find #includes |
| `Space m` | Run make |
| `Space t` | Open terminal split |

### Filetype Rules

| Filetype | Indent | Tabs | Notes |
|---|---|---|---|
| C / C++ | 4 | Spaces | BSP/driver code standard |
| Linux kernel C | 8 | Hard tabs | `~/kernel/` path triggers this |
| Makefile | 4 | Hard tabs | Required — spaces break `make` |
| Device Tree (`.dts`, `.dtsi`) | 4 | Hard tabs | `/* */` comment style |
| Kconfig | 1 | Hard tabs | Whitespace-sensitive syntax |
| Python | 4 | Spaces | PEP 8 |

### cscope Integration

Build the index once in your project root:

```bash
# Using the alias from bash_aliases:
mkidx

# Or manually:
find . -name "*.[ch]" > cscope.files && cscope -b -q -k
ctags -R --exclude=.git --exclude="*.o" .
```

Vim auto-connects to `cscope.out` if it exists in the current directory.

---

## tmux Configuration

### Why tmux for embedded work?

Sessions persist after you close the terminal. Start a 2-hour kernel build, disconnect, go home, SSH back in — your build is still running and your Vim is still open exactly where you left it.

### Built-in Layouts

**Prefix+A** — BSP Development (3 panes)

```
┌──────────────────┬──────────────┐
│                  │  make -j8    │
│   vim            │  build pane  │
│   editor         ├──────────────┤
│                  │  dmesg -w    │
│                  │  log pane    │
└──────────────────┴──────────────┘
```

**Prefix+B** — Dual ADB Shell (2 panes)

```
┌──────────────────┬──────────────────┐
│  adb shell       │  adb shell       │
│  device A        │  device B        │
└──────────────────┴──────────────────┘
```

### Key Reference

| Key | Action |
|---|---|
| `Ctrl+H` | Split pane horizontally (new pane below) |
| `Ctrl+V` | Split pane vertically (new pane right) |
| `Alt+Arrow` | Move between panes (no prefix needed) |
| `Prefix+z` | Zoom current pane to full screen |
| `Prefix+[` / `]` | Previous / next window |
| `Prefix+A` | Build 3-pane BSP layout |
| `Prefix+B` | Build dual ADB layout |
| `Prefix+d` | Detach session (keeps running) |
| `Prefix+s` | Choose session interactively |
| `Prefix+r` | Reload `~/.tmux.conf` |

---

## Shell Configuration

### Aliases — Highlights

```bash
make            # make -j$(nproc)    — always parallel
mkcs            # rebuild cscope + ctags index
mkidx           # rebuild both at once
con             # picocom -b 115200 --flow=none /dev/ttyUSB0
mcom            # minicom (for XMODEM/YMODEM file transfer)
ff              # fzf with bat syntax preview
vf              # open file selected by fzf in Vim
dmesg           # sudo dmesg -T (with timestamps)
glg             # git log --oneline --graph --decorate --all
```

### Functions

| Function | Usage | Purpose |
|---|---|---|
| `xc` | `xc arm64 aarch64-linux-gnu` | Set cross-compile toolchain |
| `xc-show` | `xc-show` | Show current `ARCH` / `CROSS_COMPILE` |
| `xc-clear` | `xc-clear` | Revert to native build |
| `dlog` | `dlog i2c` | Filter dmesg by keyword |
| `kgrep` | `kgrep USB_SERIAL` | Search `.config` for a kernel option |
| `modcheck` | `modcheck i2c_dev` | Check if a kernel module is loaded |
| `rmmod_insmod` | `rmmod_insmod my_driver` | Reload a kernel module |
| `adbpush` | `adbpush ./bin /data/local/tmp/` | Push file to ADB target |
| `adbpull` | `adbpull /data/local/tmp/log.txt` | Pull file from ADB target |
| `sysinfo` | `sysinfo` | OS, kernel, CPU, RAM, disk summary |
| `myip` | `myip` | Local and public IP addresses |
| `up` | `up 3` | Go up N directory levels |
| `mkcd` | `mkcd new_project` | Create directory and cd into it |
| `extract` | `extract file.tar.gz` | Extract any archive format |
| `gsync` | `gsync` | Git fetch + rebase in one step |

### Machine-Local Config

Project-specific paths (SDK roots, board aliases, toolchain setup) live in `~/.bash_local` — not committed to the repo. The installer creates a template:

```bash
# ~/.bash_local — not committed, machine-specific
alias sdk='cd ~/path/to/your/sdk'
alias work='cd ~/Workspace/'
xc arm64 aarch64-linux-gnu   # auto-set toolchain on login
```

---

## UltiSnips Snippets

### C Snippets (`vim/snippets/c.snippets`)

| Trigger | Expands to |
|---|---|
| `fhdr` | SPDX file header + includes |
| `hguard` | `#ifndef` header guard (filename auto-filled) |
| `kmod` | Complete kernel module skeleton |
| `kmod_make` | Out-of-tree Makefile |
| `platdrv` | Platform driver with probe/remove/of_match |
| `i2cdrv` | I2C driver with regmap |
| `spidrv` | SPI driver skeleton |
| `irqh` | `devm_request_irq` + handler |
| `irqth` | Threaded IRQ handler pair |
| `dtnode` | DTS platform device node |
| `dti2c` | DTS I2C slave device node |
| `dtspi` | DTS SPI slave device node |
| `deve` | `dev_err` with format |
| `devi` | `dev_info` with format |
| `devd` | `dev_dbg` (dynamic debug) |
| `regr` | `regmap_read` with error check |
| `regw` | `regmap_write` with error check |
| `regupd` | `regmap_update_bits` |
| `retcheck` | Return value error check pattern |
| `bfield` | `BIT()`, `GENMASK()`, `FIELD_GET/PREP` macros |
| `waitq` | `wait_event_interruptible` pattern |
| `cdev` | Character device registration |

### Python Snippets (`vim/snippets/python.snippets`)

| Trigger | Expands to |
|---|---|
| `fhdr` | Script header with shebang + docstring |
| `main` | argparse CLI entry point |
| `log` | Module-level logger |
| `logsetup` | Logging to console + file |
| `serial` | pyserial `SerialComm` class |
| `ssh` | paramiko SSH wrapper |
| `sub` | `subprocess.run` helper |
| `regparse` | Register bitfield parser + display |
| `bitmask` | Bitmask and field extraction helpers |
| `retry` | Retry decorator for flaky hardware ops |
| `test` | pytest test module skeleton |
| `fixture` | pytest fixture |
| `timer` | Elapsed time context manager |

---

## Project Structure

```
dotforge/
├── assets/
│   └── screenshots/            workspace screenshots for README
├── docker/
│   └── docker.sh               detect distro + install Docker Engine
├── docs/
│   └── keymaps.md              full keybinding cheatsheet
├── scripts/
│   ├── install.sh              one-command workspace setup
│   ├── update.sh               pull + re-apply + upgrade plugins
│   └── uninstall.sh            clean removal with backup restore
├── shell/
│   ├── bash_aliases            short command aliases
│   ├── bash_functions          shell functions (xc, dlog, kgrep...)
│   └── bashrc_append           one-line shell loader
├── tmux/
│   └── tmux.conf               tmux config for embedded workflows
├── vim/
│   ├── vimrc                   core Vim configuration (13 sections)
│   ├── plugin_config.vim       plugin list + all plugin configuration
│   ├── key_mapping.vim         all keybindings, annotated
│   └── snippets/
│       ├── c.snippets          kernel driver patterns
│       └── python.snippets     embedded automation patterns
└── README.md
```

---

## Contributing

Issues and pull requests are welcome.

If you're adding a new alias or function, follow the documentation style in the existing files — every entry needs a WHAT and a WHY. A setting without a reason isn't documentation, it's just noise.

```bash
# Fork → clone → branch
git checkout -b feature/your-feature

# Make changes, then open a PR against main
```

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full guide.

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
