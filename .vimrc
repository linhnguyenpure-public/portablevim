call plug#begin()
Plug 'tpope/vim-sensible' "Some standard vim config
Plug 'tpope/vim-fugitive' "Git wrapper in vim
Plug 'flazz/vim-colorschemes'
"These 2 are used for keeping cursor at same position while using * search
Plug 'vim-scripts/ingo-library' "Autoload functions for vim
Plug 'vim-scripts/SearchHighlighting' "Changes star command to not jump to next match
Plug 'vim-scripts/highlight.vim' "To highlight line
Plug 'vim-scripts/IndexedSearch' "To print at match N out of M matches
Plug 'vim-scripts/grep.vim' "To grep phrase in all source files
Plug 'vim-scripts/taglist.vim' "TlistToggle
Plug 'vim-scripts/genutils' "Required for tagselect
Plug 'lnguyen639/tagselect' "To search in vim ctags, use g] instead of Ctrl]
Plug 'rodjek/vim-puppet' "Plug in for puppet coding
Plug 'ctrlpvim/ctrlp.vim' "Plug in for indexing all files in current repo
Plug 'w0rp/ale' "Linting for vim
"https://unix.stackexchange.com/questions/7695/how-to-make-vim-display-colors-as-indicated-by-color-codes
Plug 'powerman/vim-plugin-AnsiEsc' "Conceals ANSI escape sequences but color it
"Plug 'darfink/vim-plist' "plist in OSX

"Plug to auto index with ctags - disable due to slow startup time
"Plug 'ludovicchabant/vim-gutentags'
    "let g:gutentags_cache_dir = expand('~/.cache/ctags')
    "let g:gutentags_add_default_project_roots = 0
    "let g:gutentags_project_root = ['.git', '.hg', '.svn', 'Makefile']
set hlsearch

"Auto complete"
"Plug 'Valloric/YouCompleteMe'
set encoding=utf-8 "YouCompleteMe unavailable: requires UTF-8 encoding. Put the line 'set encoding=utf-8' in your vimrc.

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

"Linhtmp: disable because it's hanging at opening 1 C file
" Autocomplete with LSP
"Plug 'https://github.com/prabirshrestha/vim-lsp'
"Plug 'https://github.com/mattn/vim-lsp-settings'
"Plug 'https://github.com/prabirshrestha/asyncomplete.vim'
"Plug 'https://github.com/prabirshrestha/asyncomplete-lsp.vim'
" EndLinhtmp
call plug#end()

" Set cscope shortcuts for vim
" http://cscope.sourceforge.net/cscope_vim_tutorial.html
" source ~/.vim/cscope_maps.vim

" Source proprietary vimscripts
" source ~/.proprietary.vim

" Show existing tab with 4 spaces width
set tabstop=4
" When indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab
filetype plugin indent on

"Show line number
set number
"Show file path
set laststatus=2

"tags-option
set tags=./tags,tags,~/tags

syntax on
nmap ; :
"https://superuser.com/questions/549930/cant-resize-vim-splits-inside-tmux
"set these 2 options to drag vimsplit within tmux
set mouse+=a
" tmux knows the extended mouse mode
set ttymouse=xterm2
nmap <C-h> <C-W><C-h>
nmap <C-l> <C-W><C-l>
nmap <C-]> g<C-]>
vnoremap // y/<C-R>"<CR>
" map Ctrl \ to open in new tab, Alt ] to open in vs 
"map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR> 
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
" redirect output of g search command to new window with F3
" https://vim.fandom.com/wiki/Redirect_g_search_output
nnoremap <silent> <F3> :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR>
"https://stackoverflow.com/questions/30691466/what-is-difference-between-vims-clipboard-unnamed-and-unnamedplus-settings
set clipboard^=unnamedplus,unnamed



" case insensitive tag matching
" go to defn of tag under the cursor
fun! MatchCaseTag()
    let ic = &ic
    set noic
    try
        exe 'tjump ' . expand('<cword>')
    finally
        let &ic = ic
    endtry
endfun
nnoremap <silent> <c-]> :call MatchCaseTag()<CR>

"Type Ctrl+m to index python site-packages folder
nmap <C-m> :CtrlP /usr/local/lib/python2.7/site-packages/<CR>
"Ctrl + P then t gets to fuzzy search for tags content
nnoremap <C-p>t :CtrlPTag<cr>

"For vim-plist
"let g:plist_display_format = 'xml'
"let g:plist_save_format = ''

"Nerdtree on the right
let g:NERDTreeWinSize=40
let g:NERDTreeWinPos = "right"
let g:Tlist_Show_One_File = 1
nmap <F6> :NERDTreeToggle<CR> <C-W> R
nmap <F5> :TlistToggle<CR>
"Highlight current line
"Copy gf <cfile> to clipboard: Yes, I did it myself + https://vi.stackexchange.com/questions/9627/how-can-i-get-vim-to-include-suffixes-in-cfile
nmap yf :call setreg("*", expand("<cfile>"))<CR>

" For cygwin: Do \cp to copy file path to system clipboard
" replace with C:\Users\ - Ref: chatgpt
nnoremap <leader>cp :let @+ = substitute(substitute(expand('%:p'), '^/cygdrive/\([a-z]\)', '\U\1:', ''), '/', '\', 'g')<CR>

"https://stackoverflow.com/questions/1152362/how-to-send-data-to-local-clipboard-from-a-remote-ssh-session   -- comment in top answer
"https://stackoverflow.com/questions/12414745/send-echo-or-register-contents-to-pbcopy-mac-clipboard-on-mac-os-x
"Copy current selection to remote clipboard
nmap yr :call system("ssh `cat $REMOTE_NAME` pbcopy", @*)<CR>

"Short cut to open new tabs: https://stackoverflow.com/questions/6638290/how-to-make-shortcut-for-tabnew-tabn-tabp
inoremap <C-t> <Esc>:tabnew<Space>

"Change colorscheme while doing vimdiff https://stackoverflow.com/questions/2019281/load-different-colorscheme-when-using-vimdiff
if &diff
    colorscheme desert
endif

fun! MatchAddHighlight()
    "Set rules to highlight pass/fail/running/killed
    hi passed ctermfg=blue
    call matchadd('passed', 'Passed')
    hi killed ctermfg=red
    call matchadd('killed', 'Killed')
    call matchadd('killed', 'fail')
    call matchadd('killed', 'error')
    call matchadd('killed', 'FAIL')
    call matchadd('killed', 'ERROR')
    call matchadd('killed', 'Fail')
    call matchadd('killed', 'Error')
    call matchadd('killed', 'Detached')
    hi running ctermfg=yellow
    call matchadd('running', 'Running')
endfun

"Apply highlighting to all windows
"https://vi.stackexchange.com/questions/8027/automatically-call-matchadd-in-every-new-window-without-producing-duplicate-en
"autocmd BufWinEnter * let w:matchId = MatchAddHighlight() "works too
autocmd WinEnter * if !exists('w:matchId') | let w:matchId = MatchAddHighlight() | endif
"autocmd BufWinLeave * call matchdelete(w:matchId) "this gives error: e802: invalid id: 0 must be greater than or equal to 1

"Zooming https://medium.com/@vinodkri/zooming-vim-window-splits-like-a-pro-d7a9317d40
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=
