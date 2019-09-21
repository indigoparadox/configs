set nocompatible 
" 
" General Options 
" 
set nobackup 
set complete-=i 
" 
" Formatting Options 
" 
set autoindent 
set smarttab 
set shiftwidth=3 
set softtabstop=3 
set shiftround 
set tabstop=3 
set expandtab 
set ruler 
set modeline 
set enc=utf-8 
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
" 
" Display Options 
" 
if !exists("syntax_on") 
   syntax on
endif
"
if has("gui_running")
   " If we're using gvim, set the theme to white on black and resize the
   " window to something comfortable.
   highlight Normal guibg=Black guifg=White
   set bg=dark
   set co=80
   set lines=25
   " Set the window font to something legible that supports East-Asian 
   " characters depending on the platform.
   if has("win32") || has("win64")
      "set guifont=Fixedsys:h9:cANSI
      set guifont=MS\ Gothic:h12
   else
      set gfn=DejaVu\ Sans\ Mono\ 14
   endif
endif
"
" Color Tweaks
"
hi Comment ctermfg=Blue  gui=bold guifg=Blue
"
" User Functions
"
function! Compile()
   " TODO
   " Figure out what kind of source code file the current file is and call the
   " appropriate compiler.
endfunction
"
" Key Mappings
"
map <F5> <Esc>:call Compile()<CR>
"
" Working Directory - Hide Swap Files!
"
if has("win32") || has("win64")
   set directory=$TMP
else
   set directory=$HOME/.cache/vimtmp
   set viminfo='1000,n$HOME/.cache/viminfo
end
