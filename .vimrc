" normal useful stuff
set number
syntax on
set hlsearch
set wildmenu
set ignorecase
set smartcase
set autoindent
set confirm


" Tabs -> Spaces
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab


" Auto cursor
augroup resCur
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END

" Theme
color desert


" Control+Backspace to delete words
imap <C-BS> <C-W>
