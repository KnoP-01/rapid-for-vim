" ABB Rapid Command file type detection for Vim
" Language: ABB Rapid Command
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeffrobotics.de>
" Version: 2.2.7
" Last Change: 12. May 2023
" Credits:
"

let s:keepcpo = &cpo
set cpo&vim

" Change default autocmd
" Make sure to catch both *.ext and *.ext\c...
" No augroup! see :h ftdetect
au! BufNewFile *.prg,*.Prg,*.PRG,*.prg\c
      \  setf rapid
au! BufRead *.prg,*.Prg,*.PRG,*.prg\c
      \  if s:IsRapid()
      \|   setf rapid
      \| elseif exists("g:filetype_prg")
      \|   exe "setf " . g:filetype_prg
      \| else
      \|   setf clipper
      \| endif
au! BufNewFile *.mod,*.Mod,*.MOD,*.mod\c
      \  setf rapid
au! BufRead *.mod,*.Mod,*.MOD,*.mod\c
      \  if s:IsRapid()
      \|   setf rapid
      \| elseif exists("g:filetype_mod")
      \|   exe "setf " . g:filetype_mod
      \| elseif s:IsLProlog()
      \|   setf lprolog
      \| elseif getline(nextnonblank(1)) =~ '\%(\<MODULE\s\+\w\+\s*;\|^\s*(\*\)'
      \|   setf modula2
      \| elseif expand("<afile>") =~ '\<go.mod$'
      \|   setf gomod
      \| else
      \|   setf modsim3
      \| endif
au! BufNewFile *.sys,*.Sys,*.SYS,*.sys\c
      \  setf rapid 
au! BufRead *.sys,*.Sys,*.SYS,*.sys\c
      \  if s:IsRapid()
      \|   setf rapid 
      \| elseif exists("g:filetype_sys")
      \|   exe "setf " . g:filetype_sys
      \| else 
      \|   setf dosbatch 
      \| endif
au! BufNewFile *.cfg,*.Cfg,*.CFG,*.cfg\c
      \  setf rapid
au! BufRead *.cfg,*.Cfg,*.CFG,*.cfg\c
      \  if s:IsRapid("cfg")
      \|   call <SID>RapidSetFandCorrEOL() 
      \| elseif exists("g:filetype_cfg")
      \|   exe "setf " . g:filetype_cfg
      \| else 
      \|   setf cfg 
      \| endif

if !exists("*<SID>RapidSetFandCorrEOL()")

  function <SID>RapidSetFandCorrEOL() abort
    setf rapid
    if get(g:,'rapidAutoCorrCfgLineEnd',1)
      silent! %s/\r//
      normal ``
    endif
  endfunction

  " Returns true if file content looks like RAPID
  function s:IsRapid(sChkExt = "") abort
    if a:sChkExt == "cfg"
      return getline(1) =~? '\v^%(EIO|MMC|MOC|PROC|SIO|SYS):CFG'
    endif
    " called from FTmod, FTprg or FTsys
    return getline(nextnonblank(1)) =~? '\v^\s*%(\%{3}|module\s+\k+\s*%(\(|$))'
  endfunction

  " Returns true if file content looks like LambdaProlog
  function s:IsLProlog() abort
    " skip apparent comments and blank lines, what looks like 
    " LambdaProlog comment may be RAPID header
    let l = nextnonblank(1)
    while l > 0 && l < line('$') && getline(l) =~ '^\s*%' " LambdaProlog comment
      let l = nextnonblank(l + 1)
    endwhile
    " this pattern must not catch a go.mod file
    return getline(l) =~ '\<module\s\+\w\+\s*\.\s*\(%\|$\)'
  endfunction

endif

let &cpo = s:keepcpo
unlet s:keepcpo

" vim:sw=2 sts=2 et
