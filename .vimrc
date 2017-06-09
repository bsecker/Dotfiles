" ----------------------
" normal useful stuff
" ----------------------

"enable filetype plugins
filetype plugin on
filetype indent on



" line numbers
set number 

" Syntax highlighting
syntax on

" highlist search results
set hlsearch

" turn on Wild menu
set wildmenu

" ignore case when searching
set ignorecase

" be smart about cases
set smartcase

" auto indent lines
set autoindent

" confirm when exiting
set confirm


" Tabs -> Spaces
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab


" Auto cursor on reopen file
augroup resCur
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END

" Theme
color desert


" Control+Backspace to delete words
imap <C-BS> <C-W>
