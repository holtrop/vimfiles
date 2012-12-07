set nocompatible

if has("autocmd")
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
endif " has("autocmd")

set ruler
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set copyindent
set cindent
set backspace=indent,eol,start
set mouse=a
syntax on
set hlsearch
set showmatch
set incsearch
set tags=./tags;/
set grepprg=internal
set tabpagemax=999
set nobackup
set nowritebackup
set noswapfile
set wildmode=longest,list,full
set splitright
set showcmd

" GUI settings
set background=dark
set showtabline=1
set nomousehide

if has("gui_running")
    colorscheme ir_black
    runtime ftplugin/man.vim
    nmap K :Man <cword><CR>
"    set lines=50
    set scrolloff=8
"    if &diff
"        set columns=175
"    endif
    set guioptions-=m   " remove menu bar
    set guioptions-=T   " remove toolbar
    set colorcolumn=80
    hi ColorColumn guibg=#220000
else
    set scrolloff=4
endif

if has("win32") || has("win64")
    set directory=$TMP
endif

" mappings
map ,# :set paste<CR>O<Esc>75A#<Esc>yypO#<Esc>73A <Esc>A#<Esc>0ll:set nopaste<CR>R
map ,p :set paste<CR>o#<Esc>73A <Esc>A#<Esc>0ll:set nopaste<CR>R
map ,* :set paste<CR>O/<Esc>74A*<Esc>o <Esc>73A*<Esc>A/<Esc>O * <Esc>:set nopaste<CR>A
map ,; :set paste<CR>O;<Esc>74A*<Esc>o;*<Esc>72A <Esc>A*<Esc>o;<Esc>74A*<Esc>0klll:set nopaste<CR>R
map ,8 :set paste<CR>o<Esc>20A-<Esc>A8<<Esc>20A-<Esc>:set nopaste<CR>0
map ,m mz:%s/<C-Q><CR>//g<CR>:noh<CR>`z
map ,t :tabn<CR>
map ,T :tabp<CR>
map ,s mz:%s/\v\s+$//<CR>`z
map ,f :set ts=8<CR>:retab<CR>:set ts=4<CR>
" jump to tag in a new tab
map ,w :tab :tag <C-R><C-W><CR>
" re-indent the following line how vim would automatically do it
map ,j Ji<CR><Esc>
map <C-N> :cn<CR>
map <C-P> :cp<CR>

if has("autocmd")
  autocmd FileType text setlocal noautoindent
  autocmd FileType c syn match Constant display "\<[A-Z_][A-Z_0-9]*\>"
  autocmd FileType cpp syn match Constant display "\<[A-Z_][A-Z_0-9]*\>"
  autocmd FileType dosbatch syn match Comment "^@rem\($\|\s.*$\)"lc=4 contains=dosbatchTodo,@dosbatchNumber,dosbatchVariable,dosbatchArgument
  autocmd BufRead,BufNewFile *.dxl set filetype=dxl
  autocmd FileType dxl setlocal syntax=cpp
  " install glsl.vim in ~/.vim/syntax to use syntax highlighting for GLSL:
  autocmd BufRead,BufNewFile *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl
  autocmd Syntax {cpp,c,idl} runtime syntax/doxygen.vim
  autocmd QuickFixCmdPre grep copen
  autocmd QuickFixCmdPre vimgrep copen
  autocmd FileType html setlocal sw=2 ts=2 sts=2
  autocmd FileType xhtml setlocal sw=2 ts=2 sts=2
  autocmd FileType xml setlocal sw=2 ts=2 sts=2
  autocmd FileType yaml setlocal sw=2 ts=2 sts=2
endif " has("autocmd")
