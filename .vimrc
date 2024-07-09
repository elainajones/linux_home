"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load plugins first so vimrc configs can override for changes
" Gruvbox (colorscheme) config {{{
" I honestly forgot what these are for
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
let NERDTreeQuitOnOpen = 0
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keymapping
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
" Remap up and down movement for wrapped lines so eveything lines up.
" This is safe since the behavior is the same for non-wrapped lines.
vnoremap j gj
noremap j gj
vnoremap k gk
noremap k gk

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set Proper Tabs
set tabstop=4
set shiftwidth=4
set smarttab
set autoindent
set expandtab
" Fix for Makefile tabs since it can be picky
autocmd FileType make setlocal noexpandtab

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Defaults
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Do not visually wrap lines (easier for split pane work)
set wrap
set nocompatible
" Fix for starting in replace mode.
set t_u7=
" Use at least 256 colors.
set t_co=256
set number
set ruler
" Always display the status line
set laststatus=2
" Automatically show matching brackets. works like it does in bbedit.
set showmatch
" Better command line completion
set wildmode=list:longest,longest:full
" Use marker as fold method (see Functions section)
set foldtext=MyFoldText()
set foldmethod=marker
highlight Folded ctermbg=NONE

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Line number highlighting
highlight LineNr ctermfg=darkgrey
highlight Normal guibg=NONE ctermbg=NONE
" Cursor highlight
set cursorline
highlight CursorLineNR ctermbg=None cterm=bold
highlight CursorLine ctermbg=None
" Highlight columns over 80 chars
highlight ColorColumn ctermbg=red
call matchadd('ColorColumn', '\%81v', 100)
" Highlight trailing whitespace (for code linting)
highlight TrailingWhitespace ctermbg=magenta
call matchadd('TrailingWhitespace', '\s\+$', 100)
" Highlight commas with missing whitespace (for code linting)
highlight CommaWhiteSpace ctermbg=magenta
call matchadd('CommaWhiteSpace', ',\w', 100)
" Verical split
set fillchars+=vert:\
highlight VertSplit ctermfg=None ctermbg=None
" Spell check highlighting
highlight clear SpellBad
highlight SpellBad cterm=underline

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spell check
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" - Pressing z= with the cursor over a word in normal mode will open word
"   selection
" - Pressing zg with the cursor over a word in normal mode will add it to the
"   dictionary
" - Pressing zw with the cursor over a word in normal mode will mark it as
"   incorrect
" Set spelling for markdown files
autocmd FileType markdown setlocal spell spelllang=en_us
" Set spelling for git commits
autocmd FileType gitcommit setlocal spell spelllang=en_us
" Set spelling for text files
autocmd FileType text setlocal spell spelllang=en_us

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" I stole this from somewhere. It's magic. No clue how it works.
" TODO: Need to add credit
function! MyFoldText()
    let line = getline(v:foldstart)
    let folded_line_num = v:foldend - v:foldstart
    let line_text = substitute(line, '^"{\+', '', 'g')
    let fillcharcount = &textwidth - len(line_text) - len(folded_line_num)
    return '+'. repeat('-', 4) . line_text . repeat('.', fillcharcount) . ' (' . folded_line_num . ' L)'
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Unused (for reference)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Lightline-like configs: {{{
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
"}}}
