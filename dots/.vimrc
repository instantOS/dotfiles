" paperbenni default vimrc

set number
set ruler
set autoread
set cursorline
filetype plugin on
set expandtab
set hlsearch
set ignorecase
set incsearch
set smartcase
set lazyredraw
set wildmenu

set noerrorbells

syntax on

if v:version >= 900
	colorscheme habamax
else
	colorscheme desert
endif



" Disable vi compatibility, if for some reason it's on.
if &compatible
  set nocompatible
endif

" Delete comment character when joining commented lines.
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j
endif

