" ============================================================================
"
"    ██╗  ██╗███████╗██╗   ██╗███╗   ███╗ █████╗ ██████╗ ███████╗
"    ██║ ██╔╝██╔════╝╚██╗ ██╔╝████╗ ████║██╔══██╗██╔══██╗██╔════╝
"    █████╔╝ █████╗   ╚████╔╝ ██╔████╔██║███████║██████╔╝███████╗
"    ██╔═██╗ ██╔══╝    ╚██╔╝  ██║╚██╔╝██║██╔══██║██╔═══╝ ╚════██║
"    ██║  ██╗███████╗   ██║   ██║ ╚═╝ ██║██║  ██║██║     ███████║
"    ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝
"  
"  File name   : key_mapping 
"  Author      : Abdul Sattar  <abdul.linuxdev@gmail.com>
"  Repository  : https://github.com/A4sa/vimrc-Embedded.git
"
"  ┌──────────────────────────────────────────────────────────────┐
"  │  HOW TO READ THIS FILE                                       │
"  │                                                              │
"  │  Every mapping documents:                                    │
"  │    KEY    — the actual keystrokes                            │
"  │    MODE   — where it works (Normal / Visual / Insert)        │
"  │    WHAT   — what it does                                     │
"  │    WHY    — why an embedded dev wants it on that key         │
"  │                                                              │
"  │  NOTATION REMINDER                                           │
"  │    <Leader>   = Space (configured below)                     │
"  │    <C-X>      = Ctrl + X                                     │
"  │    <A-X>      = Alt  + X                                     │
"  │    <S-X>      = Shift + X                                    │
"  │    <CR>       = Enter / Return                               │
"  │    <Esc>      = Escape                                       │
"  │    nnoremap   = Normal mode, non-recursive                   │
"  │    vnoremap   = Visual mode, non-recursive                   │
"  │    inoremap   = Insert mode, non-recursive                   │
"  │    noremap    = Normal + Visual, non-recursive               │
"  │                                                              │                    
"  └──────────────────────────────────────────────────────────────┘
"
" ======================================================================


" ============================================================================
" [1]  LEADER KEY
" ============================================================================
let mapleader=" "                      " Remap leader key to Space
let maplocalleader = "\\"              " 


" ============================================================================
" [2]  FILE OPERATIONS
" ============================================================================

nnoremap <C-S> :w<CR>                 " Save file (Ctrl+S)
nnoremap <C-Q> :q<CR>                 " Close file (Ctrl+Q)
nnoremap <Leader>w :wa<CR>            " Save all file in Open Buffer (<Leader>w)
nnoremap <Leader>q :qa<CR>            " Close vim entirely (<Leader>q)
nnoremap <Leader>x :wq<CR>            " Save and  Close file (<Leader>x)

nnoremap <F2> :set nonumber norelativenumber<CR>
nnoremap <F3> :set number relativenumber<CR>

" ============================================================================
" [3]  BUFFER NAVIGATION
" ============================================================================
nnoremap <Tab> :bn<CR>                " Next buffer (Tab)
nnoremap <S-Tab> :bprevious<CR>       " Previous buffer (Shift+Tab)

