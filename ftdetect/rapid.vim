" ABB Rapid Command file type detection for Vim
" Language: ABB Rapid Command
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 2.0.0
" Last Change: 17. Sep 2020
" Credits:
"
" Suggestions of improvement are very welcome. Please email me!
"

let s:keepcpo= &cpo
set cpo&vim

au! filetypedetect BufNewFile,BufRead *.mod,*.Mod,*.MOD,*.prg,*.Prg,*.PRG setf rapid
" change default autocmd for .sys 
au! filetypedetect BufNewFile,BufRead *.sys,*.Sys,*.SYS if getline(nextnonblank(1)) =~ '\v\c^\s*(\%\%\%|module\s)' | setf rapid | else | setf dosbatch | endif
" change default autocmd for cfg
au! filetypedetect BufNewFile,BufRead *.cfg,*.Cfg,*.CFG if getline(1) =~ '^\w\+:CFG' | setf rapid | endif

" correct line endings. in ftdetect because it gets loaded befor a file
" is loaded
augroup rapidftdetect
  au! filetypedetect BufRead *.cfg,*.Cfg,*.CFG if getline(1) =~ '^\w\+:CFG' | call <SID>RapidAutoCorrCfgLineEnding() | endif
augroup END
if !exists("*<SID>RapidAutoCorrCfgLineEnding()")
  function <SID>RapidAutoCorrCfgLineEnding() abort
    setf rapid
    if get(g:,'rapidAutoCorrCfgLineEnd',1)
      silent! %s/\r//
      normal ``
    endif
  endfunction
endif

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
