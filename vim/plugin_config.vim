" ============================================================================
"
"        ██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
"        ██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝
"        ██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗
"        ██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║
"        ██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║
"        ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝
"
"  File name   : plugin.vim
"  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
"  Repository  : https://github.com/A4sa/vimrc-Embedded.git
"  Description : All plugin declarations AND their configuration in one file.
"                Sourced from .vimrc as:
" ===========================================================================


" ============================================================================
"  APT INSTALL CHECKLIST — tools required by plugins in this file
" --------------------------------------------------------------
"   sudo apt install universal-ctags    (Tagbar)
"   sudo apt install cscope             (.vimrc cscope section)
"   sudo apt install fzf                (fzf)
"   sudo apt install ripgrep            (fzf :Rg command)
"   sudo apt install clang-format       (vim-autoformat)
"   sudo apt install bat                (bash_aliases ff preview)
"   sudo apt install picocom            (bash_aliases serial console)
" ============================================================================


" ============================================================================
"[0]  VIM-PLUG BOOTSTRAP
" ============================================================================
" FIRST-TIME SETUP: Just open Vim — plug.vim installs itself, then all plugins
"                   install automatically.

let s:plug_file = expand('~/.vim/autoload/plug.vim')
let s:plug_fresh_install = 0

if !filereadable(s:plug_file)
  if executable('curl')
    echo "vim-plug not found. Downloading..."
    silent execute '!curl -fLo ' . s:plug_file . ' --create-dirs '
      \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    let s:plug_fresh_install = 1
  else
    echo "WARNING: curl not found. Install curl and re-open Vim, or manually"
    echo "install vim-plug: https://github.com/junegunn/vim-plug#installation"
  endif
endif


" ============================================================================
" [1]  PLUGIN DECLARATIONS
" ============================================================================

call plug#begin('~/.vim/plugged')

" ── UI & Appearance ────────────────────────────────────────────────────────
"Plug 'morhetz/gruvbox'                       " Popular dark/light color scheme
Plug 'vim-airline/vim-airline'               " Statusline - shows mode, filename, branch
Plug 'vim-airline/vim-airline-themes'        " Themes for airline
Plug 'ryanoasis/vim-devicons'                " File icons to airline and NERDTree

" ── Navigation ──────────────────────────────────────────────────────────────
Plug 'preservim/nerdtree'                    " Sidebar file explorer tree
Plug 'preservim/tagbar'                      " Show a tag-based code outline in a sidebar
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " Fuzzy finder CLI (needs install)
Plug 'junegunn/fzf.vim'                      " fzf — :Files, :Buffers, :Rg, :Tags, :Commits.

" ── Editing Helpers ───────────────────────────────────────────────────────────
Plug 'jiangmiao/auto-pairs'                  " Automatically insert the closing bracket, paren, or quote
Plug 'preservim/nerdcommenter'               " Toggle, add, or remove code comments with a single mapping
Plug 'Chiel92/vim-autoformat'                " Format code using external formatters (clang-format, autopep8

" ── Language & Syntax Support ─────────────────────────────────────────────────
"Plug 'sheerun/vim-polyglot'                  " Syntax highlighting for 100+ languages in one plugin
Plug 'plasticboy/vim-markdown'               " Enhanced Markdown support — syntax, folding, concealment

" ── Embedded-Specific (Optional) ─────────────────────────────────────────────
"Plug 'stevearc/vim-arduino'                 " Arduino CLI integration — compile, upload, serial monitor from Vim.
"Plug 'normen/vim-pio'                       " PlatformIO project management inside Vim. 
Plug 'msaf1980/vim-dt'                      " Device Tree Source syntax highlighting and indentation.

call plug#end()

" On a brand-new machine (first-time bootstrap), install all plugins without :PlugInstall.
if s:plug_fresh_install
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" ============================================================================
" [2]  COLORSCHEME — gruvbox
" ============================================================================
" gruvbox CONTRAST OPTIONS:
"   hard   — highest contrast, sharpest differentiation (good for bright rooms)
"   medium — balanced, the default (recommended for most setups)
"   soft   — lower contrast, easier on eyes in dark rooms / long sessions

let g:gruvbox_contrast_dark  = 'medium'   " dark mode contrast: hard/medium/soft
let g:gruvbox_contrast_light = 'soft'     " light mode contrast
let g:gruvbox_italic         = 1          " enable italics (comments, keywords)
let g:gruvbox_bold           = 1          " enable bold (types, constants)
let g:gruvbox_invert_selection = 0        " keep selection readable (don't invert)
let g:gruvbox_sign_column    = 'bg1'      " sign column blends with background
silent! colorscheme gruvbox               " Apply the scheme

