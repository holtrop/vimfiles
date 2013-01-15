"==============================================================================
" General Settings
"==============================================================================
let $MYVIMFILES=fnamemodify(resolve(expand("<sfile>")), ":p:h")
set nocompatible
syntax enable
filetype plugin indent on
set backspace=indent,eol,start
set autoindent
set copyindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4
set ruler
set showmatch
"if has("persistent_undo")
"    set undodir=$MYVIMFILES/undo
"    set undofile
"endif
set mouse=a
set hlsearch
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
set background=dark
set showtabline=1

runtime ftplugin/man.vim
nnoremap K :Man <cword><CR>

if has("gui_running")
    " GUI-specific settings
    colorscheme ir_black
    set scrolloff=8
    set guioptions-=m   " remove menu bar
    set guioptions-=T   " remove toolbar
    set colorcolumn=80
    set nomousehide
    hi ColorColumn guibg=#220000
else
    " console-specific settings
    set scrolloff=4
endif

if has("win32") || has("win64")
    set directory=$TMP
    if filereadable('C:/cygwin/bin/bash.exe')
        set shell=C:/cygwin/bin/bash.exe
        set shellcmdflag=--login\ -c
    endif
endif

" mappings
let mapleader = ','
nnoremap <Leader>C# :set paste<CR>O<Esc>75A#<Esc>yypO# <Esc>:set nopaste<CR>A
nnoremap <Leader>c# :set paste<CR>o<Esc>75A#<Esc>yypO# <Esc>:set nopaste<CR>A
nnoremap <Leader>C* :set paste<CR>O/<Esc>74A*<Esc>o <Esc>73A*<Esc>A/<Esc>O * <Esc>:set nopaste<CR>A
nnoremap <Leader>c* :set paste<CR>o/<Esc>74A*<Esc>o <Esc>73A*<Esc>A/<Esc>O * <Esc>:set nopaste<CR>A
nnoremap <Leader>c; :set paste<CR>O;<Esc>74A*<Esc>o;*<Esc>72A <Esc>A*<Esc>o;<Esc>74A*<Esc>0klll:set nopaste<CR>R
nnoremap <Leader>c8 :set paste<CR>o<Esc>20A-<Esc>A8<<Esc>20A-<Esc>:set nopaste<CR>0
nnoremap <Leader>m m`:%s/<C-Q><CR>//g<CR>:noh<CR>``
nnoremap <Leader>t :tabn<CR>
nnoremap <Leader>T :tabp<CR>
nnoremap <Leader>s m`:%s/\v\s+$//<CR>``
" jump to tag in a new tab
nnoremap <Leader>w :tab :tag <C-R><C-W><CR>
" re-indent the following line how vim would automatically do it
nnoremap <Leader>j Ji<CR><Esc>
nnoremap <C-N> :cnext<CR>
nnoremap <C-P> :cprev<CR>

vnoremap <C-J> <Esc>
vnoremap < <gv
vnoremap > >gv

inoremap <silent> <C-Space> <C-o>:call PtagSymbolBeforeParen()<CR>
inoremap <silent> <C-S-Space> <C-o>:pclose<CR>

if has("autocmd")
    autocmd FileType text setlocal noautoindent
    autocmd FileType c syn match Constant display "\<[A-Z_][A-Z_0-9]*\>"
    autocmd FileType cpp syn match Constant display "\<[A-Z_][A-Z_0-9]*\>"
    autocmd FileType dosbatch syn match Comment "^@rem\($\|\s.*$\)"lc=4 contains=dosbatchTodo,@dosbatchNumber,dosbatchVariable,dosbatchArgument
    autocmd BufRead,BufNewFile *.dxl set syntax=cpp
    " install glsl.vim in ~/.vim/syntax to use syntax highlighting for GLSL:
    autocmd BufRead,BufNewFile *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl
    autocmd Syntax {cpp,c,idl} runtime syntax/doxygen.vim
    autocmd QuickFixCmdPre grep copen
    autocmd QuickFixCmdPre vimgrep copen
    autocmd FileType html setlocal sw=2 ts=2 sts=2
    autocmd FileType xhtml setlocal sw=2 ts=2 sts=2
    autocmd FileType xml setlocal sw=2 ts=2 sts=2
    autocmd FileType yaml setlocal sw=2 ts=2 sts=2
    autocmd FileType text setlocal textwidth=78
    autocmd BufRead,BufNewFile *.icf set syntax=cpp

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event handler
    " (happens when dropping a file on gvim).
    autocmd BufReadPost *
                \ if line("'\"") > 0 && line("'\"") <= line("$") |
                \   exe "normal! g`\"" |
                \ endif

    autocmd BufWinEnter * call LoadProject()
    autocmd BufEnter * call ProjectCD()
endif " has("autocmd")

"==============================================================================
" Functions
"==============================================================================

" LoadProject - Searches for and loads project specific settings
function! LoadProject()
    if exists("b:project_loaded") && b:project_loaded == 1
        return
    endif
    let projfile = findfile("project.vim", ".;")
    if projfile != ""
        let b:project_directory = fnamemodify(projfile, ":p:h")
        exec "source " . fnameescape(projfile)
        let b:project_loaded = 1
    else
        let projdir = finddir("project.vim", ".;")
        if projdir != ""
            let b:project_directory = fnamemodify(projdir, ":p:h:h")
            for f in split(glob(projdir . '/*.vim'), '\n')
                exec 'source ' . fnameescape(f)
            endfor
            let b:project_loaded = 1
        endif
    endif
endfunction

" ProjectCD - Change to the project directory
" for some reason doing this in LoadProject() didn't work on Windows
function! ProjectCD()
    if exists("b:project_directory")
        exec "cd " . fnameescape(b:project_directory)
    endif
endfunction

function! FindSymbolInSources(sources, ...)
    if a:0 > 0
        let sym = a:1
    else
        let sym = expand("<cword>")
    endif
    exec 'vimgrep /\<' . sym . '\>/gj ' . a:sources
    let n_matches = len(getqflist())
    if n_matches == 0
        cclose
    else
        redraw " the following echo will be lost without redrawing here
        echo "Found " . n_matches . " matches"
    endif
endfunction

" PtagSymbolBeforeParen - can be called from insert mode when the cursor
" is anywhere within the parentheses of a function call in order to open
" the called-function's prototype in the Preview window using :ptag
function! PtagSymbolBeforeParen()
    let l:line = getline(".")
    let l:paren_pos = strridx(l:line, "(", col("."))
    if l:paren_pos != -1
        let l:line = strpart(l:line, 0, l:paren_pos)
    endif
    let l:symidx = match(l:line, '\v[a-zA-Z_][a-zA-Z_0-9]*$')
    if l:symidx != -1
        let l:line = strpart(l:line, l:symidx)
    endif
    if &syntax == 'vim'
        execute 'silent! help ' . l:line
        if &filetype == 'help'
            " we successfully opened the help window
            execute "normal 1000\<C-w>-"
            setlocal winheight=10
            execute "normal \<C-w>\<C-w>"
            startinsert
        endif
    else
        execute 'silent! ptag ' . l:line
    endif
endfunction

"==============================================================================
" Machine-local Settings
"==============================================================================
if filereadable($MYVIMRC . ".local")
    exec 'source ' . $MYVIMRC . ".local"
endif
