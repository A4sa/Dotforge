" ============================================================================
"
"        ██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗
"        ██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝
"        ██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗
"        ██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║
"        ██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║
"        ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝
"
"  File name   : plugin_config.vim
"  Author      : Abdul Sattar <abdul.linuxdev@gmail.com>
"  Repository  : https://github.com/A4sa/dotforge.git
"  Description : All plugin declarations AND their configuration in one file.
"                Sourced from ~/.vimrc.
" ===========================================================================


" ============================================================================
"  APT INSTALL CHECKLIST — tools required by plugins in this file
" --------------------------------------------------------------
"   sudo apt install vim-gtk3           (+python3 for UltiSnips, +clipboard)
"   sudo apt install universal-ctags    (Tagbar, :Tags)
"   sudo apt install cscope             (vimrc cscope section)
"   sudo apt install fzf ripgrep        (fzf.vim, :Rg)
"   sudo apt install clang-format       (vim-autoformat)
"   sudo apt install clangd bear        (LSP: go-to-definition, diagnostics)
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
    silent execute '!curl -fsLo ' . shellescape(s:plug_file) . ' --create-dirs '
      \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    let s:plug_fresh_install = filereadable(s:plug_file)
  else
    echo "WARNING: curl not found. Install curl and re-open Vim, or manually"
    echo "install vim-plug: https://github.com/junegunn/vim-plug#installation"
  endif
endif

" Without vim-plug there is nothing more to configure in this file.
if !filereadable(s:plug_file)
  finish
endif


" ============================================================================
" [1]  PLUGIN DECLARATIONS
" ============================================================================

call plug#begin('~/.vim/plugged')

" ── UI & Appearance ────────────────────────────────────────────────────────
Plug 'morhetz/gruvbox'                       " Warm, low-fatigue colour scheme
Plug 'vim-airline/vim-airline'               " Statusline - shows mode, filename, branch
Plug 'vim-airline/vim-airline-themes'        " Themes for airline
Plug 'ryanoasis/vim-devicons'                " File icons to airline and NERDTree

" ── Navigation ──────────────────────────────────────────────────────────────
Plug 'preservim/nerdtree'                    " Sidebar file explorer tree
Plug 'preservim/tagbar'                      " Show a tag-based code outline in a sidebar
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " Fuzzy finder CLI (needs install)
Plug 'junegunn/fzf.vim'                      " fzf — :Files, :Buffers, :Rg, :Tags, :Commits.

" ── Git ─────────────────────────────────────────────────────────────────────
Plug 'tpope/vim-fugitive'                    " :Git status/blame/diff/log inside Vim
Plug 'airblade/vim-gitgutter'                " +/-/~ signs for changed lines, hunk staging

" ── Editing Helpers ───────────────────────────────────────────────────────────
Plug 'jiangmiao/auto-pairs'                  " Automatically insert the closing bracket, paren, or quote
Plug 'preservim/nerdcommenter'               " Toggle, add, or remove code comments with a single mapping
Plug 'vim-autoformat/vim-autoformat'         " :Autoformat with clang-format / black / etc.
Plug 'tpope/vim-surround'                    " cs\"' — change/add/delete surrounding quotes, parens, tags

" UltiSnips needs Vim built with +python3 (vim-gtk3 / vim-nox have it).
if has('python3')
  Plug 'SirVer/ultisnips'                    " Snippet engine — ~/.vim/UltiSnips/*.snippets
endif

" ── Language & Syntax Support ─────────────────────────────────────────────────
Plug 'preservim/vim-markdown'                " Enhanced Markdown support — syntax, folding, concealment
" Device Tree (.dts/.dtsi) syntax ships with Vim itself — no plugin needed.

" ── LSP (clangd for C/C++, pylsp for Python) — only when a server exists ──
" clangd gives exact go-to-definition, references, hover and diagnostics,
" driven by compile_commands.json (generate it with the shell function: kccdb).
if executable('clangd') || executable('pylsp')
  Plug 'prabirshrestha/vim-lsp'
endif

" ── Embedded-Specific (Optional) ─────────────────────────────────────────────
"Plug 'stevearc/vim-arduino'                 " Arduino CLI integration — compile, upload, serial monitor from Vim.
"Plug 'normen/vim-pio'                       " PlatformIO project management inside Vim.

call plug#end()

" On a brand-new machine (first-time bootstrap), install all plugins without :PlugInstall.
if s:plug_fresh_install
  autocmd dotforge VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Vim 9.1 ships EditorConfig support. Projects that carry a .editorconfig
" (many BSP and userspace repos do) get their own indent rules automatically.
silent! packadd! editorconfig


" ============================================================================
" [2]  COLORSCHEME — gruvbox
" ============================================================================
" gruvbox CONTRAST OPTIONS:
"   hard   — highest contrast, sharpest differentiation (good for bright rooms)
"   medium — balanced, the default (recommended for most setups)
"   soft   — lower contrast, easier on eyes in dark rooms / long sessions