"Jump directly to buffer number 1–9 by position in the tabline
nnoremap <Leader>1 :bfirst<CR>
nnoremap <Leader>2 :exe 'buffer' (bufnr('%') + 0)<CR> nnoremap <Leader>] :bnext<CR> nnoremap <Leader>[ :bprevious<CR>

nnoremap <Leader>d :bd<CR>           " Close the current buffer without closing the window


" ============================================================================
" [4]  WINDOW SPLITS & NAVIGATION
" ============================================================================
nnoremap <Leader>v :vsplit<CR>  " Open a vertical split (side by side)
nnoremap <Leader>s :split<CR>   " Open a horizontal split (top and bottom).

" Easy split navigation using Ctrl+H/J/K/L
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize the Current Window using Ctrl+Up/Down/Left/Right
nnoremap <C-Up>    :resize +2<CR>
nnoremap <C-Down>  :resize -2<CR>
nnoremap <C-Left>  :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

nnoremap <Leader>o <C-w>o     "  Maximize the current window (close all other splits temporarily)


" ============================================================================
" [5]  SEARCH & HIGHLIGHT
" ============================================================================
nnoremap <Leader>/ :nohlsearch<CR>    " Clear all search highlights

"Search for the word under the cursor across all open buffers.
"Place cursor on a function name (e.g., gpio_request) and <Leader>* finds all occurrences
"in every open buffer, populating the quickfix list.
nnoremap <Leader>* :vimgrep /<C-r><C-w>/gj ##<CR>:copen<CR>

"Search and replace the word under the cursor across the whole file.
"Place cursor on 'gpio_request', press <Leader>sr, type new name, Enter.
nnoremap <Leader>sr :%s/\<<C-r><C-w>\>//gc<Left><Left><Left>


" ============================================================================
" [6]  CLIPBOARD  (system copy / paste)
" ============================================================================

vnoremap <leader>y "+y      " Copy the visual selection to the system clipboard
nnoremap <leader>Y "+yg_    " Copy from cursor to end of line into the system clipboard
nnoremap <Leader>yy "+yy    " Copy the entire current line to the system clipboard. 
nnoremap <leader>p "+p      " Paste from the system clipboard after the cursor. 
vnoremap <Leader>p "_dP     "  Paste clipboard over visual selection without clobbering the clipboard

" ============================================================================
" [7]  LINE OPERATIONS
" ============================================================================

" Move the current line (or visual selection) down/up with Alt+J / Alt+K.
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Duplicate the current line below.
nnoremap <Leader>dl yyp

" ============================================================================
" [8]  INSERT MODE HELPERS
" ============================================================================

" Exit insert mode — alternative to pressing Escape.
inoremap jj <Esc>
inoremap jk <Esc>

" Save the file without leaving insert mode.
inoremap <C-S> <Esc>:w<CR>a

" Undo the last change and stay in normal mode.
inoremap <C-Z> <Esc>u


" ============================================================================
" [9]  NAVIGATION HELPERS
" ============================================================================

" Move to the first non-blank character of the current line.
nnoremap H ^

" Move to the last non-blank character of the current line.
nnoremap L $

" Jump 10 lines down/up.
nnoremap <Leader>j 10j
nnoremap <Leader>k 10k


" ============================================================================
" [10]  NERDTREE
" ============================================================================

" Toggle the NERDTree file explorer open and closed.
nnoremap <C-F> :NERDTreeToggle<CR>

" Find and reveal the currently open file inside NERDTree.
nnoremap <Leader>nf :NERDTreeFind<CR>

" Refresh the NERDTree (re-read directory contents from disk).
nnoremap <Leader>nr :NERDTreeRefreshRoot<CR>


" ============================================================================
" [11]  TAGBAR
" ============================================================================

" Toggle the Tagbar code outline sidebar.
nmap <F8> :TagbarToggle<CR>

" Jump to the Tagbar window without toggling (if already open).
nnoremap <Leader>tb :TagbarOpen fj<CR>


" ============================================================================
" [12]  FZF — FUZZY FINDER
" ============================================================================

" Fuzzy-search all files in the project tree (Ctrl + P).
nnoremap <C-p> :Files<CR>

" Fuzzy-search open buffers by name.
nnoremap <Leader>b :Buffers<CR>

" Ripgrep search across all file contents with fzf interface.
nnoremap <Leader>rg :Rg<CR>

" Ripgrep for the exact word under the cursor.
" Place cursor on 'platform_driver_register', press <Leader>rw —
"       instantly shows every file where that symbol is used.
nnoremap <Leader>rw :Rg <C-r><C-w><CR>

" Fuzzy-search ctags symbols (functions, structs, macros, enums).
nnoremap <Leader>tg :Tags<CR>

" Browse git commit history with fzf.
nnoremap <Leader>gc :Commits<CR>

" Search Vim's help with fzf.
nnoremap <Leader>hh :Helptags<CR>

" ============================================================================
" [13]  CSCOPE — SYMBOL NAVIGATION
" ============================================================================
"
" WHY CSCOPE MAPPINGS MATTER
" --------------------------
" ctags tells you WHERE a symbol is defined (one result).
" cscope tells you EVERYTHING about a symbol (multiple results):
"
"   Find all callers of a function    → who calls probe()?
"   Find the definition of a symbol   → where is struct platform_driver?
"   Find all assignments to a var     → where is irq_handler set?
"   Find files including a header     → who includes linux/gpio.h?
"   Find all uses of a text string    → where is "compatible" string used?
"
" NAMESPACE: Ctrl+\ prefix for cscope — unambiguous, doesn't overlap
" with any Vim built-in in normal mode.
"
" USAGE PATTERN:
"   Place cursor on a symbol → press the mapping → results in quickfix list
"   Navigate results with:
"     :cn   — next result
"     :cp   — previous result
"     :ccl  — close quickfix
"     (or use the <Leader>cn/<Leader>cp mappings defined in [15])

" Find all CALLERS of the function under the cursor.
nnoremap <C-\>c :cs find c <C-r>=expand('<cword>')<CR><CR>

" Find the DEFINITION of the symbol under the cursor.
nnoremap <C-\>d :cs find g <C-r>=expand('<cword>')<CR><CR>

" Find all REFERENCES (uses) of the symbol under the cursor.
nnoremap <C-\>r :cs find s <C-r>=expand('<cword>')<CR><CR>

" Find all files that #include the header under the cursor.
nnoremap <C-\>i :cs find i <C-r>=expand('<cfile>')<CR><CR>

" Find a TEXT string (not just symbol names) across the codebase.
nnoremap <C-\>t :cs find t <C-r>=expand('<cword>')<CR><CR>

" Open the FILE whose name matches the word under the cursor.
nnoremap <C-\>f :cs find f <C-r>=expand('<cfile>')<CR><CR>

" CSCOPE FIND CODES REFERENCE:
"   0 / s — symbol:   find all references to this C symbol
"   1 / g — global:   find the global definition of this symbol
"   2 / d — called:   find functions called BY this function
"   3 / c — callers:  find functions calling this function
"   4 / t — text:     find this text string
"   6 / e — egrep:    find this egrep pattern
"   7 / f — file:     find this file
"   8 / i — includes: find files #including this file
"   9 / a — assigns:  find places where this symbol is assigned a value


" ============================================================================
" [14]  QUICKFIX & LOCATION LIST
" ============================================================================

" Jump to the NEXT entry in the quickfix list.
nnoremap <Leader>cn :cnext<CR>

" Jump to the PREVIOUS entry in the quickfix list.
nnoremap <Leader>cp :cprevious<CR>

" OPEN the quickfix window (show the list).
nnoremap <Leader>co :copen<CR>

" CLOSE the quickfix window.
nnoremap <Leader>cq :cclose<CR>

" Jump to the FIRST entry in the quickfix list.
nnoremap <Leader>cf :cfirst<CR>

" Jump to the LAST entry in the quickfix list.
nnoremap <Leader>cl :clast<CR>


" ============================================================================
" [15]  BUILD INTEGRATION
" ============================================================================

" Run make (using the Makefile in the current or parent directory).
nnoremap <Leader>m :make<CR>

" Open the quickfix list after a build to see errors.
nnoremap <Leader>me :make<CR>:copen<CR>


" ============================================================================
" [16]  NERDCOMMENTER — REFERENCE
" ============================================================================
"
" MAPPINGS (auto-created by NERDCommenter — no nnoremap needed):
"
"   <Leader>cc    — Comment out the current line or visual selection
"                   In C:  /* code */
"                   In Python/Shell:  # code
"                   NERDCommenter detects the filetype automatically.
"
"   <Leader>cu    — Uncomment the current line or visual selection.
"
"   <Leader>c<Space>  — TOGGLE comment state (most useful — use this one).
"                       Commented → uncomments. Uncommented → comments.
"
"   <Leader>ci    — Invert comment state per line in a selection.
"                   (uncommented lines get commented, commented get uncommented)
"
"   <Leader>cs    — Comment in "sexy" block style:
"                   /*
"                    * code here
"                    */
"
"   <Leader>cm    — Comment with minimal formatting (single /* */ block).
"
"   <Leader>ca    — Switch to an alternative delimiter for the filetype.
"                   In C: toggles between /* */ and // styles.
"
" TIP: In visual mode, select multiple lines with V, then <Leader>cc
"      to comment the whole block at once.


" ============================================================================
" [17]  CODE FOLDING — REFERENCE
" ============================================================================
"
" FOLD COMMANDS:
"   za    — Toggle fold under cursor (open if closed, close if open).
"           The one you use 90% of the time.
"
"   zo    — Open  the fold under cursor (one level).
"   zO    — Open  the fold under cursor (all levels recursively).
"   zc    — Close the fold under cursor (one level).
"   zC    — Close the fold under cursor (all levels recursively).
"
"   zM    — Close ALL folds in the file.
"           Useful to get a bird's-eye view of a large driver's structure.
"
"   zR    — Open ALL folds in the file (restore full view).
"
"   zj    — Move to the START of the next fold.
"   zk    — Move to the END of the previous fold.
"
"   [z    — Move to the start of the current open fold.
"   ]z    — Move to the end of the current open fold.
"
" FOLD METHODS (set in .vimrc or per-filetype):
"   set foldmethod=syntax   — fold based on language syntax (C structs, #ifdef)
"   set foldmethod=indent   — fold based on indentation level
"   set foldmethod=marker   — fold between {{{ and }}} markers in comments
"   set foldmethod=manual   — fold only regions you define with 'zf'
"


" ============================================================================
" [18]  MARKDOWN
" ============================================================================

" Start the Markdown live preview in a browser.
nnoremap <Leader>mp :MarkdownPreview<CR>

" Stop the Markdown live preview.
nnoremap <Leader>ms :MarkdownPreviewStop<CR>


" ============================================================================
" [19]  TERMINAL
" ============================================================================

" Open a terminal in a horizontal split below the current window.
nnoremap <Leader>t :below terminal<CR>

" Open a terminal in a vertical split to the right.
nnoremap <Leader>tv :vertical terminal<CR>


" ============================================================================
" COMPLETE MAPPING REFERENCE (alphabetical by key)
" ============================================================================
"
"  KEY              MODE    ACTION
"  ──────────────────────────────────────────────────────────────────────────
"  <Tab>            N       Next buffer
"  <S-Tab>          N       Previous buffer
"  H                N       Line start (first non-blank)
"  L                N       Line end (last non-blank)
"  <C-h/j/k/l>      N       Move focus to left/down/up/right window
"  <C-p>            N       fzf file search
"  <C-F>            N       NERDTree toggle
"  <C-S>            N/I     Save file
"  <C-Q>            N       Close window
"  <C-Up/Down>      N       Resize window height
"  <C-Left/Right>   N       Resize window width
"  <C-\>c           N       cscope: find callers
"  <C-\>d           N       cscope: find definition
"  <C-\>r           N       cscope: find all references
"  <C-\>i           N       cscope: find #includes
"  <C-\>t           N       cscope: find text string
"  <C-\>f           N       cscope: open file
"  <A-j/k>          N/V     Move line(s) down/up
"  <F2>             N       Hide line numbers
"  <F3>             N       Show line numbers
"  <F8>             N       Tagbar toggle
"  jj / jk          I       Exit insert mode
"  <Leader>/        N       Clear search highlights
"  <Leader>*        N       Search word under cursor in all buffers
"  <Leader>[        N       Previous buffer
"  <Leader>]        N       Next buffer
"  <Leader>1        N       First buffer
"  <Leader>b        N       fzf buffer switcher
"  <Leader>cn/cp    N       Quickfix next/previous
"  <Leader>co/cq    N       Quickfix open/close
"  <Leader>cf/cl    N       Quickfix first/last
"  <Leader>d        N       Delete (close) current buffer
"  <Leader>D        N       Force-delete current buffer
"  <Leader>dl       N       Duplicate current line
"  <Leader>hh       N       fzf help search
"  <Leader>j/k      N       Jump 10 lines down/up
"  <Leader>m        N       Run make
"  <Leader>me       N       Run make + open quickfix
"  <Leader>mp/ms    N       Markdown preview start/stop
"  <Leader>nf       N       NERDTree find current file
"  <Leader>nr       N       NERDTree refresh
"  <Leader>o        N       Maximize current window
"  <Leader>p/P      N       Paste from system clipboard after/before
"  <Leader>p        V       Paste without clobbering clipboard
"  <Leader>q        N       Quit all windows
"  <Leader>rg       N       ripgrep search (fzf)
"  <Leader>rw       N       ripgrep word under cursor
"  <Leader>s        N       Horizontal split
"  <Leader>sr       N       Search and replace word under cursor
"  <Leader>t        N       Open terminal (horizontal)
"  <Leader>tb       N       Focus Tagbar
"  <Leader>tg       N       fzf ctags symbol search
"  <Leader>tv       N       Open terminal (vertical)
"  <Leader>v        N       Vertical split
"  <Leader>w        N       Save all buffers
"  <Leader>x        N       Save and close
"  <Leader>Y        N       Yank to end of line → clipboard
"  <Leader>y        V       Yank selection → clipboard
"  <Leader>yy       N       Yank line → clipboard
"  <Leader>=        N       Equalize window sizes
"  ──────────────────────────────────────────────────────────────────────────

