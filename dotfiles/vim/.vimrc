
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2017 Sep 20
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'preservim/nerdtree'
Plugin 'mattn/emmet-vim'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'sheerun/vim-polyglot'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'rafi/awesome-vim-colorschemes'
Plugin 'alvan/vim-closetag'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'morhetz/gruvbox'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" Non-plugin stuff is below this line
" ==================================
"            THEMES
" ==================================
set background=dark " Change this when you want to change the mode of the colorscheme
set t_Co=256 " Enables the 256 colors in vim
colorscheme gruvbox " Sets your default colorscheme
""let g:airline_theme='angr' " Adds custom airline-vim theme, by default it is
"                              the theme from the colorscheme
"===================================
"	GENERAL SETTINGS 
"===================================
set clipboard=unnamedplus
set nocompatible
filetype plugin on
syntax enable
set path+=**
set wildmenu
command! MakeTags !ctags -R
"================================
"       ALACRITTY
"================================
" Enabling the mouse intergration with Alacritty
set ttymouse=sgr
"=============================
"	POWERLINE
"============================
let g:powerline_pycmd="py3"
:set laststatus=2
"=========================
"       CLOSING TAGS
"=========================
" filenames like *.xml, *.html, *.xhtml, ...
" These are the file extensions where this plugin is enabled.
"
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'

" filetypes like xml, html, xhtml, ...
" These are the file types where this plugin is enabled.
"
let g:closetag_filetypes = 'html,xhtml,phtml'

" filetypes like xml, xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filetypes = 'xhtml,jsx'

" integer value [0|1]
" This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" dict
" Disables auto-close if not in a "valid" region (based on filetype)
"
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }

" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is ''
"
let g:closetag_close_shortcut = '<leader>>'
"=================================
"	DEFAULTS
"================================
" Auto-closing parenthesis
inoremap (  ()<Left>
inoremap [  []<Left>
inoremap {  {}<Left>
inoremap "  ""<Left>
" Configuring the behaviour of TAB
set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab
" Setting the 256 colors for vim up 
if &term == "screen"
	  set t_Co=256
endif

" Toggling relative line numbers
set relativenumber
set rnu
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif
