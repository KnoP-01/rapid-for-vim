" ABB Rapid Command file type detection for Vim
" Language: ABB Rapid Command
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeffrobotics.de>
" Version: 2.0.7
" Last Change: 16. Mar 2022
" Credits:
"
" Suggestions of improvement are very welcome. Please email me!
"

let s:keepcpo= &cpo
set cpo&vim

" change default autocmd
augroup filetypedetect
  au! BufNewFile *.prg\c
        \  if exists("g:filetype_prg")
        \|   exe "setf " . g:filetype_prg
        \| else
        \|   setf rapid
        \| endif
  au! BufRead *.prg\c
        \  if s:ftIsRapid()
        \|   setf rapid
        \| elseif exists("g:filetype_prg")
        \|   exe "setf " . g:filetype_prg
        \| else
        \|   setf clipper
        \| endif
  au! BufNewFile *.mod\c
        \  if exists("g:filetype_mod")
	\|   exe "setf " . g:filetype_mod
        \| else
        \|   setf rapid
        \| endif
  au! BufRead *.mod\c
        \  if exists("*dist#ft#FTmod()")
        \|   call dist#ft#FTmod()
        \| elseif s:ftIsRapid()
        \|   setf rapid
        \| elseif getline(nextnonblank(1)) =~# '\<MODULE\s\+\w\+;'
        \|   setf modsim3
        \| elseif getline(s:nextLPrologCodeLine(1)) =~# '<module\s\+\w\+\.'
        \|   setf lprolog
        \| elseif expand("<afile>") =~ '\<go.mod$'
        \|   setf gomod
        \| endif
  au! BufNewFile *.sys\c
        \  setf rapid 
  au! BufRead *.sys\c
        \  if s:ftIsRapid()
        \|   setf rapid 
        \| else 
        \|   setf dosbatch 
        \| endif
  au! BufNewFile *.cfg\c
        \  setf rapid
  au! BufRead *.cfg\c
        \  if getline(1) =~? '\c\v^(EIO|MMC|MOC|PROC|SIO|SYS):CFG'
        \|   call <SID>RapidSetFandCorrEOL() 
        \| else 
        \|   setf cfg 
        \| endif
augroup END

if !exists("*<SID>RapidSetFandCorrEOL()")

  function <SID>RapidSetFandCorrEOL() abort
    setf rapid
    if get(g:,'rapidAutoCorrCfgLineEnd',1)
      silent! %s/\r//
      normal ``
    endif
  endfunction

  function s:ftIsRapid() abort
    return getline(nextnonblank(1)) =~? '%%%\|^\s*module\s\+\w\+\s*\%((\|$\)'
  endfunction

  function s:nextLPrologCodeLine(n) abort
    let s:n = nextnonblank(a:n)
    " skip lines that look like lprolog comments
    while s:n =~ '^\s*%'
      let s:n = nextnonblank(s:n+1)
    endwhile
    return s:n
  endfunction

endif

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