" TIP:  Toggle between dark/light with:
"         :set background=dark
"         :set background=light         

" ============================================================================
" [3]  STATUSLINE — vim-airline
" ============================================================================
" AIRLINE SECTION MAP (left → right):
"   section_a  — mode indicator (NORMAL, INSERT, VISUAL...)
"   section_b  — git branch name
"   section_c  — file name / path
"   section_x  — filetype
"   section_y  — file encoding + line endings
"   section_z  — line number / column
"
" NERD FONT REQUIREMENT
" ---------------------
" vim-airline powerline symbols and vim-devicons icons require a Nerd Font.
" Install one from: https://www.nerdfonts.com/font-downloads
" Recommended for terminal work: JetBrainsMono Nerd Font or FiraCode Nerd Font
"
" Then set it in your terminal:
"   GNOME Terminal : Preferences → Profile → Text → Custom Font
"   Alacritty      : ~/.config/alacritty/alacritty.toml
"                      [font] family = "JetBrainsMono Nerd Font"
"   Tmux           : no font setting needed — inherits from terminal
"
" If you cannot install a Nerd Font, disable icons:
"   let g:airline_powerline_fonts = 0
"   let g:webdevicons_enable = 0

" ── Tabline (buffer tabs at top of screen) ────────────────────────────────────
let g:airline#extensions#tabline#enabled = 1              " Show open buffers as tabs
let g:airline#extensions#tabline#left_sep = ' '           " Active & Inactive tab
let g:airline#extensions#tabline#left_alt_sep = '|' 
let g:airline#extensions#tabline#formatter = 'unique_tail' " filename in tabs (not full path)

" ── Statusline content ────────────────────────────────────────────────────────
let g:airline_theme = 'gruvbox'         " Use the powerlineish theme — clean separators, works well with gruvbox.
let g:airline_powerline_fonts = 1            " Enable powerline arrow-style

let g:webdevicons_enable_airline_tabline   = 1  " Enable devicons in tabline
let g:webdevicons_enable_airline_statusline = 1 " Enable devicons in statusline"

" ── Section customization ─────────────────────────────────────────────────────
let g:airline_section_b = ''                  " Hide Git branch or filename here
let g:airline_section_c = '%t'                " Only file name
let g:airline_section_x = ''                  " Hide encoding, fileformat
let g:airline_section_y = ''                  " Hide line info
let g:airline_section_z = 'Ln:%l/%L Col:%c'   " Line number / column info

" ============================================================================
" [4]  FILE EXPLORER — NERDTree
" ============================================================================
" Configure NERDTree's behavior and appearance.
" Ctrl+F — toggle NERDTree open/closed

let g:NERDTreeWinSize = 28                    " Set NERDTree window width
let g:NERDTreeHighlightCursorline = 0         " Keep NERDTree's cursor line highlight minimal
let g:NERDTreeQuitOnOpen = 1                  " Close NERDTree automatically after opening a file from it.
let g:NERDTreeShowBookmarks = 1               " Show bookmarks panel at the top of NERDTree

" Ignore generated build files in the NERDTree listing.
let g:NERDTreeIgnore = [
  \ '\.o$', '\.ko$', '\.d$', '\.map$', '\.dtb$',
  \ '\.pyc$', '\.swp$', '__pycache__',
  \ 'cscope\.out$', 'cscope\.files$',
  \ 'tags$'
  \ ]


" Auto-open NERDTree when Vim starts with no file argument (just 'vim').
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

"Close Vim if NERDTree is the only remaining window.
autocmd BufEnter * if tabpagenr('$') == 1
  \ && winnr('$') == 1
  \ && exists('b:NERDTree')
  \ && b:NERDTree.isTabTree()
  \ | quit | endif

" ============================================================================
" [5]  CODE STRUCTURE — Tagbar
" ============================================================================
"Configure Tagbar — the function/struct/enum outline sidebar.
"<F8> — toggle Tagbar (defined here and in key_mapping.vim)

let g:tagbar_width = 30          " Width of the Tagbar sidebar in columns.
let g:tagbar_autoclose = 1       " Auto-close Tagbar after jumping to a tag.
let g:tagbar_autofocus = 1       " Auto-focus the Tagbar window when it opens.
let g:tagbar_sort = 0            " Sort tags by their order (Set to 1 for alphabetical)
let g:tagbar_compact = 0         " Don't compact the tag display — show type categories as headers

