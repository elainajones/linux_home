set nocompatible

" Load plugins first so vimrc configs take precedent.
" Gruvbox (colorscheme) config {{{
syntax on
set background=dark

let g:gruvbox_transparent_bg = '1'
let g:gruvbox_bold = '1'
let g:gruvbox_italic = '1'

colorscheme gruvbox

nnoremap <silent> [oh :call gruvbox#hls_show()<CR>
nnoremap <silent> ]oh :call gruvbox#hls_hide()<CR>
nnoremap <silent> coh :call gruvbox#hls_toggle()<CR>

nnoremap * :let @/ = ""<CR>:call gruvbox#hls_show()<CR>*
nnoremap / :let @/ = ""<CR>:call gruvbox#hls_show()<CR>/
nnoremap ? :let @/ = ""<CR>:call gruvbox#hls_show()<CR>?
" }}}
" NERDTree config {{{
let NERDTreeQuitOnOpen = 1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

silent! nmap <C-p> :NERDTreeToggle<CR>
silent! map <F3> :NERDTreeFind<CR>

let g:NERTreeMapActivateNode="<F3>"
let g:NERDTreeMapPreview="<F4>"

nmap xecute "NERDTree"
" }}}
" GitGutter Colors {{{
let g:gitgutter_override_sign_column_highlight = 0
highlight clear SignColumn
highlight GitGutterAdd ctermfg=2 ctermbg=none
highlight GitGutterChange ctermfg=3 ctermbg=none
highlight GitGutterDelete ctermfg=1 ctermbg=none
highlight GitGutterChangeDelete ctermfg=4 ctermbg=none
" }}}

"" Lightline-like configs:
"" Show the current mode
"set showmode
"" Show EOL type and last modified timestamp, right after the filename
"" Set the statusline...
"" ...filename relative to current $PWD
"set statusline=%f               
"" ...help file flag
"set statusline+=%h              
"" ...modified flag
"set statusline+=%m              
"" ...readonly flag
"set statusline+=%r              
"" ...fileformat [unix]/[dos] etc...
"set statusline+=\ [%{&ff}]      
"" ...last modified timestamp
"set statusline+=\ (%{strftime(\"%H:%M\ %d/%m/%Y\",getftime(expand(\"%:p\")))})  
"" ...Rest: right align
"set statusline+=%=              
"" ...position in buffer: linenumber, column, virtual column
"set statusline+=%l,%c%V         
"" ...position in buffer: Percentage
"set statusline+=\ %P            

" Fix for starting in replace mode.
set t_u7=
" Use at least 256 colors.
set t_co=256
" Do not visually wrap lines (easier for split pane work)
set nowrap

" Disable arrow key navigation.
noremap <Up> <Nop>
inoremap <Up> <Nop>
vnoremap <Up> <Nop>
noremap <Down> <Nop>
inoremap <Down> <Nop>
vnoremap <Down> <Nop>
noremap <Left> <Nop>
inoremap <Left> <Nop>
vnoremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Right> <Nop>
vnoremap <Right> <Nop>

" Disable accidental termination (ctrl + z, fn + w)
noremap <C-z> <Nop>
noremap <f> <Nop>
" Disable f1 key for help because I bump it too often.
noremap <f1> <Nop>
inoremap <f1> <Nop>

" Set Proper Tabs
set tabstop=4
set shiftwidth=4
set smarttab
set autoindent
set expandtab
" Fix for Makefile tabs
autocmd FileType make setlocal noexpandtab

" Always display the status line
set laststatus=2
" Automatically show matching brackets. works like it does in bbedit.
set showmatch                   
" Better command line completion
set wildmode=list:longest,longest:full

" Line numbers
set number
set ruler
highlight LineNr ctermfg=darkgrey

" Highlight config
highlight Normal guibg=NONE ctermbg=NONE

" Cursor
set cursorline
highlight CursorLineNR ctermbg=None cterm=bold
highlight CursorLine ctermbg=None
" Remap up and down movement for wrapped lines so eveything lines up.
" This is safe since the behavior is the same 
" for non-wrapped lines.
vnoremap j gj
noremap j gj
vnoremap k gk
noremap k gk


" Verical split
set fillchars+=vert:\ 
highlight VertSplit ctermfg=None ctermbg=None

" Set spelling for text and markdown files
" - Pressing z= with the cursor over a word in normal mode will open word 
"   selection
" - Pressing zg with the cursor over a word in normal mode will add it to the
"   dictionary
" - Pressing zw with the cursor over a word in normal mode will mark it as 
"   incorrect
hi clear SpellBad
hi SpellBad cterm=underline
autocmd FileType markdown setlocal spell spelllang=en_us
autocmd FileType text setlocal spell spelllang=en_us

" Use marker as fold method
set foldtext=MyFoldText()
set foldmethod=marker
highlight Folded ctermbg=NONE

" Functions
function! MyFoldText()
    let line = getline(v:foldstart)
    let folded_line_num = v:foldend - v:foldstart
    let line_text = substitute(line, '^"{\+', '', 'g')
    let fillcharcount = &textwidth - len(line_text) - len(folded_line_num)
    return '+'. repeat('-', 4) . line_text . repeat('.', fillcharcount) . ' (' . folded_line_num . ' L)'
endfunction

