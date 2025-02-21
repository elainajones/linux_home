"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable
" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
" Do not visually wrap lines (easier for split pane work)
set nowrap
set nocompatible
" Fix for starting in replace mode.
set t_u7=
" Use at least 256 colors.
set t_co=256
set number
set cursorline
set ruler
" Always display the status line
set laststatus=2
" Automatically show matching brackets. works like it does in bbedit.
set showmatch
" Better command line completion
set wildmode=list:longest,longest:full
" :W sudo saves the file
" Useful for handling the permission-denied error
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
" Ignore case when searching
set ignorecase
" Linebreak on 80 characters
set linebreak
set textwidth=80
set autoindent
set hlsearch
" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load plugins first so vimrc configs can override for changes
" Gruvbox (colorscheme) config {{{
" I honestly forgot what these are for
set background=dark
set notermguicolors
let g:gruvbox_transparent_bg=1
let g:gruvbox_bold=1
let g:gruvbox_italic=1
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
highlight GitGutterAdd ctermbg=NONE guibg=NONE "ctermfg=2
highlight GitGutterChange ctermbg=NONE guibg=NONE "ctermfg=3
highlight GitGutterDelete ctermbg=NONE guibg=NONE "ctermfg=1
highlight GitGutterChangeDelete ctermbg=NONE guibg=NONE "ctermfg=4
" }}}
" Ale {{{
let g:ale_linters = {'python': ['pycodestyle'], 'bash': ['cspell']}
highlight ALEVirtualTextError ctermbg=none ctermfg=red
highlight ALEVirtualTextWarning ctermbg=none ctermfg=yellow
highlight ALEErrorSign ctermbg=none ctermfg=red
highlight ALEWarningSign ctermbg=none ctermfg=yellow
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
" Use ctr + h, j, k, l to move between windows
map <C-h> <C-W>h
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-l> <C-W>l
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set Proper Tabs
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
" Fix for Makefile tabs since it can be picky
autocmd FileType make setlocal noexpandtab

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Line number highlighting
highlight LineNr ctermbg=NONE guibg=NONE "ctermfg=darkgrey guifg=darkgrey
highlight Normal guibg=NONE ctermbg=NONE
" Cursor highlight
highlight CursorLinenr ctermbg=NONE cterm=bold guibg=NONE gui=bold
highlight CursorLine ctermbg=NONE guibg=NONE
" Highlight columns over 80 chars
highlight ColorColumn ctermbg=red guibg=red
call matchadd('ColorColumn', '\%81v', 100)
" Highlight trailing whitespace (for code linting)
highlight TrailingWhitespace ctermbg=magenta guibg=pink
call matchadd('TrailingWhitespace', '\s\+$', 100)
" Highlight commas with missing whitespace (for code linting)
highlight CommaWhiteSpace ctermbg=magenta guibg=pink
" Verical split
set fillchars+=vert:\ 
highlight VertSplit ctermfg=darkgrey ctermbg=NONE guifg=darkgrey guibg=NONE
" Spell check highlighting
highlight clear SpellBad
highlight SpellBad cterm=underline gui=underline
" Highlight search results
" Use marker as fold method (see Functions section)
set foldtext=MyFoldText()
set foldmethod=marker
highlight Folded ctermbg=NONE guibg=NONE
augroup commit_highlight
    autocmd!
    highlight ConventionalCommits ctermbg=magenta
    autocmd FileType gitcommit call matchadd('ConventionalCommits', '\%^\(\(fix\|feat\|build\|chore\|ci\|docs\|style\|refactor\|perf\|test\)\>\)\@!.*:', 100)
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Spell check
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" - Pressing z= with the cursor over a word in normal mode will open word
"   selection
" - Pressing zg with the cursor over a word in normal mode will add it to the
"   dictionary
" - Pressing zw with the cursor over a word in normal mode will mark it as
"   incorrect
set spell spelllang=en_us
"" Set spelling for markdown files
"autocmd FileType markdown setlocal spell spelllang=en_us
"" Set spelling for git commits
"autocmd FileType gitcommit setlocal spell spelllang=en_us
"" Set spelling for text files
"autocmd FileType text setlocal spell spelllang=en_us
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
" Delete trailing white space on save, useful for some filetypes ;)
function! CleanExtraSpaces()
let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
augroup clean_spaces
    autocmd!
    autocmd BufWritePre *.py,*.sh,*.robot,*.md,*.txt :call CleanExtraSpaces()
augroup END
