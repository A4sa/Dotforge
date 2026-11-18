" ============================================================================
"
"    ██╗  ██╗███████╗██╗   ██╗███╗   ███╗ █████╗ ██████╗ ███████╗
"    ██║ ██╔╝██╔════╝╚██╗ ██╔╝████╗ ████║██╔══██╗██╔══██╗██╔════╝
"    █████╔╝ █████╗   ╚████╔╝ ██╔████╔██║███████║██████╔╝███████╗
"    ██╔═██╗ ██╔══╝    ╚██╔╝  ██║╚██╔╝██║██╔══██║██╔═══╝ ╚════██║
"    ██║  ██╗███████╗   ██║   ██║ ╚═╝ ██║██║  ██║██║     ███████║
"    ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝
"
"  File name   : key_mapping.vim
"  Author      : Abdul Sattar  <abdul.linuxdev@gmail.com>
"  Repository  : https://github.com/A4sa/dotforge.git
"
"  ┌──────────────────────────────────────────────────────────────┐
"  │  HOW TO READ THIS FILE                                       │
"  │                                                              │
"  │  Every mapping documents WHAT it does and WHY.               │
"  │                                                              │
"  │  !! Comments go on their OWN line above a mapping. In Vim,   │
"  │  a '"' after a :map command is part of the mapping and gets  │
"  │  executed as keystrokes.                                     │
"  │                                                              │
"  │  NOTATION REMINDER                                           │
"  │    <Leader>   = Space (configured below)                     │
"  │    <C-X>      = Ctrl + X                                     │
"  │    <M-X>      = Alt  + X                                     │
"  │    <S-X>      = Shift + X                                    │
"  │    nnoremap   = Normal mode, non-recursive                   │
"  │    xnoremap   = Visual mode, non-recursive                   │
"  │    inoremap   = Insert mode, non-recursive                   │
"  │                                                              │
"  │  PREFIX GROUPS (one prefix per area, no overlaps):           │
"  │    <Leader>f…  find (fzf)     <Leader>g…  git                │
"  │    <Leader>h…  git hunks      <Leader>c…  comments/qf/check  │
"  │    <Leader>n…  NERDTree       <Leader>t…  tags / terminal    │
"  │    <Leader>l…  LSP            <Leader>e…  edit config        │
"  │    <C-\>…      cscope         ]x / [x     next / previous    │
"  └──────────────────────────────────────────────────────────────┘
"
" ======================================================================


" ============================================================================
" [1]  LEADER KEY
" ============================================================================
" Space is the biggest key and is a no-op in Normal mode.
let mapleader = " "
let maplocalleader = "\\"
nnoremap <Space> <Nop>


" ============================================================================
" [0]  ALT KEYS IN A TERMINAL
" ============================================================================
" Terminals send Alt+j as 'Esc j'. Tell terminal Vim about it so <M-j>
" mappings work (with ttimeoutlen=10 this does not slow down Esc).
if !has('gui_running') && !has('nvim')
  for s:key in ['j', 'k', 'p', 'e']
    execute 'set <M-' . s:key . ">=\<Esc>" . s:key
  endfor
endif


" ============================================================================
" [2]  FILE OPERATIONS
" ============================================================================

" Save (Ctrl+S) in Normal, Insert and Visual mode.
" Needs 'stty -ixon' in the shell (dotforge bashrc does it) or the
" terminal freezes on Ctrl+S.
nnoremap <C-S> :update<CR>
inoremap <C-S> <C-o>:update<CR>
xnoremap <C-S> <Esc>:update<CR>gv

" Close the window (Ctrl+Q).
nnoremap <C-Q> :q<CR>

" Save all buffers.
nnoremap <Leader>w :wall<CR>

" Quit Vim (asks about unsaved buffers thanks to 'confirm').
nnoremap <Leader>q :qall<CR>

" Save (only if changed) and close.
nnoremap <Leader>x :x<CR>

" F2: toggle line numbers (clean copy with the mouse / for screenshots).
nnoremap <silent> <F2> :set number! relativenumber!<CR>

" F3: toggle visible tabs / trailing whitespace.
nnoremap <silent> <F3> :set list!<CR>

" F7: toggle spell check.
nnoremap <silent> <F7> :setlocal spell!<CR>


" ============================================================================
" [3]  BUFFER NAVIGATION
" ============================================================================