let g:gruvbox_contrast_dark  = 'hard'   " dark mode contrast: hard/medium/soft
let g:gruvbox_contrast_light = 'light'     " light mode contrast
let g:gruvbox_italic         = 1          " enable italics (comments, keywords)
let g:gruvbox_bold           = 1          " enable bold (types, constants)
let g:gruvbox_invert_selection = 0        " keep selection readable (don't invert)
let g:gruvbox_sign_column    = 'bg0'      " sign column blends with background
" Fall back to a built-in scheme if gruvbox is not installed yet.
try
  colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme desert
endtry

" TIP:  Toggle between dark/light with:
"         :set background=dark
"         :set background=light

" ============================================================================
" [3]  STATUSLINE — vim-airline
" ============================================================================
" AIRLINE SECTION MAP (left → right):
"   section_a  — mode indicator (NORMAL, INSERT, VISUAL...)
"   section_b  — git hunks + branch name
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
" If you cannot install a Nerd Font, put these in ~/.vimrc.local:
"   let g:airline_powerline_fonts = 0
"   let g:webdevicons_enable = 0

" ── Tabline (buffer tabs at top of screen) ────────────────────────────────────
let g:airline#extensions#tabline#enabled = 1              " Show open buffers as tabs
let g:airline#extensions#tabline#left_sep = ' '           " Active & Inactive tab
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail' " filename in tabs (not full path)
let g:airline#extensions#tabline#buffer_idx_mode = 1      " Numbers on tabs: <Leader>1..9 jumps

" ── Statusline content ────────────────────────────────────────────────────────
let g:airline_theme = 'gruvbox'
let g:airline_powerline_fonts = get(g:, 'airline_powerline_fonts', 1)

let g:webdevicons_enable_airline_tabline   = 1  " Enable devicons in tabline
let g:webdevicons_enable_airline_statusline = 1 " Enable devicons in statusline

" ── Section customization ─────────────────────────────────────────────────────
" section_b keeps airline's default: git hunk summary + branch (via fugitive).
let g:airline_section_c = '%t'                " Only file name
let g:airline_section_y = ''                  " Hide encoding / fileformat
let g:airline_section_z = 'Ln:%l/%L Col:%c'   " Line number / column info
" Warn about mixed tabs/spaces and trailing whitespace in the statusline.
let g:airline#extensions#whitespace#enabled = 1

" ============================================================================
" [4]  FILE EXPLORER — NERDTree
" ============================================================================
" Ctrl+F — toggle NERDTree open/closed

let g:NERDTreeWinSize = 30                    " Set NERDTree window width
let g:NERDTreeHighlightCursorline = 0         " Keep NERDTree's cursor line highlight minimal
let g:NERDTreeQuitOnOpen = 1                  " Close NERDTree automatically after opening a file from it.
let g:NERDTreeShowBookmarks = 1               " Show bookmarks panel at the top of NERDTree
let g:NERDTreeMinimalUI = 1                   " Hide the 'Press ? for help' banner

" Ignore generated build files in the NERDTree listing.
let g:NERDTreeIgnore = [
  \ '\.o$', '\.ko$', '\.mod$', '\.mod\.c$', '\.d$', '\.map$', '\.dtb$', '\.dtbo$',
  \ '\.cmd$', '\.order$', '\.symvers$',
  \ '\.pyc$', '\.swp$', '__pycache__',
  \ '^cscope\.', '^tags$', '^compile_commands\.json$'
  \ ]

" Auto-open NERDTree when Vim starts with no file argument (just 'vim'),
" but not when reading from stdin (e.g. 'dmesg | vim -').
autocmd dotforge StdinReadPre * let s:std_in = 1
autocmd dotforge VimEnter * if argc() == 0 && !exists('s:std_in') && exists(':NERDTree') | NERDTree | endif

" Close Vim if NERDTree is the only remaining window.
autocmd dotforge BufEnter * if tabpagenr('$') == 1
  \ && winnr('$') == 1
  \ && exists('b:NERDTree')
  \ && b:NERDTree.isTabTree()
  \ | quit | endif

" ============================================================================
" [5]  CODE STRUCTURE — Tagbar
" ============================================================================
" <F8> — toggle Tagbar (key_mapping.vim)

let g:tagbar_width = 32          " Width of the Tagbar sidebar in columns.
let g:tagbar_autoclose = 1       " Auto-close Tagbar after jumping to a tag.
let g:tagbar_autofocus = 1       " Auto-focus the Tagbar window when it opens.
let g:tagbar_sort = 0            " Keep source order (1 = alphabetical)
let g:tagbar_compact = 1         " Hide the help line

" ============================================================================
" [6]  COMMENTING — NERDCommenter
" ============================================================================

let g:NERDSpaceDelims = 1           " Add a space after the comment delimiter.
let g:NERDCompactSexyComs = 1       " Use compact syntax for multi-line comments.
let g:NERDDefaultAlign = 'left'     " Align comment delimiters flush left rather than following indentation
let g:NERDCommentEmptyLines = 1     " Allow commenting empty lines
let g:NERDToggleCheckAllLines = 1   " Toggle uncomments only if ALL selected lines are commented

" ============================================================================
" [7]  BRACKET AUTO-CLOSE — auto-pairs
" ============================================================================

