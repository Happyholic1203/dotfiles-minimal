let mapleader=","

colorscheme vividchalk
set background=dark
set number
set relativenumber
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent
set backspace=2
syntax on

" shortcuts
nnoremap <leader>q :q<CR>
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-h> <c-w>h
map <c-l> <c-w>l
map <leader>h: tabprevious<CR>
map <leader>l: tabnext<CR>

" fzf
if executable('fzf')
    set runtimepath+=~/.fzf
    map <leader>f :FZF<CR>
    if executable('rg')
        nmap <leader>s <Esc>:Rg<Cr>
        nnoremap \ :Rg <C-R><C-W><CR>
    endif
    execute pathogen#infect()
endif