" Next / previous buffer.
nnoremap <silent> <Tab>   :bnext<CR>
nnoremap <silent> <S-Tab> :bprevious<CR>
nnoremap <silent> <Leader>] :bnext<CR>
nnoremap <silent> <Leader>[ :bprevious<CR>

" Jump to buffer 1–9 by the number shown in the airline tabline.
for s:n in range(1, 9)
  execute 'nmap <Leader>' . s:n . ' <Plug>AirlineSelectTab' . s:n
endfor

" Close the current buffer but keep the window layout (NERDTree / splits stay).
nnoremap <silent> <Leader>d :bprevious <Bar> bdelete #<CR>

" Force-close the current buffer, discarding changes.
nnoremap <silent> <Leader>D :bdelete!<CR>


" ============================================================================
" [4]  WINDOW SPLITS & NAVIGATION
" ============================================================================

" Vertical split (side by side) / horizontal split (top and bottom).
nnoremap <Leader>v :vsplit<CR>
nnoremap <Leader>s :split<CR>

" Move between splits with Ctrl+H/J/K/L.
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize the current window with Ctrl+Arrows.
nnoremap <silent> <C-Up>    :resize +2<CR>
nnoremap <silent> <C-Down>  :resize -2<CR>
nnoremap <silent> <C-Left>  :vertical resize -2<CR>
nnoremap <silent> <C-Right> :vertical resize +2<CR>

" Keep only the current window / make all windows equal size.
nnoremap <Leader>o <C-w>o
nnoremap <Leader>= <C-w>=


" ============================================================================
" [5]  SEARCH & HIGHLIGHT
" ============================================================================

" Clear search highlights.
nnoremap <silent> <Leader>/ :nohlsearch<CR>

" Keep search matches in the middle of the screen.
nnoremap n nzzzv
nnoremap N Nzzzv

" Search the word under the cursor across the whole project (ripgrep via
" 'grepprg'), results in the quickfix list.
" Example: cursor on gpio_request → <Leader>* → every use in the tree.
nnoremap <silent> <Leader>* :silent grep! -w <C-r><C-w><CR>:redraw!<CR>:cwindow<CR>

" Substitute the word under the cursor in the whole file (asks each time).
nnoremap <Leader>S :%s/\<<C-r><C-w>\>//gc<Left><Left><Left>


" ============================================================================
" [6]  CLIPBOARD  (system copy / paste)
" ============================================================================

" Copy the visual selection to the system clipboard.
xnoremap <Leader>y "+y
" Copy from the cursor to end of line / the whole line to the clipboard.
nnoremap <Leader>Y "+y$
nnoremap <Leader>yy "+yy
" Paste from the system clipboard after / before the cursor.
nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
" Paste over a selection without losing what you are pasting.
xnoremap <Leader>p "_dP

" Y yanks to end of line, consistent with D and C.
nnoremap Y y$


" ============================================================================
" [7]  LINE OPERATIONS
" ============================================================================

" Move the current line (or visual selection) down/up with Alt+J / Alt+K.
nnoremap <silent> <M-j> :move .+1<CR>==
nnoremap <silent> <M-k> :move .-2<CR>==
xnoremap <silent> <M-j> :move '>+1<CR>gv=gv
xnoremap <silent> <M-k> :move '<-2<CR>gv=gv

" Indent in visual mode without losing the selection.
xnoremap < <gv
xnoremap > >gv


" ============================================================================
" [8]  INSERT MODE HELPERS
" ============================================================================

" Exit insert mode — alternative to pressing Escape.
inoremap jk <Esc>
inoremap jj <Esc>

" Undo the last change and return to normal mode.
inoremap <C-Z> <Esc>u


" ============================================================================
" [9]  NAVIGATION HELPERS
" ============================================================================

" First / last non-blank character of the line.
nnoremap H ^
nnoremap L g_
xnoremap H ^
xnoremap L g_

" Jump 10 lines down/up.
nnoremap <Leader>j 10j
nnoremap <Leader>k 10k


" ============================================================================
" [10]  NERDTREE
" ============================================================================

" Toggle the file explorer.
nnoremap <silent> <C-F> :NERDTreeToggle<CR>
" Reveal the current file in the tree.
nnoremap <silent> <Leader>nf :NERDTreeFind<CR>
" Re-read the tree from disk (after a build creates files).
nnoremap <silent> <Leader>nr :NERDTreeRefreshRoot<CR>


" ============================================================================
" [11]  TAGBAR & CTAGS
" ============================================================================

" Toggle the code outline sidebar.
nnoremap <silent> <F8> :TagbarToggle<CR>
" Open (or focus) Tagbar and jump into it.
nnoremap <silent> <Leader>tb :TagbarOpen fj<CR>
" Fuzzy-search tags in the project / in the current file.
nnoremap <silent> <Leader>tg :Tags<CR>
nnoremap <silent> <Leader>tf :BTags<CR>


" ============================================================================
" [12]  FZF — FUZZY FINDER
" ============================================================================

" Files in the project (Ctrl+P, like most IDEs).
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <Leader>ff :Files<CR>
" Only files tracked by git (fast in huge trees with build output).
nnoremap <silent> <Leader>fg :GFiles<CR>
" Open buffers.
nnoremap <silent> <Leader>b :Buffers<CR>
nnoremap <silent> <Leader>fb :Buffers<CR>
" Recently opened files.
nnoremap <silent> <Leader>fr :History<CR>
" Lines in the current buffer.
nnoremap <silent> <Leader>fl :BLines<CR>
" Vim help.
nnoremap <silent> <Leader>fh :Helptags<CR>
" Git commits (whole repo / this file).
nnoremap <silent> <Leader>fc :Commits<CR>
nnoremap <silent> <Leader>fC :BCommits<CR>

" Ripgrep across file contents.
nnoremap <Leader>rg :Rg<Space>
" Ripgrep for the word under the cursor.
" Example: cursor on platform_driver_register → <Leader>rw.
nnoremap <silent> <Leader>rw :Rg <C-r><C-w><CR>


" ============================================================================
" [13]  GIT — fugitive + gitgutter
" ============================================================================

" Status window (stage with '-', commit with 'cc', diff with '=').
nnoremap <silent> <Leader>gs :Git<CR>
" Diff the working file against the index, side by side.
nnoremap <silent> <Leader>gd :Gvdiffsplit<CR>
" Blame the current file.
nnoremap <silent> <Leader>gb :Git blame<CR>
" Log of the current file into the quickfix list.
nnoremap <silent> <Leader>gl :0Gclog<CR>
" Stage the whole current file.
nnoremap <silent> <Leader>gw :Gwrite<CR>

" Next / previous changed hunk.
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
" Preview / stage / undo the hunk under the cursor.
nmap <Leader>hp <Plug>(GitGutterPreviewHunk)
nmap <Leader>hs <Plug>(GitGutterStageHunk)
nmap <Leader>hu <Plug>(GitGutterUndoHunk)


" ============================================================================
" [14]  CSCOPE — SYMBOL NAVIGATION
" ============================================================================
"
" WHY CSCOPE MAPPINGS MATTER
" --------------------------
" ctags tells you WHERE a symbol is defined (one result).
" cscope tells you EVERYTHING about a symbol (multiple results):
"   who calls probe()?  where is irq_handler assigned?  who includes gpio.h?
"
" Multi-result queries land in the quickfix list (]q / [q to walk it).
" Rebuild the database with 'mkidx' in the shell, then :CscopeReload.

" Find all references to the symbol.
nnoremap <C-\>s :cs find s <C-r>=expand('<cword>')<CR><CR>:cwindow<CR>
" Find the global definition.
nnoremap <C-\>g :cs find g <C-r>=expand('<cword>')<CR><CR>
nnoremap <C-\>d :cs find g <C-r>=expand('<cword>')<CR><CR>
" Find all callers of the function.
nnoremap <C-\>c :cs find c <C-r>=expand('<cword>')<CR><CR>:cwindow<CR>
" Find functions called BY this function.
nnoremap <C-\>e :cs find d <C-r>=expand('<cword>')<CR><CR>:cwindow<CR>
" Find places where the symbol is assigned a value.
nnoremap <C-\>a :cs find a <C-r>=expand('<cword>')<CR><CR>:cwindow<CR>
" Find a text string.
nnoremap <C-\>t :cs find t <C-r>=expand('<cword>')<CR><CR>:cwindow<CR>
" Find files #including the header under the cursor.
nnoremap <C-\>i :cs find i <C-r>=expand('<cfile>:t')<CR><CR>:cwindow<CR>
" Open the file whose name is under the cursor.
nnoremap <C-\>f :cs find f <C-r>=expand('<cfile>')<CR><CR>

" CSCOPE FIND CODES REFERENCE:
"   s — symbol:   all references          g — global definition
"   d — called:   functions called BY     c — callers of this function
"   t — text:     text string             e — egrep pattern
"   f — file:     open this file          i — files #including this file
"   a — assigns:  places assigning a value


" ============================================================================
" [15]  QUICKFIX & LOCATION LIST
" ============================================================================
" ]x / [x convention: next / previous. Capital = last / first.

nnoremap <silent> ]q :cnext<CR>zz
nnoremap <silent> [q :cprevious<CR>zz
nnoremap <silent> ]Q :clast<CR>
nnoremap <silent> [Q :cfirst<CR>
nnoremap <silent> ]l :lnext<CR>zz
nnoremap <silent> [l :lprevious<CR>zz

" Open / close the quickfix window.
nnoremap <silent> <Leader>co :copen<CR>
nnoremap <silent> <Leader>cq :cclose<CR>


" ============================================================================
" [16]  BUILD & KERNEL TOOLS
" ============================================================================

" Run make without jumping to the first error; open quickfix if anything
" failed. Uses $ARCH / $CROSS_COMPILE from the shell ('xc arm64 ...').
nnoremap <silent> <Leader>m :silent make! <Bar> redraw! <Bar> cwindow<CR>
nnoremap <silent> <F5>      :silent make! <Bar> redraw! <Bar> cwindow<CR>

" :Checkpatch — run the kernel's scripts/checkpatch.pl on the current file
" (searched upward from the file) and load the findings into quickfix.
function! s:Checkpatch() abort
  let l:script = findfile('scripts/checkpatch.pl', expand('%:p:h') . ';')
  if empty(l:script)
    echohl WarningMsg | echo 'scripts/checkpatch.pl not found above this file' | echohl None
    return
  endif
  let l:script = fnamemodify(l:script, ':p')
  let l:out = system('perl ' . shellescape(l:script)
        \ . ' --no-tree --terse --emacs --show-types -f ' . shellescape(expand('%:p')))
  let l:efm = &errorformat
  let &errorformat = '%f:%l: %m'
  cexpr l:out
  let &errorformat = l:efm
  if empty(getqflist())
    echo 'checkpatch: clean'
  else
    copen
  endif
endfunction
command! Checkpatch call s:Checkpatch()
nnoremap <silent> <Leader>cp :Checkpatch<CR>

" Format the buffer with the project's formatter (clang-format for C).
nnoremap <silent> <Leader>F :Autoformat<CR>

" Remove trailing whitespace in the whole buffer (only when you ask).
command! StripTrailing let s:view = winsaveview() | keeppatterns %s/\s\+$//e | call winrestview(s:view)


" ============================================================================
" [17]  NERDCOMMENTER — REFERENCE
" ============================================================================
"
" MAPPINGS (auto-created by NERDCommenter — no nnoremap needed):
"   <Leader>c<Space>  — TOGGLE comment (most useful — use this one)
"   <Leader>cc        — Comment line / selection
"   <Leader>cu        — Uncomment line / selection
"   <Leader>cs        — "Sexy" block comment:  /* … */ with leading *
"   <Leader>ca        — Switch delimiter style (C: /* */ ↔ //)


" ============================================================================
" [18]  CODE FOLDING — REFERENCE
" ============================================================================
"   za  toggle · zo/zc open/close · zO/zC recursive · zM close all · zR open all
"   zj / zk  next / previous fold


" ============================================================================
" [19]  TERMINAL
" ============================================================================

" Open a terminal below (12 rows) / to the right.
nnoremap <silent> <Leader>tt :below terminal ++rows=12<CR>
nnoremap <silent> <Leader>tv :vertical terminal<CR>

" Double Esc leaves terminal-job mode (single Esc still reaches the shell).
tnoremap <Esc><Esc> <C-\><C-n>


" ============================================================================
" [20]  CONFIG FILES
" ============================================================================

" Edit ~/.vimrc / this mapping file; reload the configuration.
nnoremap <silent> <Leader>ev :edit $MYVIMRC<CR>
nnoremap <silent> <Leader>ek :edit ~/.vim/key_mapping.vim<CR>
command! Reload source $MYVIMRC | echo 'vimrc reloaded'


" ============================================================================
" COMPLETE MAPPING REFERENCE — see docs/keymaps.md in the repo
" ============================================================================