let g:AutoPairsFlyMode = 0               " Fly mode jumps unpredictably over ')' — off
let g:AutoPairsShortcutToggle = '<M-p>'  " Toggle auto-pairs on/off (Alt+P)
let g:AutoPairsShortcutJump = '<M-e>'    " Jump out of the current pair (Alt+E)
let g:AutoPairsMultilineClose = 0        " Don't jump to a ')' on a later line

" ============================================================================
" [8]  FUZZY FINDER — fzf + fzf.vim
" ============================================================================

let g:fzf_layout = { 'down': '40%' }  " fzf window layout — open at the bottom
let g:fzf_preview_window = ['right,50%,<70(up,40%)', 'ctrl-/']

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
" [9]  GIT — fugitive + gitgutter
" ============================================================================
" Hunk navigation uses ]h / [h (key_mapping.vim) so ]c / [c stay free for
" Vim's own diff-mode navigation.
let g:gitgutter_map_keys = 0
let g:gitgutter_max_signs = 2000        " Big generated diffs: don't stall the UI

" ============================================================================
" [10]  MARKDOWN — vim-markdown
" ============================================================================

let g:vim_markdown_folding_disabled = 1           " Disable automatic folding of sections on file open
let g:vim_markdown_no_extensions_in_markdown = 1  " Allow following links without the .md extension
let g:vim_markdown_frontmatter = 1                " Highlight YAML front matter
let g:vim_markdown_strikethrough = 1              " Highlight strikethrough text (~~like this~~)
" Conceal markdown markup only in markdown buffers (not globally).
autocmd dotforge FileType markdown setlocal conceallevel=2


" ============================================================================
" [11]  AUTO-FORMAT — vim-autoformat
" ============================================================================
" Formatting is manual (<Leader>F) or opt-in on save (:FormatOnSave, vimrc).
" Never fall back to Vim's re-indent or retab — on a file without a
" formatter that would rewrite every line.
let g:autoformat_autoindent             = 0
let g:autoformat_retab                  = 0
let g:autoformat_remove_trailing_spaces = 0
let g:autoformat_verbosemode            = 0

" ============================================================================
" [12]  SNIPPETS — UltiSnips
" ============================================================================
" Tab expands a snippet and jumps forward; Shift-Tab jumps back.
" :UltiSnipsEdit opens the snippet file for the current filetype.
let g:UltiSnipsExpandTrigger       = '<Tab>'
let g:UltiSnipsJumpForwardTrigger  = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
let g:UltiSnipsEditSplit           = 'vertical'
let g:UltiSnipsSnippetDirectories  = ['UltiSnips']

" ============================================================================
" [13]  LSP — vim-lsp (clangd / pylsp)
" ============================================================================
" Generate compile_commands.json once per tree:
"   kernel / U-Boot :  kccdb      (shell function — wraps the kernel's script)
"   any make project:  bear -- make
"   CMake           :  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
"
" Without compile_commands.json clangd still works for small projects, but in
" a kernel tree it cannot resolve the arch includes — cscope remains the
" fallback there.
if executable('clangd')
  autocmd dotforge User lsp_setup call lsp#register_server({
    \ 'name': 'clangd',
    \ 'cmd': {server_info -> ['clangd', '--background-index', '--header-insertion=never', '-j=4']},
    \ 'allowlist': ['c', 'cpp'],
    \ })
endif
if executable('pylsp')
  autocmd dotforge User lsp_setup call lsp#register_server({
    \ 'name': 'pylsp',
    \ 'cmd': {server_info -> ['pylsp']},
    \ 'allowlist': ['python'],
    \ })
endif

let g:lsp_diagnostics_virtual_text_enabled = 0   " Signs + echo, not inline text
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_document_highlight_enabled = 0

" Buffer-local mappings only where an LSP server is attached — elsewhere
" gd / K / Ctrl-] keep their normal (cscope / ctags) meaning.
function! s:OnLspBufferEnabled() abort
  setlocal omnifunc=lsp#complete
  nmap <buffer> gd <Plug>(lsp-definition)
  nmap <buffer> gD <Plug>(lsp-declaration)
  nmap <buffer> gr <Plug>(lsp-references)
  nmap <buffer> gi <Plug>(lsp-implementation)
  nmap <buffer> K  <Plug>(lsp-hover)
  nmap <buffer> <Leader>rn <Plug>(lsp-rename)
  nmap <buffer> <Leader>la <Plug>(lsp-code-action)
  nmap <buffer> [d <Plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d <Plug>(lsp-next-diagnostic)
  nmap <buffer> <Leader>ld <Plug>(lsp-document-diagnostics)
endfunction
autocmd dotforge User lsp_buffer_enabled call s:OnLspBufferEnabled()

" ============================================================================
" [14]  EMBEDDED-SPECIFIC (optional plugins — uncomment to activate)
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
"
" COMMANDS PROVIDED:
"   :PioRun      — build the project
"   :PioUpload   — build and flash
"   :PioMonitor  — open serial monitor
"   :PioInit     — initialize a new PlatformIO project
