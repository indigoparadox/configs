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
command -nargs=1 RFvdp :!cd retrovdp/<args> && make clean && make && cp rvdp*.{so,dll} ../.. && cd ../..
command -nargs=1 MCM :!make clean && make <args>
command GPmaug :!cd maug && git pull && cd ..
command GP :!git pull
command -nargs=1 GCD :!git commit -a --date <args>
command GC :!git commit -a
command GS :!git push
command -nargs=1 GCr :!cd <args> && git commit -a && cd ..
command -nargs=1 GSr :!cd <args> && !git push && cd ..
command Sp :setlocal spell spelllang=en_us
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
function! BufferList()
   execute "silent redir @m"
   execute "silent buffers"
   execute "silent redir END"
   let a=@m
   return a
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
