" ABB Rapid Command file type detection for Vim
" Language: ABB Rapid Command
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 2.0.0
" Last Change: 13. Dec 2017
" Credits:
"
" Suggestions of improvement are very welcome. Please email me!
"

let s:keepcpo= &cpo
set cpo&vim

if !exists("*<SID>RapidAutoCorrCfgLineEnding()")
  function <SID>RapidAutoCorrCfgLineEnding()
    if exists("g:rapidAutoCorrCfgLineEnd") && g:rapidAutoCorrCfgLineEnd==1
      silent! %s/\r//
      normal ``
    endif
  endfunction
endif

augroup rapidftdetect
  au! BufNewFile *.mod,*.Mod,*.MOD,*.sys,*.Sys,*.SYS,*.prg,*.Prg,*.PRG,*.cfg,*.Cfg,*.CFG setf rapid
  au! BufRead *.mod,*.Mod,*.MOD,*.sys,*.Sys,*.SYS,*.prg,*.Prg,*.PRG if getline(nextnonblank(1)) =~ '\v\c^\s*(\%\%\%|module\s)' | set filetype=rapid | endif
  au! BufRead *.cfg,*.Cfg,*.CFG if getline(1) =~ '^\w\+:CFG' | set filetype=rapid | endif
augroup END

" correct line endings. in ftdetect because it gets loaded befor a file is loaded
augroup rapidcorrcfg
  au! BufRead *.cfg,*.Cfg,*.CFG if getline(1) =~ '^\w\+:CFG' | call <SID>RapidAutoCorrCfgLineEnding() | endif
augroup END

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