" ============================================================================
" [6]  COMMENTING — NERDCommenter
" ============================================================================
" Configure NERDCommenter's behavior

let g:NERDSpaceDelims = 1           " Add a space after the comment delimiter.
let g:NERDCompactSexyComs = 1       " Use compact syntax for multi-line comments.
let g:NERDDefaultAlign = 'left'     " Align comment delimiters flush left rather than following indentation
let g:NERDCommentEmptyLines = 1     " Allow commenting empty lines
let g:NERDToggleCheckAllLines = 1   " Enable NERDCommenter for all filetypes

" ============================================================================
" [7]  BRACKET AUTO-CLOSE — auto-pairs
" ============================================================================
" Configure auto-pairs behavior for embedded C development.

let g:AutoPairsFlyMode = 1  " Jump over existing closing characters instead of inserting duplicates
let g:AutoPairsShortcutToggle = '<M-p>'  " Toggle auto-pairs on/off quickly (Alt+P flips it off)
let g:AutoPairsShortcutJump = '<M-e>'    " Jump out of the current enclosing pair (Alt+e)

" ============================================================================
" [8]  FUZZY FINDER — fzf + fzf.vim
" ============================================================================
" Configure fzf.vim commands and key mappings for fast navigation.

let g:fzf_layout = { 'down': '40%' }  " fzf window layout — open at the bottom

" Color fzf's UI to match the current Vim colorscheme.
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" ============================================================================
" [09]  SYNTAX PACK — vim-polyglot
" ============================================================================
"  vim-polyglot loads syntax files on demand for 100+ languages.

" Disable polyglot for filetypes where we manage syntax ourselves
let g:polyglot_disabled = ['c', 'cpp', 'markdown']

" ============================================================================
" [10]  MARKDOWN — vim-markdown
" ============================================================================
" Configure vim-markdown for documentation and README editing.

let g:vim_markdown_folding_disabled = 1           " Disable automatic folding of sections on file open
let g:vim_markdown_no_extensions_in_markdown = 1  " Allow following links without the .md extension
let g:vim_markdown_frontmatter = 1                " Highlight YAML front matter
let g:vim_markdown_strikethrough = 1              " Highlight strikethrough text (~~like this~~)
set conceallevel=2                                " conceal level for Markdown formatting characters
"   0 — show all raw syntax characters (** [ ] # etc.)
"   2 — conceal markers, show formatted result (bold, links look clean)


" ============================================================================
" [11]  AUTO-FORMAT — vim-autoformat
" ============================================================================
" Configure the formatter and which filetypes trigger it.
"
"FORMATTER SELECTION (in priority order):
"   1. clang-format  — C/C++ (the standard for kernel and BSP C code)
"   2. autopep8      — Python
"   3. prettier      — JSON, Markdown, YAML

let g:autoformat_autoindent          = 1
let g:autoformat_retab               = 1
let g:autoformat_remove_trailing_spaces = 1
let g:autoformat_verbosemode = 0

" ============================================================================
" [12]  EMBEDDED-SPECIFIC (optional plugins — uncomment to activate)
" ============================================================================

" ── Arduino (vim-arduino) ─────────────────────────────────────────────────────
"
" REQUIRES: Arduino CLI — https://arduino.github.io/arduino-cli/
"   curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
"
" COMMANDS PROVIDED:
"   :ArduinoChooseBoard    — select the target board
"   :ArduinoVerify         — compile the sketch
"   :ArduinoUpload         — compile and flash
"   :ArduinoSerial         — open serial monitor
"
"let g:arduino_cmd = 'arduino-cli'
"let g:arduino_dir = '/usr/share/arduino'

" ── PlatformIO (vim-pio) ──────────────────────────────────────────────────────
"
" REQUIRES: PlatformIO Core
"   pip install platformio
"   (or: curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py | python3)
"
" COMMANDS PROVIDED:
"   :PioRun      — build the project
"   :PioUpload   — build and flash
"   :PioMonitor  — open serial monitor
"   :PioInit     — initialize a new PlatformIO project

" ── Device Tree Syntax (vim-dt) ───────────────────────────────────────────────

let g:dt_highlight_hex = 1     " Highlight hex values like <0x1234abcd>
let g:dt_highlight_cell = 1    " Highlight cell arrays like <1 2 3>












