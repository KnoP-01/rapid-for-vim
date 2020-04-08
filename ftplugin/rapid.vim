" ABB Rapid Command file type plugin for Vim
" Language: ABB Rapid Command
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 2.2.1
" Last Change: 08. Apr 2020
" Credits: Peter Oddings (KnopUniqueListItems/xolox#misc#list#unique)
"          Thanks for beta testing to Thomas Baginski
"
" Suggestions of improvement are very welcome. Please email me!
"
" ToDo's {{{
" TODO  - make file search case insensitive
"       - make [[, [], ][ and ]] text objects
"
" }}} ToDo's

" Init {{{

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:keepcpo = &cpo
set cpo&vim

" if rapidShortenQFPath exists it's pushed to knopShortenQFPath
if exists("g:rapidShortenQFPath")
  if !exists("g:knopShortenQFPath")
    let g:knopShortenQFPath=g:rapidShortenQFPath
  endif
  unlet g:rapidShortenQFPath
endif
" if rapidNoVerbose exists it's pushed to knopNoVerbose
if exists("g:rapidNoVerbose")
  if !exists("g:knopNoVerbose")
    let g:knopNoVerbose=g:rapidNoVerbose
  endif
  unlet g:rapidNoVerbose
endif
if exists("g:rapidVerbose")
  if !exists("g:knopVerbose")
    let g:knopVerbose=get(g:,'rapidVerbose')
  endif
  unlet g:rapidVerbose
endif
" if knopVerbose exists it overrides knopNoVerbose
if exists("g:knopVerbose")
  silent! unlet g:knopNoVerbose
endif
" if knopNoVerbose still exists it's pushed to knopVerbose
if exists("g:knopNoVerbose")
  let g:knopVerbose=!get(g:,'knopNoVerbose')
  unlet g:knopNoVerbose
endif
if exists("g:rapidRhsQuickfix")
  if !exists("g:knopRhsQuickfix")
    let g:knopRhsQuickfix = g:rapidRhsQuickfix
  endif
  unlet g:rapidRhsQuickfix
endif
if exists("g:rapidLhsQuickfix")
  if !exists("g:knopLhsQuickfix")
    let g:knopLhsQuickfix = g:rapidLhsQuickfix
  endif
  unlet g:rapidLhsQuickfix
endif
if exists("g:rapidNoPath") 
  if !exists("g:rapidPath")
    let g:rapidPath = !g:rapidNoPath
  endif
  unlet g:rapidNoPath
endif

" }}} init

" only declare functions once
if !exists("*s:KnopVerboseEcho()")

  " Little Helper {{{

  if get(g:,'knopVerbose',0)
    let g:knopCompleteMsg = 1
    let g:knopCompleteMsg2 = 1
    let g:knopVerboseMsg = 1
  endif
  if exists('g:knopVerboseMsg')
    unlet g:knopVerboseMsg
    echomsg "Switch verbose messages off with \":let g:knopVerbose=0\" any time. You may put this in your .vimrc"
  endif
  function s:KnopVerboseEcho(msg, ...)
    if get(g:,'knopVerbose',0)
      if type(a:msg) == v:t_list
        let l:msg = a:msg
      elseif type(a:msg) == v:t_string
        let l:msg = split(a:msg, "\n")
      else
        return
      endif
      for l:i in l:msg
        echomsg l:i
      endfor
      if exists('a:1')
        " for some reason I don't understand this has to be present twice
        call input("Hit enter> ")
        call input("Hit enter> ")
      endif
    endif
  endfunction " s:KnopVerboseEcho()

  function s:KnopDirExists(in)
    if finddir( substitute(a:in,'\\','','g') )!=''
      return 1
    endif
    return 0
  endfunction " s:KnopDirExists

  function s:KnopFnameescape4Path(in)
    " escape a path for use as 'execute "set path=" . s:KnopFnameescape4Path(mypath)'
    " use / (not \) as a separator for the input parameter
    let l:out = fnameescape( a:in )
    let l:out = substitute(l:out, '\\#', '#', "g") " # and % will get escaped by fnameescape() but must not be escaped for set path...
    let l:out = substitute(l:out, '\\%', '%', "g")
    let l:out = substitute(l:out, '\\ ', '\\\\\\ ', 'g') " escape spaces with three backslashes
    let l:out = substitute(l:out, ',', '\\\\,', 'g') " escape comma and semicolon with two backslashes
    let l:out = substitute(l:out, ';', '\\\\;', "g")
    return l:out
  endfunction

  function s:knopCompleteEnbMsg()
    if exists("g:knopCompleteMsg")
      unlet g:knopCompleteMsg
      call s:KnopVerboseEcho("Add the following files to 'complete'.\n  Try <Ctrl-p> and <Ctrl-n> to complete words from there:")
    endif
  endfunction " s:knopCompleteEnbMsg

  function s:KnopSplitAndUnescapeCommaSeparatedPathStr(commaSeparatedPathStr)
    let l:pathList = []
    for l:pathItem in split(a:commaSeparatedPathStr,'\\\@1<!,')
      if l:pathItem != ''
        call add(l:pathList,substitute(l:pathItem,'\\','','g'))
      endif
    endfor
    return l:pathList
  endfunction

  function s:KnopAddFileToCompleteOption(file,pathList,...)
    let l:file=a:file
    for l:path in a:pathList
      let l:path = substitute(l:path,'[\\/]\*\*$','','')
      if l:path != ''
        if filereadable(l:path.'/'.l:file)!=''
          let l:f = s:KnopFnameescape4Path(l:path.'/'.l:file)
          call s:knopCompleteEnbMsg()
          if exists("g:knopCompleteMsg2")|call s:KnopVerboseEcho(l:f)|endif
          execute 'setlocal complete+=k'.l:f
          return
        else
        endif
      else
      endif
    endfor
    if exists('a:1')
      let l:f = a:1
      if filereadable(l:f)!=''
        let l:f = s:KnopFnameescape4Path(a:1)
        call s:knopCompleteEnbMsg()
        if exists("g:knopCompleteMsg2")|call s:KnopVerboseEcho(l:f)|endif
        execute 'setlocal complete+=k'.l:f
        return
      else
      endif
    endif
  endfunction " s:KnopAddFileToCompleteOption()

  function s:KnopSubStartToEnd(search,sub,start,end)
    execute 'silent '. a:start .','. a:end .' s/'. a:search .'/'. a:sub .'/ge'
    call cursor(a:start,0)
  endfunction " s:KnopSubStartToEnd()

  function s:KnopUpperCase(start,end)
    call cursor(a:start,0)
    execute "silent normal! gU" . (a:end - a:start) . "j"
    call cursor(a:start,0)
  endfunction " s:KnopUpperCase()

  " taken from Peter Oddings
  " function! xolox#misc#list#unique(list)
  " xolox/misc/list.vim
  function s:KnopUniqueListItems(list)
    " Remove duplicate values from the given list in-place (preserves order).
    call reverse(a:list)
    call filter(a:list, 'count(a:list, v:val) == 1')
    return reverse(a:list)
  endfunction " s:KnopUniqueListItems()

  function s:KnopPreparePath(path,file)
    " prepares 'path' for use with vimgrep
    let l:path = substitute(a:path,'$',' ','') " make sure that space is the last char
    let l:path = substitute(l:path,'\v(^|[^\\])\zs,+',' ','g') " separate with spaces instead of comma
    let l:path = substitute(l:path, '\\,', ',', "g") " unescape comma and semicolon
    let l:path = substitute(l:path, '\\;', ';', "g")
    let l:path = substitute(l:path, "#", '\\#', "g") " escape #, % and `
    let l:path = substitute(l:path, "%", '\\%', "g")
    let l:path = substitute(l:path, '`', '\\`', "g")
    " let l:path = substitute(l:path, '{', '\\{', "g") " I don't get curly braces to work
    " let l:path = substitute(l:path, '}', '\\}', "g")
    let l:path = substitute(l:path, '\*\* ', '**/'.a:file.' ', "g") " append a / to **, . and ..
    let l:path = substitute(l:path, '\.\. ', '../'.a:file.' ', "g")
    let l:path = substitute(l:path, '\. ', './'.a:file.' ', "g")
    call s:KnopVerboseEcho(l:path)
    return l:path
  endfunction " s:KnopPreparePath()

  function s:KnopQfCompatible()
    " check for qf.vim compatiblity
    if exists('g:loaded_qf') && get(g:,'qf_window_bottom',1)
          \&& (get(g:,'knopRhsQuickfix',0)
          \||  get(g:,'knopLhsQuickfix',0))
      call s:KnopVerboseEcho("NOTE: \nIf you use qf.vim then g:knopRhsQuickfix and g:knopLhsQuickfix will not work unless g:qf_window_bottom is 0 (Zero). \nTo use g:knop[RL]hsQuickfix put this in your .vimrc: \n  let g:qf_window_bottom = 0\n\n",1)
      return 0
    endif
    return 1
  endfunction " s:KnopQfCompatible()

  let g:knopPositionQf=1
  function s:KnopOpenQf(useSyntax)
    if getqflist()==[] | return -1 | endif
    cwindow 4
    if getbufvar('%', "&buftype")!="quickfix"
      let l:getback=1
      copen
    endif
    if get(g:,'knopShortenQFPath',1)
      setlocal modifiable
      silent! %substitute/\v\c^([^|]{40,})/\=pathshorten(submatch(1))/
      0
      if !exists("g:knopTmpFile")
        let g:knopTmpFile=tempname()
        augroup knopDelTmpFile
          au!
          au VimLeavePre * call delete(g:knopTmpFile)
          au VimLeavePre * call delete(g:knopTmpFile . "~")
        augroup END
      endif
      execute 'silent save! ' . g:knopTmpFile
      setlocal nomodifiable
      setlocal nobuflisted " to be able to remove from buffer list after writing the temp file
    endif
    augroup KnopOpenQf
      au!
      " reposition after closing
      execute 'au BufWinLeave <buffer='.bufnr('%').'> let g:knopPositionQf=1'
    augroup END
    if a:useSyntax!='' 
      execute 'set syntax='.a:useSyntax 
    endif
    if exists('g:knopPositionQf') && s:KnopQfCompatible() 
      unlet g:knopPositionQf
      if get(g:,'knopRhsQuickfix',0)
        wincmd L
      elseif get(g:,'knopLhsQuickfix',0)
        wincmd H
      endif
    endif
    if exists("l:getback")
      unlet l:getback
      wincmd p
    endif
    return 0
  endfunction " s:KnopOpenQf()

  function s:KnopSearchPathForPatternNTimes(Pattern,path,n,useSyntax)
    call setqflist([])
    try
      execute ':noautocmd ' . a:n . 'vimgrep /' . a:Pattern . '/j ' . a:path
    catch /^Vim\%((\a\+)\)\=:E303/
      call s:KnopVerboseEcho(":vimgrep stopped with E303. No match found")
      return -1
    catch /^Vim\%((\a\+)\)\=:E480/
      call s:KnopVerboseEcho(":vimgrep stopped with E480. No match found")
      return -1
    catch /^Vim\%((\a\+)\)\=:E683/
      call s:KnopVerboseEcho(":vimgrep stopped with E683. No match found")
      return -1
    endtry
    if a:n == 1
      call setqflist(s:KnopUniqueListItems(getqflist()))
    endif
    if s:KnopOpenQf(a:useSyntax)==-1
      call s:KnopVerboseEcho("No match found")
      return -1
    endif
    return 0
  endfunction " s:KnopSearchPathForPatternNTimes()

  function <SID>KnopNTimesSearch(nCount,sSearchPattern,sFlags)
    let l:nCount=a:nCount
    let l:sFlags=a:sFlags
    while l:nCount>0
      if l:nCount < a:nCount
        let l:sFlags=substitute(l:sFlags,'s','','g')
      endif
      call search(a:sSearchPattern,l:sFlags)
      let l:nCount-=1
    endwhile
  endfunction " <SID>KnopNTimesSearch()

  " }}} Little Helper

  " Rapid Helper {{{

  function <SID>RapidCleanBufferList()
    if exists("g:knopTmpFile")
      let l:knopTmpFile = substitute(g:knopTmpFile,'.*[\\/]\(VI\w\+\.tmp\)','\1','')
    endif
    if exists("g:rapidTmpFile")
      let l:rapidTmpFile = substitute(g:rapidTmpFile,'.*[\\/]\(VI\w\+\.tmp\)','\1','')
    endif
    let l:b = {}
    for l:b in getbufinfo({'buflisted':1})
      " unlist temp file buffer
      if exists("g:knopTmpFile")
            \&& l:b["name"] =~ l:knopTmpFile . '$'
            \&& !l:b["hidden"]
        call setbufvar(l:b["bufnr"],"&buflisted",0)
      endif
      if exists("g:rapidTmpFile")
            \&& l:b["name"] =~ l:rapidTmpFile . '$'
            \&& !l:b["hidden"]
        call setbufvar(l:b["bufnr"],"&buflisted",0)
      endif
      " delete those strange empty unnamed buffers
      if        l:b["name"]==""       " not named
            \&& l:b["windows"]==[]    " not shown in any window
            \&& !l:b["hidden"]        " not hidden
            \&& !l:b["changed"]       " not modified
        execute "silent bwipeout! " . l:b["bufnr"]
      endif
    endfor
    augroup RapidCleanBufferList
      " work around where buffer list is not cleaned if knopVerbose is enabled
      autocmd!
    augroup END
  endfunction " <SID>RapidCleanBufferList()

  function s:RapidCurrentWordIs()
    " returns the string "<type><name>" depending on the word under the cursor
    "
    let l:numLine = line(".")
    let l:strLine = getline(".")
    "
    " position the cursor at the start of the current word
    if search('\<','bcsW',l:numLine)
      "
      " init
      let l:numCol = col(".")
      let l:currentChar = strpart(l:strLine, l:numCol-1, 1)
      let l:strUntilCursor = strpart(l:strLine, 0, l:numCol-1)
      let l:lenStrUntilCursor = strlen(l:strUntilCursor)
      "
      " find next char
      if search('\>\s*.',"eW",l:numLine)
        let l:nextChar = strpart(l:strLine, col(".")-1, 1)
      else
        let l:nextChar = ""
      endif
      "
      " set cursor back to start of word
      call cursor(l:numLine,l:numCol)
      "
      " get word at cursor
      let l:word = expand("<cword>")
      "
      " count string chars " before the current char
      let l:i = 0
      let l:countStrChr = 0
      while l:i < l:lenStrUntilCursor
        let l:i = stridx(l:strUntilCursor, "\"", l:i)
        if l:i >= 0
          let l:i = l:i+1
          let l:countStrChr = l:countStrChr+1
        else
          let l:i = l:lenStrUntilCursor+1
        endif
      endwhile
      let l:countStrChr = l:countStrChr%2
      "
      " return something
      if search('!','bcnW',l:numLine)
        return ("comment" . l:word)
        "
      elseif l:countStrChr == 1
        return ("string" . l:word)
        "
      elseif l:word =~ '\v\c^(true|false|high|edge|low)>'
        return ("bool" . l:word)
        "
      elseif l:currentChar =~ '\d' && 
            \(  synIDattr(synID(line("."),col("."),0),"name")=="rapidFloat" 
            \|| synIDattr(synID(line("."),col("."),0),"name")=="")
        return ("num" . l:word)
        "
      elseif l:nextChar == "(" && 
            \(  synIDattr(synID(line("."),col("."),0),"name")=="rapidFunction"
            \|| synIDattr(synID(line("."),col("."),0),"name")=="rapidBuildInFunction"
            \|| synIDattr(synID(line("."),col("."),0),"name")==""
            \)
        if synIDattr(synID(line("."),col("."),0),"name") != "rapidBuildInFunction"
          return ("func" . l:word)
          "
        else
          return ("sysfunc" . l:word)
          "
        endif
      else
        if synIDattr(synID(line("."),col("."),0),"name") != "rapidNames"
              \&& synIDattr(synID(line("."),col("."),0),"name") != ""
          return ("inst" . l:word)
          "
        else
          return ("userdefined" . l:word)
          "
        endif
      endif
    endif
    return "none"
  endfunction " s:RapidCurrentWordIs()

  function s:RapidPutCursorOnModuleAndReturnEndmoduleline()
    if search('\c^\s*module\s','bcW')
      let l:numEndmodule = search('\v\c^\s*endmodule>','nW')
      if l:numEndmodule <= 0
        let l:numEndmodule = line("$")
      endif
    else
      0
      let l:numEndmodule = search('\v\c^\s*endmodule>','nW')
      if l:numEndmodule <= 0
        let l:numEndmodule = line("$")
      endif
    endif
    return l:numEndmodule
  endfunction

  " }}} Rapid Helper

  " Go Definition {{{

  function s:RapidSearchUserDefined(declPrefix,currentWord)
    "
    let l:numSearchStartLine = line(".")
    let l:numSearchStartColumn = col(".")
    let l:numProcStart = search('\v\c^\s*((local|global|task)\s+)?(proc|func|trap)\s+','bcnW')
    let l:numProcEnd = search('\v\c^\s*end(proc|func|trap)>','cnW')
    "
    " if search starts inside a proc, search local decl
    if l:numProcStart != 0 && l:numProcEnd  != 0
          \&& search('\v\c^\s*(((local|global|task)\s+)?(proc|func|trap)\s+|endmodule)','cnW') > l:numProcEnd
          \&& search('\v\c^\s*end(proc|func|trap)>','bcnW') < l:numProcStart
      "
      " search FOR loop local auto declaration
      call s:KnopVerboseEcho("search FOR loop local auto declaration")
      let l:nFor = 0
      let l:nEndfor = 0
      let l:nSkipFor = 0
      while search('\v\c^\s*(end)?for>','bW',l:numProcStart)
        if expand("<cword>") =~ '\c\<endfor'
          let l:nEndfor = l:nEndfor+1
          let l:nSkipFor = l:nSkipFor+1
        elseif expand("<cword>") =~ '\c\<for'
          let l:nFor = l:nFor+1
          if      l:nFor>l:nEndfor && 
                \ l:nSkipFor<=0 &&
                \ search('\c\v\s+for\s+\zs'.a:currentWord.'>','cW',line("."))
            call s:KnopVerboseEcho("Found FOR loop local auto declaration",1)
            return 0
            "
          endif
          if l:nSkipFor > 0
            let l:nSkipFor = l:nSkipFor-1
          endif
        endif
      endwhile " FOR loop local auto declaration
      "
      " search Proc/Func/Trap argument declaration
      call s:KnopVerboseEcho("search Proc/Func/Trap argument declaration")
      call cursor(l:numProcStart,1)
      let l:noneCloseParen = '([^)]|\n)*'
      if search('\c\v^'.l:noneCloseParen.'\('.l:noneCloseParen.'\w(\s|\n)*\zs<'.a:currentWord.'>'.l:noneCloseParen.'\)','cW',line("."))
        call s:KnopVerboseEcho("Found VARIABLE declaration in ARGUMENT list",1)
        return 0
        "
      endif " search Proc/Func/Trap argument declaration
      "
      " search Proc/Func/Trap local declaration
      call s:KnopVerboseEcho("search Proc/Func/Trap local declaration")
      call cursor(l:numProcStart,1)
      if search(a:declPrefix.'\zs'.a:currentWord.'>','W',l:numProcEnd)
        call s:KnopVerboseEcho("Found PROC, FUNC or TRAP local VARIABLE declaration",1)
        return 0
        "
      endif
    endif " search inside Proc/Func/Trap for local declaration
    "
    " search Module local variable declaration
    call s:KnopVerboseEcho("search Module local variable declaration")
    let l:numEndmodule=s:RapidPutCursorOnModuleAndReturnEndmoduleline()
    while search(a:declPrefix.'\zs'.a:currentWord.'>','W',l:numEndmodule)
      " found something, remember where
      let l:numFoundLine = line(".")
      let l:numFoundCol = col(".")
      " rule out proc local declarations
      if search('\v\c^\s*((local|global|task)\s+)?(end)?(proc|func|trap|record|module)>','W') && 
            \(  expand("<cword>") !~ '\c\v^\s*end(proc|func|trap|record)>' 
            \|| expand("<cword>") =~ '\c\v^\s*endmodule>' 
            \)
        call cursor(l:numFoundLine,l:numFoundCol)
        call s:KnopVerboseEcho("Found VARIABLE declaration in this MODULE",1)
        return 0
        "
      endif
    endwhile " search Module local variable declaration
    " 
    " search Module local proc (et al) declaration
    call s:KnopVerboseEcho("search Module local proc (et al) declaration")
    let l:numEndmodule=s:RapidPutCursorOnModuleAndReturnEndmoduleline()
    if search('\v\c^\s*((local|global|task)\s+)?(proc|func\s+\w+|trap|record)\s+\zs'.a:currentWord.'>','cW',l:numEndmodule)
      call s:KnopVerboseEcho("Found declaration of PROC, FUNC, TRAP or RECORD in this MODULE",1)
      return 0
      "
    endif " search Module local proc (et al) declaration
    "
    " nothing found in current module, put cursor back where search started
    call cursor(l:numSearchStartLine,l:numSearchStartColumn)
    "
    " search global declaration
    call s:KnopVerboseEcho("search global declaration")
    for l:i in ['task', 'system']
      "
      " first fill location list with all (end)?(proc|func|trap|record) and variable
      " declarations with currentWord
      let l:prefix = '/\c\v^\s*(local\s+|task\s+|global\s+)?((var|pers|const)\s+\w+\s+'
      let l:suffix = '>|(end)?(proc|func|trap|record)>)/j' " since this finds all (not only global) ends, the previous must also list local
      if l:i =~ 'task'
        if has("win32")
          let l:path = './*.prg ./*.mod ./*.sys '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.sys'
        else
          let l:path = './*.prg ./*.Prg ./*.PRG ./*.mod ./*.Mod ./*.MOD ./*.sys ./*.Sys ./*.SYS '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.Mod '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.MOD '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.sys '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.Sys '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.SYS '
        endif
      elseif l:i =~ 'system'
        if has("win32")
          let l:path = './*.prg ./*.mod ./*.sys '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.sys'
        else
          let l:path = './*.prg ./*.Prg ./*.PRG ./*.mod ./*.Mod ./*.MOD ./*.sys ./*.Sys ./*.SYS '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.Mod '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.MOD '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.sys '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.Sys '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.SYS '
        endif
      endif
      try
        execute ':noautocmd lvimgrep '.l:prefix.a:currentWord.l:suffix.' '.l:path
      catch /^Vim\%((\a\+)\)\=:E480/
        call s:KnopVerboseEcho(":lvimgrep stopped with E480!",1)
        return -1
        "
      catch /^Vim\%((\a\+)\)\=:E683/
        call s:KnopVerboseEcho(":lvimgrep stopped with E683!",1)
        return -1
        "
      endtry
      "
      " search for global proc in loclist
      call s:KnopVerboseEcho("search for global proc in loclist")
      if l:i =~ 'task'
        let l:procdecl = '\v\c^\s*(task\s+|global\s+)?(proc|func\s+\w+|trap|record)\s+'
      elseif l:i =~ 'system'
        let l:procdecl = '\v\c^\s*(global\s+)?(proc|func\s+\w+|trap|record)\s+'
      endif
      let l:loclist = getloclist(0)
      let l:qf = []
      for l:loc in l:loclist
        if l:loc.text =~ l:procdecl.a:currentWord.'>'
          call setqflist([])
          call add(l:qf,l:loc)
          call setqflist(l:qf)
          if l:i =~ 'task'
            call s:KnopVerboseEcho("Found declaration of PROC, FUNC, TRAP or RECORD in this TASK",1)
          elseif l:i =~ 'system'
            call s:KnopVerboseEcho("Found declaration of PROC, FUNC, TRAP or RECORD in SYSTEM (other task)",1)
          endif
          call s:KnopOpenQf('rapid')
          return 0
          "
        endif
      endfor
      "
      " then search for global variable in loc list
      call s:KnopVerboseEcho("search for global variable in loc list")
      let l:procdecl = '\v\c^\s*(local\s+|task\s+|global\s+)?(proc|func\s+\w+|trap|record)\s+' " procdecl must also contain local, since all ends are present
      let l:endproc = '\v\c^\s*end(proc|func|trap|record)>'
      let l:skip = 0
      if l:i =~ 'task'
        let l:declPrefix = substitute(a:declPrefix, 'local\\s+|', '', '')
      elseif l:i =~ 'system'
        let l:declPrefix = substitute(l:declPrefix, 'task\\s+|', '', '')
      endif
      for l:loc in l:loclist
        if l:loc.text =~ l:procdecl
          let l:skip = 1 " skip until next endproc
        endif
        if l:skip == 0
          if l:loc.text =~ l:declPrefix.a:currentWord.'>'
            call setqflist([])
            call add(l:qf,l:loc)
            call setqflist(l:qf)
            if l:i =~ 'task'
              call s:KnopVerboseEcho("Found VARIABLE declaration in this TASK",1)
            elseif l:i =~ 'system'
              call s:KnopVerboseEcho("Found VARIABLE declaration in SYSTEM (other task)",1)
            endif
            call s:KnopOpenQf('rapid')
            return 0
            "
          endif
        endif
        if l:loc.text =~ l:endproc
          let l:skip = 0 " skip done
        endif
      endfor
      "
    endfor " search 'task' or 'system' global declaration
    "
    " search EIO.cfg
    call s:KnopVerboseEcho("search EIO.cfg")
    if filereadable("./EIO.cfg")
      let l:path = './EIO.cfg'
    elseif filereadable("./EIO.Cfg")
      let l:path = './EIO.Cfg'
    elseif filereadable("./EIO.CFG")
      let l:path = './EIO.CFG'
    elseif filereadable("./SYSPAR/EIO.cfg")
      let l:path = './SYSPAR/EIO.cfg'
    elseif filereadable("./SYSPAR/EIO.Cfg")
      let l:path = './SYSPAR/EIO.Cfg'
    elseif filereadable("./SYSPAR/EIO.CFG")
      let l:path = './SYSPAR/EIO.CFG'
    elseif filereadable("./../../SYSPAR/EIO.cfg")
      let l:path = './../../SYSPAR/EIO.cfg'
    elseif filereadable("./../../SYSPAR/EIO.Cfg")
      let l:path = './../../SYSPAR/EIO.Cfg'
    elseif filereadable("./../../SYSPAR/EIO.CFG")
      let l:path = './../../SYSPAR/EIO.CFG'
    elseif filereadable('./../../../SYSPAR/EIO.cfg')
      let l:path = './../../../SYSPAR/EIO.cfg'
    elseif filereadable('./../../../SYSPAR/EIO.Cfg')
      let l:path = './../../../SYSPAR/EIO.Cfg'
    elseif filereadable('./../../../SYSPAR/EIO.CFG')
      let l:path = './../../../SYSPAR/EIO.CFG'
    else
      call s:KnopVerboseEcho("No EIO.cfg found!",1)
      return -1
      "
    endif
    let l:strPattern = '\c\v^\s*-name\s+"'.a:currentWord.'>'
    let l:searchResult = s:KnopSearchPathForPatternNTimes(l:strPattern,l:path,1,"rapid")
    if l:searchResult == 0
      call s:KnopVerboseEcho("Found signal(?) in EIO.cfg. The quickfix window will open. See :he quickfix-window",1)
      return 0
      "
    endif
    "
    call s:KnopVerboseEcho("Nothing found.",1)
    return -1
  endfunction " s:RapidSearchUserDefined()

  function <SID>RapidGoDefinition()
    augroup RapidCleanBufferList
      " work around where buffer list is not cleaned if knopVerbose is enabled
      autocmd!
      autocmd CursorMoved * call <SID>RapidCleanBufferList()
    augroup END
    "
    let l:declPrefix = '\c\v^\s*(local\s+|task\s+|global\s+)?(var|pers|const|alias)\s+\w+\s+'
    "
    " suche das naechste wort
    if search('\w','cW',line("."))
      "
      let l:currentWord = s:RapidCurrentWordIs()
      "
      if l:currentWord =~ '^userdefined.*'
        let l:currentWord = substitute(l:currentWord,'^userdefined','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be userdefined. Start search..."])
        return s:RapidSearchUserDefined(l:declPrefix,l:currentWord)
        "
      elseif l:currentWord =~ '\v^(sys)?func.*'
        let l:currentWord = substitute(l:currentWord,'\v^%(sys)?func','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a FUNCTION. Start search..."])
        return s:RapidSearchUserDefined(l:declPrefix,l:currentWord)
        "
      elseif l:currentWord =~ '^inst.*'
        let l:currentWord = substitute(l:currentWord,'^inst','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a Rapid KEYWORD. No search performed."],1)
      elseif l:currentWord =~ '^num.*'
        let l:currentWord = substitute(l:currentWord,'^num','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a NUMBER. No search performed."],1)
      elseif l:currentWord =~ '^bool.*'
        let l:currentWord = substitute(l:currentWord,'^bool','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a BOOLEAN VALUE. No search performed."],1)
      elseif l:currentWord =~ '^string.*'
        let l:currentWord = substitute(l:currentWord,'^string','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a STRING. Start search..."])
        return s:RapidSearchUserDefined(l:declPrefix,l:currentWord)
        "
      elseif l:currentWord =~ '^comment.*'
        let l:currentWord = substitute(l:currentWord,'^comment','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a COMMENT. No search performed."],1)
      else
        let l:currentWord = substitute(l:currentWord,'^none','','')
        call s:KnopVerboseEcho([l:currentWord,"Could not determine typ of current word. No search performed."],1)
      endif
      return -1
      "
    endif
    "
    call s:KnopVerboseEcho("Unable to determine what to search for at current cursor position. No search performed.",1)
    return -1
    "
  endfunction " <SID>RapidGoDefinition()

  " }}} Go Definition

  " Auto Form {{{

  function s:RapidGetGlobal(sAction)
    if a:sAction=~'^[lg]'
      let l:sGlobal = a:sAction
    else
      let l:sGlobal = substitute(input("\n[g]lobal or [l]ocal?\n> "),'\W*','','g')
    endif
    if l:sGlobal=~'\c^\s*g'
      return "g"
    elseif l:sGlobal=~'\c^\s*l'
      return "LOCAL "
    endif
    return ''
  endfunction " s:RapidGetGlobal()

  function s:RapidGetType(sAction)
    if a:sAction =~ '^.[pftr]'
      let l:sType = substitute(a:sAction,'^.\(\w\).','\1','')
    else
      let l:sType = substitute(input("\n[p]roc, [f]unc, [t]rap or [r]ecord? \n> "),'\W*','','g')
    endif
    if l:sType =~ '\c^\s*p'
      return "PROC"
    elseif l:sType =~ '\c^\s*f'
      return "FUNC"
    elseif l:sType =~ '\c^\s*t'
      return "TRAP"
    elseif l:sType =~ '\c^\s*r'
      return "RECORD"
    endif
    return ''
  endfunction " s:RapidGetType()

  function s:RapidGetName()
    let l:sName = substitute(input("\nName?\n Type <space><enter> for word under cursor.\n> "),'[^ 0-9a-zA-Z_]*','','g')
    if l:sName==""
      return ''
    elseif l:sName=~'^ $' " sName from current word
      let l:sName = expand("<cword>")
    endif
    let l:sName = substitute(l:sName,'\W*','','g')
    return l:sName
  endfunction " s:RapidGetName()

  function s:RapidGetDataType(sAction)
    if a:sAction=~'..[bndsprjtw]'
      let l:sDataType = substitute(a:sAction,'..\(\w\)','\1','')
    else
      let l:sDataType = substitute(input("\nData type? \n
            \Choose [b]ool, [n]um, [d]num, [s]ring, [p]ose, [r]obtarget, [j]ointtarget, [t]ooldata, [w]objdata,\n
            \ or enter your desired data type\n> "),'[^ 0-9a-zA-Z_{}]*','','g')
    endif
    if l:sDataType=~'\c^b$'
      return "bool"
    elseif l:sDataType=~'\c^n$'
      return "num"
    elseif l:sDataType=~'\c^d$'
      return "dnum"
    elseif l:sDataType=~'\c^s$'
      return "string"
    elseif l:sDataType=~'\c^p$'
      return "pose"
    elseif l:sDataType=~'\c^r$'
      return "robtarget"
    elseif l:sDataType=~'\c^j$'
      return "jointtarget"
    elseif l:sDataType=~'\c^t$'
      return "tooldata"
    elseif l:sDataType=~'\c^w$'
      return "wobjdata"
    endif
    return substitute(l:sDataType,'[^0-9a-zA-Z_{}]*','','g')
  endfunction " s:RapidGetDataType()

  function s:RapidGetReturnVar(sDataType)
    if a:sDataType=~'\c^bool\>'
      return "bResult"
    elseif a:sDataType=~'\c^num\>'
      return "nResult"
    elseif a:sDataType=~'\c^dnum\>'
      return "dResult"
    elseif a:sDataType=~'\c^string\>'
      return "sResult"
    elseif a:sDataType=~'\c^pose\>'
      return "pResult"
    elseif a:sDataType=~'\c^robtarget\>'
      return "rtResult"
    elseif a:sDataType=~'\c^jointtarget\>'
      return "jtResult"
    elseif a:sDataType=~'\c^tooldata\>'
      return "tResult"
    elseif a:sDataType=~'\c^wobjdata\>'
      return "woResult"
    endif
    return substitute(a:sDataType,'^\(..\).*','\l\1','')."Result"
  endfunction " s:RapidGetReturnVar()

  function s:RapidPositionForEdit(sType)
    let l:commentline = '^\s*!'
    " empty file
    if line('$')==1 && getline('.')=='' | return | endif
    if a:sType =~ '\v(PROC|FUNC|TRAP)' " position for PROC, FUNC or TRAP
      if search('\v\c^\s*(local\s+)?(proc|func|trap|endmodule)>','csW')
        let l:prevline = getline(line('.')-1)
        while l:prevline=~l:commentline
          normal! k
          let l:prevline = getline(line('.')-1)
        endwhile
        normal! k
        normal! o
        normal! O
        if getline(line('.')-1) != ''
          normal! o
        endif
        return
      endif
    else " position for RECORD close to top of module
      if search('\c^\s*module\s','bcsW') || search('\c^\s*module\s','csW')
        execute "normal " . nextnonblank(line('.')+1) . "gg"
        let l:nextline = getline(line('.')+1)
        while l:nextline=~l:commentline
          normal! j
          let l:nextline = getline(line('.')+1)
        endwhile
        normal! o
        normal! o
        if getline(line('.')+1) != ''
          normal! O
        endif
        return
      endif
    endif
    " default positioning for PROC, FUNC, TRAP and RECORD if no ancor was found
    normal! G
    if getline('.') != ''
      normal! o
    endif
    if getline(line('.')-1) != ''
      normal! o
    endif
  endfunction " s:RapidPositionForEdit()

  function s:RapidPositionForRead(sType)
    call s:RapidPositionForEdit(a:sType)
    if getline('.')=~'^\s*$'
          \&& line('.')!=line('$')
      delete
    endif
  endfunction " s:RapidPositionForRead()

  function s:RapidReadBody(sBodyFile,sType,sName,sGlobal,sDataType,sReturnVar)
    let l:sBodyFile = glob(fnameescape(g:rapidPathToBodyFiles)).a:sBodyFile
    if !filereadable(glob(l:sBodyFile))
      call s:KnopVerboseEcho([l:sBodyFile,": Body file not readable."],1)
      return
    endif
    " read body
    call s:RapidPositionForRead(a:sType)
    execute "silent .-1read ".glob(l:sBodyFile)
    " set marks
    let l:start = line('.')
    let l:end = search('\v\c^\s*end(proc|trap|record|func)?>','cnW')
    " substitute marks in body
    call s:KnopSubStartToEnd('<name>',a:sName,l:start,l:end)
    call s:KnopSubStartToEnd('<type>',a:sType,l:start,l:end)
    call s:KnopSubStartToEnd('<global>',a:sGlobal,l:start,l:end)
    " set another mark after the def(fct|dat)? line is present
    let l:defstart = search('\v\c^\s*(local\s+)?(proc|trap|record|func)?>','cnW')
    call s:KnopSubStartToEnd('<datatype>',a:sDataType,l:start,l:end)
    call s:KnopSubStartToEnd('<returnvar>',a:sReturnVar,l:start,l:end)
    " indent
    if exists("b:did_indent")
      if l:start>0 && l:end>l:start
        execute l:start.','.l:end."substitute/^/ /"
        call cursor(l:start,0)
        execute "silent normal! " . (l:end-l:start+1) . "=="
      endif
    endif
    " position cursor
    call cursor(l:start,0)
    if search('<|>','cW',l:end)
      call setline('.',substitute(getline('.'),'<|>','','g'))
    endif
  endfunction " s:RapidReadBody()

  function s:RapidDefaultBody(sType,sName,sGlobal,sDataType,sReturnVar)
    call s:RapidPositionForEdit(a:sType)
    call setline('.',a:sGlobal . a:sType . " " . a:sDataType . " " . a:sName . '()')
    if a:sType =~ '\v\c(trap|record)' | silent substitute/()// | endif
    if a:sType =~ '\v\c(proc|trap|record)' | silent substitute/  / / | endif
    if a:sType =~ 'FUNC'
      normal! o
      call setline('.','VAR ' . a:sDataType . " " . a:sReturnVar . ';')
    endif
    normal! o
    call setline('.','!')
    if a:sType =~ 'FUNC'
      normal! o
      call setline('.','Return ' . a:sReturnVar . ';')
    endif
    if a:sType =~ 'PROC'
      normal! o
      call setline('.','ERROR')
      normal! o
      call setline('.','!')
    endif
    normal! o
    call setline('.','END' . a:sType . ' ! ' . a:sName . '()')
    if a:sType =~ '\v\c(trap|record)' | silent substitute/()// | endif
    let l:end = line('.')
    let l:start = search(a:sType,'bW')
    if exists("b:did_indent")
      if l:start>0 && l:end>l:start
        execute l:start.','.l:end."substitute/^/ /"
        call search(a:sType,'bW')
        execute "silent normal! " . (l:end-l:start+1) . "=="
      endif
    endif
    call search('^\s*!','eW',l:end)
  endfunction " s:RapidDefaultBody()

  function <SID>RapidAutoForm(sAction)
    " check input
    if a:sAction !~ '^[ gl][ pftr][ bndsprjtw]$' | return | endif
    "
    let l:sGlobal = s:RapidGetGlobal(a:sAction)
    if l:sGlobal == '' | return | endif " return if empty string was entered by user
    let l:sGlobal = substitute(l:sGlobal,'g','','g')
    "
    " get proc, func, trap or record
    let l:sType = s:RapidGetType(a:sAction)
    if l:sType == '' | return | endif " return if empty string was entered by user
    "
    " get data type and name of return variable if type is func
    let l:sDataType = ''
    let l:sReturnVar = ''
    if l:sType =~ 'FUNC'
      let l:sDataType = s:RapidGetDataType(a:sAction)
      if l:sDataType == '' | return | endif " return if empty string was entered by user
      let l:sReturnVar = s:RapidGetReturnVar(l:sDataType)
    endif
    "
    let l:sName = s:RapidGetName()
    if l:sName == '' | return | endif " return if empty string was entered by user
    "
    if exists("g:rapidPathToBodyFiles") && 
          \ ( l:sType =~ 'PROC' && filereadable(glob(fnameescape(g:rapidPathToBodyFiles)).'PROC.mod')
          \|| l:sType =~ 'TRAP' && filereadable(glob(fnameescape(g:rapidPathToBodyFiles)).'TRAP.mod')
          \|| l:sType =~ 'RECORD' && filereadable(glob(fnameescape(g:rapidPathToBodyFiles)).'RECORD.mod')
          \|| l:sType =~ 'FUNC' && filereadable(glob(fnameescape(g:rapidPathToBodyFiles)).'FUNC.mod') )
      call s:RapidReadBody(l:sType.'.mod',l:sType,l:sName,l:sGlobal,l:sDataType,l:sReturnVar)
      call s:KnopVerboseEcho(g:rapidPathToBodyFiles . l:sType . '.mod body inserted.',1)
    else
      call s:RapidDefaultBody(l:sType,l:sName,l:sGlobal,l:sDataType,l:sReturnVar)
      if exists("g:rapidPathToBodyFiles")
        call s:KnopVerboseEcho(g:rapidPathToBodyFiles . l:sType . '.mod is not readable. Fallback to default body.',1)
      else
        call s:KnopVerboseEcho('Default body inserted.',1)
      endif
    endif
    "
    normal! zz
    silent doautocmd User RapidAutoFormPost
    "
  endfunction " <SID>RapidAutoForm()

  " }}} Auto Form

  " List Def/Usage {{{

  function <SID>RapidListDefinition()
    augroup RapidCleanBufferList
      " work around where buffer list is not cleaned if knopVerbose is enabled
      autocmd!
      autocmd CursorMoved * call <SID>RapidCleanBufferList()
    augroup END
    " list defs in qf
    if s:KnopSearchPathForPatternNTimes('\v\c^\s*(global\s+|task\s+|local\s+)?(proc|func|trap|record|module)>','%','','rapid')==0
      if getqflist()==[] | return | endif
      " put cursor back after manipulating qf
      if getbufvar('%', "&buftype")!="quickfix"
        let l:getback=1
        noautocmd copen
      endif
      if getbufvar('%', "&buftype")!="quickfix" | return | endif
      setlocal modifiable
      silent %substitute/\v\c^.*\|\s*((global\s+|task\s+|local\s+)?(proc|func|trap|record|module)>)/\1/
      0
      if !exists("g:rapidTmpFile")
        let g:rapidTmpFile=tempname()
        augroup rapidDelTmpFile
          au!
          au VimLeavePre * call delete(g:rapidTmpFile)
          au VimLeavePre * call delete(g:rapidTmpFile . "~")
        augroup END
      endif
      execute 'silent save! ' . g:rapidTmpFile
      setlocal nomodifiable
      setlocal nobuflisted " to be able to remove from buffer list after writing the temp file
      if exists("l:getback")
        unlet l:getback
        wincmd p
      endif
    else
      call s:KnopVerboseEcho("Nothing found.",1)
    endif
  endfunction " <SID>RapidListDefinition()

  function <SID>RapidListUsage()
    augroup RapidCleanBufferList
      " work around where buffer list is not cleaned if knopVerbose is enabled
      autocmd!
      autocmd CursorMoved * call <SID>RapidCleanBufferList()
    augroup END
    "
    if search('\w','cW',line("."))
      let l:currentWord = s:RapidCurrentWordIs()
      "
      if l:currentWord =~ '^userdefined.*'
        let l:currentWord = substitute(l:currentWord,'^userdefined','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be userdefined"])
      elseif l:currentWord =~ '\v^%(sys)?func.*'
        let l:currentWord = substitute(l:currentWord,'\v^%(sys)?func','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a FUNCTION"])
      elseif l:currentWord =~ '^num.*'
        let l:currentWord = substitute(l:currentWord,'^num','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a NUMBER"])
      elseif l:currentWord =~ '^string.*'
        let l:currentWord = substitute(l:currentWord,'^string','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a STRING"])
      elseif l:currentWord =~ '^comment.*'
        let l:currentWord = substitute(l:currentWord,'^comment','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a COMMENT"])
      elseif l:currentWord =~ '^inst.*'
        let l:currentWord = substitute(l:currentWord,'^inst','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a Rapid KEYWORD"])
      elseif l:currentWord =~ '^bool.*'
        let l:currentWord = substitute(l:currentWord,'^bool','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a BOOL VALUE"])
      else
        let l:currentWord = substitute(l:currentWord,'^none','','')
        call s:KnopVerboseEcho([l:currentWord,"Unable to determine what to search for at current cursor position. No search performed!"],1)
        return
        "
      endif
      if s:KnopSearchPathForPatternNTimes('\c\v^[^!]*<'.l:currentWord.'>',s:KnopPreparePath(&path,'*'),'','rapid')==0
        call setqflist(s:KnopUniqueListItems(getqflist()))
        " rule out l:currentWord inside a backup file
        let l:qfresult = []
        for l:i in getqflist()
          if bufname(get(l:i,'bufnr')) !~ '\~$'
        "         \&& (get(l:i,'text') =~ '\v\c^([^"]*"[^"]*"[^"]*)*[^"]*<'.l:currentWord.'>'
        "         \|| (bufname(get(l:i,'bufnr')) !~ '\v\c\w+\.mod$'
        "         \&&  bufname(get(l:i,'bufnr')) !~ '\v\c\w+\.sys$'
        "         \&&  bufname(get(l:i,'bufnr')) !~ '\v\c\w+\.prg$'))
            call add(l:qfresult,l:i)
          endif
        endfor
        call setqflist(l:qfresult)
        call s:KnopVerboseEcho("Opening quickfix with results.",1)
        call s:KnopOpenQf('rapid')
      else
        call s:KnopVerboseEcho("Nothing found.",1)
      endif
    else
      call s:KnopVerboseEcho("Unable to determine what to search for at current cursor position. No search performed.",1)
    endif
  endfunction " <SID>RapidListUsage()

  " }}} List Def/Usage

  " Function Text Object {{{

  if get(g:,'rapidMoveAroundKeyMap',1) " depends on move around key mappings
    function <SID>RapidFunctionTextObject(inner,withcomment)
      if a:inner==1
        let l:n = 1
      else
        let l:n = v:count1
      endif
      if getline('.')!~'\v\c^\s*end(proc|func|trap|record|module)?>'
        silent normal ][
      endif
      silent normal [[
      silent normal! zz
      if a:inner==1
        silent normal! j
      elseif a:withcomment==1
        while line('.')>1 && getline(line('.')-1)=~'^\s*!'
          silent normal! k
        endwhile
      endif
      exec "silent normal V".l:n."]["
      if a:inner==1
        silent normal! k
      elseif a:withcomment==1 && getline(line('.')+1)=~'^\s*$'
        silent normal! j
      endif
    endfunction " RapidFunctionTextObject()
  endif

  " }}} Function Text Object

  " Comment Text Object {{{

  if get(g:,'rapidMoveAroundKeyMap',1) " depends on move around key mappings
    function <SID>RapidCommentTextObject(around)
      if getline('.')!~'^\s*!' && !search('^\s*!',"sW")
        return
      endif
      " starte innerhalb des oder nach dem kommentar
      silent normal! j
      silent normal [;
      if getline(line('.')+1)!~'^\s*!'
        silent normal! V
      else
        silent normal! V
        silent normal ];
      endif
      if a:around && getline(line('.')+1)=~'^\s*$'
        silent normal! j
      endif
    endfunction " RapidCommentTextObject()
  endif

  " }}} Comment Text Object

endif " !exists("*s:KnopVerboseEcho()")

" Vim Settings {{{

" default on; no option
setlocal commentstring=!%s
setlocal comments=:\!
if has("win32")
  setlocal suffixesadd+=.mod,.sys,.prg,.cfg
else
  setlocal suffixesadd+=.mod,.Mod,.MOD,.sys,.Sys,.SYS,.prg,.Prg,.PRG,.cfg,.Cfg,.CFG
endif
let b:undo_ftplugin = "setlocal com< cms< sua<"

" auto insert comment char when i_<CR>, o or O on a comment line
if get(g:,'rapidAutoComment',1)
  setlocal formatoptions+=r
  setlocal formatoptions+=o
  let b:undo_ftplugin = b:undo_ftplugin." fo<"
endif

" format comments
if get(g:,'rapidFormatComments',1)
  if &textwidth ==# 0
    " 78 Chars 
    setlocal textwidth=78
    let b:undo_ftplugin = b:undo_ftplugin." tw<"
  endif
  setlocal formatoptions-=t
  setlocal formatoptions+=l
  setlocal formatoptions+=j
  if stridx(b:undo_ftplugin, " fo<")==(-1)
    let b:undo_ftplugin = b:undo_ftplugin." fo<"
  endif
endif " format comments

" path for gf, :find etc
if get(g:,'rapidPath',1)

  let s:rapidpath=&path.'./**,'
  let s:rapidpath=substitute(s:rapidpath,'\/usr\/include,','','g')
  if finddir('../../../RAPID')      !='' | let s:rapidpath.='../../../RAPID/**,'        | endif
  if finddir('../../../SYSPAR')     !='' | let s:rapidpath.='../../../SYSPAR/**,'       | endif
  if finddir('../../../HOME')       !='' | let s:rapidpath.='../../../HOME/**,'         | endif
  if finddir('../../../BACKINFO')   !='' | let s:rapidpath.='../../../BACKINFO/**,'     | endif
  if finddir('../../../CS')         !='' | let s:rapidpath.='../../../CS/**,'           | endif
  if finddir('../RAPID')            !='' | let s:rapidpath.='../RAPID/**,'              | endif
  if finddir('../SYSPAR')           !='' | let s:rapidpath.='../SYSPAR/**,'             | endif
  if finddir('../HOME')             !='' | let s:rapidpath.='../HOME/**,'               | endif
  if finddir('../BACKINFO')         !='' | let s:rapidpath.='../BACKINFO/**,'           | endif
  if finddir('../CS')               !='' | let s:rapidpath.='../CS/**,'                 | endif
  if finddir('./SYSPAR')            !='' | let s:rapidpath.='./SYSPAR/**,'              | endif " for .prg files

  execute "setlocal path=".s:rapidpath
  setlocal path-=/usr/include
  let b:undo_ftplugin = b:undo_ftplugin." pa<"

endif " get(g:,'rapidPath',1)

" complete
let s:pathList = s:KnopSplitAndUnescapeCommaSeparatedPathStr(&path)
let s:pathToCurrentFile = substitute(expand("%:p:h"),'\\','/','g')
"
" complete custom files
if exists('g:rapidCompleteCustom')
  for s:customCompleteAdditions in g:rapidCompleteCustom
    let s:file = substitute(s:customCompleteAdditions,'^.*[\\/]\(\w\+\.\)\(src\|sub\|dat\)$','\1\2','')
    call s:KnopAddFileToCompleteOption(s:customCompleteAdditions,s:pathList,s:pathToCurrentFile.'/'.s:file,)
  endfor
endif
"
" complete standard files
if get(g:,'rapidCompleteStd',1)
  "
  " EIO.cfg
  call s:KnopAddFileToCompleteOption('EIO.cfg',s:pathList,s:pathToCurrentFile.'/'.'EIO.cfg')
  " TASK0/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK0/SYSMOD/user.sys',s:pathList,s:pathToCurrentFile.'/'.'user.sys')
  " TASK1/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK1/SYSMOD/user.sys',s:pathList)
  " TASK2/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK2/SYSMOD/user.sys',s:pathList)
  " TASK3/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK3/SYSMOD/user.sys',s:pathList)
  " TASK4/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK4/SYSMOD/user.sys',s:pathList)
  " TASK5/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK5/SYSMOD/user.sys',s:pathList)
  " TASK6/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK6/SYSMOD/user.sys',s:pathList)
  " TASK7/SYSMOD/user.sys
  call s:KnopAddFileToCompleteOption('TASK7/SYSMOD/user.sys',s:pathList)
  "
  " syntax file
  let s:pathList=[]
  for s:i in split(&rtp,'\\\@1<!,')
    call add(s:pathList,substitute(s:i,'\\','/','g')) 
  endfor
  call s:KnopAddFileToCompleteOption('syntax/rapid.vim',s:pathList)
  if exists("g:knopCompleteMsg2")|unlet g:knopCompleteMsg2|endif
  "
  let b:undo_ftplugin = b:undo_ftplugin." cpt<"
endif " get(g:,'rapidCompleteStd',1)
unlet s:pathList
unlet s:pathToCurrentFile

" conceal structure values (for MoveJ * v2500,z100...)
if get(g:,'rapidConcealStructs',1)

  if !exists("*<SID>RapidConcealLevel")
    function <SID>RapidConcealLevel(lvl)
      " g:rapidConcealStructs may be used as input for a:lvl


      if a:lvl == 2
        " conceal all structure values
        setlocal conceallevel=2 concealcursor=nc
        return

      elseif a:lvl == 1
        " conceal less structure values
        setlocal conceallevel=2 concealcursor=
        return

      endif

        " conceal no structure values
      setlocal conceallevel=0 concealcursor=

    endfunction " <SID>RapidConcealLevel(lvl)

  endif " !exists("*<SID>RapidConcealLevel")

  call <SID>RapidConcealLevel(get(g:,'rapidConcealStructs',1))

  let b:undo_ftplugin = b:undo_ftplugin." cole< cocu<"

endif " get(g:,'rapidConcealStructs',1)

" }}} Vim Settings

" Endwise (tpope) {{{

" endwise support
if exists("loaded_endwise")
  if get(g:,'rapidEndwiseUpperCase',0)
    let b:endwise_addition  = '\=submatch(0)=~"CASE" ? "ENDTEST" : submatch(0)=~"IF" ? "ENDIF" : "END" . submatch(0)'
  else
    let b:endwise_addition  = '\=submatch(0)=~"case" ? "endtest" : submatch(0)=~"if" ? "endif" : "end" . submatch(0)'
  endif
  let b:endwise_words     = 'proc,func,trap,record,then,do,:'
  let b:endwise_pattern   = '^\s*\(local\s\+\)\?\zs\(proc\|func\|trap\|record\|if[^!]*\<then\|while\|for\|case\)\>\ze'
  let b:endwise_syngroups = 'rapidTypeDef,rapidRepeat,rapidConditional'
endif

" }}} Endwise

" Match It {{{

" matchit support
if exists("loaded_matchit") " depends on matchit (or matchup)
  let b:match_words = '^\s*\<if\>[^!]\+\<then\>.*:^\s*\<elseif\>[^!]\+\<then\>.*:^\s*\<else\>.*:^\s*\<endif\>.*,'
         \.'^\s*\<for\>[^!]\+\<do\>.*:^\s*\<endfor\>.*,'
         \.'^\s*\<while\>[^!]\+\<do\>.*:^\s*\<endwhile\>.*,'
         \.'^\s*\<test\>.*:^\s*\<case\>.*:^\s*\<default\>.*:^\s*\<endtest\>.*,'
         \.'^\s*\(global\s\+\|local\s\+\|task\s\+\)\?\<\(proc\|func\|trap\|record\)\>.*:\<raise\>:\<return\>:^\s*\<error\>.*:\<trynext\>:\<retry\>:^\s*\<undo\>.*:^\s*\<backward\>.*:^\s*\<end\(proc\|func\|trap\|record\)\>.*,'
         \.'^\s*\<module\>.*:^\s*\<endmodule\>.*'
  let b:match_ignorecase = 1 " Rapid does ignore case
endif

" }}} Match It

" Move Around and Function Text Object key mappings {{{

if get(g:,'rapidMoveAroundKeyMap',1)
  " Move around functions
  nnoremap <silent><buffer> [[ :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?(proc\|func\|trap\|record\|module)>', 'bs')        <Bar>unlet b:knopCount<CR>:normal! zt<CR>
  onoremap <silent><buffer> [[ :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?(proc\|func\|trap\|record\|module)>.*\n\zs', 'bsW')<Bar>unlet b:knopCount<CR>
  xnoremap <silent><buffer> [[ :<C-U>let b:knopCount=v:count1<Bar>exe "normal! gv"                                                                                                                                        <Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?(proc\|func\|trap\|record\|module)>', 'bsW')     <Bar>unlet b:knopCount<CR>
  nnoremap <silent><buffer> ]] :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?(proc\|func\|trap\|record\|module)>', 's')         <Bar>unlet b:knopCount<CR>:normal! zt<CR>
  onoremap <silent><buffer> ]] :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?(proc\|func\|trap\|record\|module)>', 'sW')        <Bar>unlet b:knopCount<CR>
  xnoremap <silent><buffer> ]] :<C-U>let b:knopCount=v:count1<Bar>exe "normal! gv"                                                                                                                                        <Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?(proc\|func\|trap\|record\|module)>.*\n', 'seWz')<Bar>unlet b:knopCount<CR>
  nnoremap <silent><buffer> [] :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>', 'bs')                                    <Bar>unlet b:knopCount<CR>:normal! zb<CR>
  onoremap <silent><buffer> [] :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>\n^(.\|\n)', 'bseW')                        <Bar>unlet b:knopCount<CR>
  xnoremap <silent><buffer> [] :<C-U>let b:knopCount=v:count1<Bar>exe "normal! gv"                                                                                                                                        <Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>', 'bsW')                                 <Bar>unlet b:knopCount<CR>
  nnoremap <silent><buffer> ][ :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>', 's')                                     <Bar>unlet b:knopCount<CR>:normal! zb<CR>
  onoremap <silent><buffer> ][ :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v\ze^\s*end(proc\|func\|trap\|record\|module)>', 'sW')                                 <Bar>unlet b:knopCount<CR>
  xnoremap <silent><buffer> ][ :<C-U>let b:knopCount=v:count1<Bar>exe "normal! gv"                                                                                                                                        <Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>(\n)?', 'seWz')                           <Bar>unlet b:knopCount<CR>
  " Move around comments
  nnoremap <silent><buffer> [; :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\v(^\s*!.*\n)@<!(^\s*!)', 'bs')<Bar>unlet b:knopCount<cr>
  onoremap <silent><buffer> [; :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\v(^\s*!.*\n)@<!(^\s*!)', 'bsW')<Bar>unlet b:knopCount<cr>
  xnoremap <silent><buffer> [; :<C-U>let b:knopCount=v:count1<Bar>exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\v(^\s*!.*\n)@<!(^\s*!)', 'bsW')<Bar>unlet b:knopCount<cr>
  nnoremap <silent><buffer> ]; :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\v^\s*!.*\n\s*([^!\t ]\|$)', 's')<Bar>unlet b:knopCount<cr>
  onoremap <silent><buffer> ]; :<C-U>let b:knopCount=v:count1<Bar>                     call <SID>KnopNTimesSearch(b:knopCount, '\v^\s*!.*\n(\s*[^!\t ]\|$)', 'seW')<Bar>normal! ==<Bar>unlet b:knopCount<cr>
  xnoremap <silent><buffer> ]; :<C-U>let b:knopCount=v:count1<Bar>exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\v^\s*!.*\n\ze\s*([^!\t ]\|$)', 'seW')<Bar>unlet b:knopCount<cr>
  " inner and around function text objects
  if get(g:,'rapidFunctionTextObject',0)
        \|| mapcheck("aF","x")=="" && !hasmapto('<plug>RapidTxtObjAroundFuncInclCo','x')
    xmap <silent><buffer> aF <plug>RapidTxtObjAroundFuncInclCo
  endif
  if get(g:,'rapidFunctionTextObject',0)
        \|| mapcheck("af","x")=="" && !hasmapto('<plug>RapidTxtObjAroundFuncExclCo','x')
    xmap <silent><buffer> af <plug>RapidTxtObjAroundFuncExclCo
  endif
  if get(g:,'rapidFunctionTextObject',0)
        \|| mapcheck("if","x")=="" && !hasmapto('<plug>RapidTxtObjInnerFunc','x')
    xmap <silent><buffer> if <plug>RapidTxtObjInnerFunc
  endif
  if get(g:,'rapidFunctionTextObject',0)
        \|| mapcheck("aF","o")=="" && !hasmapto('<plug>RapidTxtObjAroundFuncInclCo','o')
    omap <silent><buffer> aF <plug>RapidTxtObjAroundFuncInclCo
  endif
  if get(g:,'rapidFunctionTextObject',0)
        \|| mapcheck("af","o")=="" && !hasmapto('<plug>RapidTxtObjAroundFuncExclCo','o')
    omap <silent><buffer> af <plug>RapidTxtObjAroundFuncExclCo
  endif
  if get(g:,'rapidFunctionTextObject',0)
        \|| mapcheck("if","o")=="" && !hasmapto('<plug>RapidTxtObjInnerFunc','o')
    omap <silent><buffer> if <plug>RapidTxtObjInnerFunc
  endif
  " inner and around comment text objects
  if get(g:,'rapidCommentTextObject',0)
        \|| mapcheck("ac","x")=="" && !hasmapto('<plug>RapidTxtObjAroundComment','x')
    xmap <silent><buffer> ac <plug>RapidTxtObjAroundComment
  endif
  if get(g:,'rapidCommentTextObject',0)
        \|| mapcheck("ic","x")=="" && !hasmapto('<plug>RapidTxtObjInnerComment','x')
    xmap <silent><buffer> ic <plug>RapidTxtObjInnerComment
  endif
  if get(g:,'rapidCommentTextObject',0)
        \|| mapcheck("ac","o")=="" && !hasmapto('<plug>RapidTxtObjAroundComment','o')
    omap <silent><buffer> ac <plug>RapidTxtObjAroundComment
  endif
  if get(g:,'rapidCommentTextObject',0)
        \|| mapcheck("ic","o")=="" && !hasmapto('<plug>RapidTxtObjInnerComment','o')
    omap <silent><buffer> ic <plug>RapidTxtObjInnerComment
  endif
endif

" }}} Move Around and Function Text Object key mappings

" Other configurable key mappings {{{

" if the mapping does not exist and there is no plug-mapping just map it,
" otherwise look for the config variable

if get(g:,'rapidGoDefinitionKeyMap',1)
      \&& !hasmapto('<plug>RapidGoDef','n')
  " Go Definition; The condition is different because gd is a vim command
  nmap <silent><buffer> gd <plug>RapidGoDef
endif
if get(g:,'rapidListDefKeyMap',0)
      \|| mapcheck("<leader>f","n")=="" && !hasmapto('<plug>RapidListDef','n')
  " list all PROCs of current file
  nmap <silent><buffer> <leader>f <plug>RapidListDef
endif
if get(g:,'rapidListUsageKeyMap',0)
      \|| mapcheck("<leader>u","n")=="" && !hasmapto('<plug>RapidListUse','n')
  " list all uses of word under cursor
  nmap <silent><buffer> <leader>u <plug>RapidListUse
endif

if get(g:,'rapidAutoFormKeyMap',0)
      \|| mapcheck("<leader>n","n")=="" && !hasmapto('<plug>RapidAutoForm','n')
  nnoremap <silent><buffer> <leader>n    :call <SID>RapidAutoForm("   ")<cr>
  nnoremap <silent><buffer> <leader>nn   :call <SID>RapidAutoForm("   ")<cr>
  "
  nnoremap <silent><buffer> <leader>nl   :call <SID>RapidAutoForm("l  ")<cr>
  nnoremap <silent><buffer> <leader>nll  :call <SID>RapidAutoForm("l  ")<cr>
  "
  nnoremap <silent><buffer> <leader>nlp  :call <SID>RapidAutoForm("lp ")<cr>
  nnoremap <silent><buffer> <leader>nlt  :call <SID>RapidAutoForm("lt ")<cr>
  nnoremap <silent><buffer> <leader>nlr  :call <SID>RapidAutoForm("lr ")<cr>
  nnoremap <silent><buffer> <leader>nlf  :call <SID>RapidAutoForm("lf ")<cr>
  nnoremap <silent><buffer> <leader>nlfu :call <SID>RapidAutoForm("lf ")<cr>
  "
  nnoremap <silent><buffer> <leader>nlfb :call <SID>RapidAutoForm("lfb")<cr>
  nnoremap <silent><buffer> <leader>nlfn :call <SID>RapidAutoForm("lfn")<cr>
  nnoremap <silent><buffer> <leader>nlfd :call <SID>RapidAutoForm("lfd")<cr>
  nnoremap <silent><buffer> <leader>nlfs :call <SID>RapidAutoForm("lfs")<cr>
  nnoremap <silent><buffer> <leader>nlfp :call <SID>RapidAutoForm("lfp")<cr>
  nnoremap <silent><buffer> <leader>nlfr :call <SID>RapidAutoForm("lfr")<cr>
  nnoremap <silent><buffer> <leader>nlfj :call <SID>RapidAutoForm("lfj")<cr>
  nnoremap <silent><buffer> <leader>nlft :call <SID>RapidAutoForm("lft")<cr>
  nnoremap <silent><buffer> <leader>nlfw :call <SID>RapidAutoForm("lfw")<cr>
  "
  nnoremap <silent><buffer> <leader>np   :call <SID>RapidAutoForm("lp ")<cr>
  nnoremap <silent><buffer> <leader>nt   :call <SID>RapidAutoForm("lt ")<cr>
  nnoremap <silent><buffer> <leader>nr   :call <SID>RapidAutoForm("lr ")<cr>
  nnoremap <silent><buffer> <leader>nf   :call <SID>RapidAutoForm("lf ")<cr>
  nnoremap <silent><buffer> <leader>nfu  :call <SID>RapidAutoForm("lf ")<cr>
  "
  nnoremap <silent><buffer> <leader>nfb  :call <SID>RapidAutoForm("lfb")<cr>
  nnoremap <silent><buffer> <leader>nfn  :call <SID>RapidAutoForm("lfn")<cr>
  nnoremap <silent><buffer> <leader>nfd  :call <SID>RapidAutoForm("lfd")<cr>
  nnoremap <silent><buffer> <leader>nfs  :call <SID>RapidAutoForm("lfs")<cr>
  nnoremap <silent><buffer> <leader>nfp  :call <SID>RapidAutoForm("lfp")<cr>
  nnoremap <silent><buffer> <leader>nfr  :call <SID>RapidAutoForm("lfr")<cr>
  nnoremap <silent><buffer> <leader>nfj  :call <SID>RapidAutoForm("lfj")<cr>
  nnoremap <silent><buffer> <leader>nft  :call <SID>RapidAutoForm("lft")<cr>
  nnoremap <silent><buffer> <leader>nfw  :call <SID>RapidAutoForm("lfw")<cr>
  "
  nnoremap <silent><buffer> <leader>ng   :call <SID>RapidAutoForm("g  ")<cr>
  nnoremap <silent><buffer> <leader>ngg  :call <SID>RapidAutoForm("g  ")<cr>
  "
  nnoremap <silent><buffer> <leader>ngp  :call <SID>RapidAutoForm("gp ")<cr>
  nnoremap <silent><buffer> <leader>ngt  :call <SID>RapidAutoForm("gt ")<cr>
  nnoremap <silent><buffer> <leader>ngr  :call <SID>RapidAutoForm("gr ")<cr>
  nnoremap <silent><buffer> <leader>ngf  :call <SID>RapidAutoForm("gf ")<cr>
  nnoremap <silent><buffer> <leader>ngfu :call <SID>RapidAutoForm("gf ")<cr>
  "
  nnoremap <silent><buffer> <leader>ngfb :call <SID>RapidAutoForm("gfb")<cr>
  nnoremap <silent><buffer> <leader>ngfn :call <SID>RapidAutoForm("gfn")<cr>
  nnoremap <silent><buffer> <leader>ngfd :call <SID>RapidAutoForm("gfd")<cr>
  nnoremap <silent><buffer> <leader>ngfs :call <SID>RapidAutoForm("gfs")<cr>
  nnoremap <silent><buffer> <leader>ngfp :call <SID>RapidAutoForm("gfp")<cr>
  nnoremap <silent><buffer> <leader>ngfr :call <SID>RapidAutoForm("gfr")<cr>
  nnoremap <silent><buffer> <leader>ngfj :call <SID>RapidAutoForm("gfj")<cr>
  nnoremap <silent><buffer> <leader>ngft :call <SID>RapidAutoForm("gft")<cr>
  nnoremap <silent><buffer> <leader>ngfw :call <SID>RapidAutoForm("gfw")<cr>
endif " g:rapidAutoFormKeyMap

if get(g:,'rapidConcealStructKeyMap',0)
        \|| mapcheck("<F2>","n")=="" && mapcheck("<F3>","n")=="" && mapcheck("<F4>","n")==""
        \&& !hasmapto('<plug>RapidConcealStructs','n') && !hasmapto('<plug>RapidShowStructsAtCursor','n') && !hasmapto('<plug>RapidShowStructs','n')
        \&& !exists("g:rapidConcealStructsKeyMap")
  " conceal all structure values
  nmap <silent><buffer> <F4> <plug>RapidConcealStructs
  " conceal less structure values
  nmap <silent><buffer> <F3> <plug>RapidShowStructsAtCursor
  " conceal no structure values
  nmap <silent><buffer> <F2> <plug>RapidShowStructs
elseif get(g:,'rapidConcealStructsKeyMap',0)
  " deprecated
  " compatiblity
  nmap <silent><buffer> <F3> <plug>RapidShowStructs
  nmap <silent><buffer> <F2> <plug>RapidConcealStructs
endif

" }}} Configurable mappings

" <PLUG> mappings {{{

" Go Definition
nnoremap <silent><buffer> <plug>RapidGoDef :call <SID>RapidGoDefinition()<CR>:call <SID>RapidCleanBufferList()<CR>

" list all PROCs of current file
nnoremap <silent><buffer> <plug>RapidListDef :call <SID>RapidListDefinition()<CR>:call <SID>RapidCleanBufferList()<CR>

" list usage
nnoremap <silent><buffer> <plug>RapidListUse :call <SID>RapidListUsage()<CR>:call <SID>RapidCleanBufferList()<CR>

" auto form
nnoremap <silent><buffer> <plug>RapidAutoForm                 :call <SID>RapidAutoForm("   ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalProc        :call <SID>RapidAutoForm("lp ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalTrap        :call <SID>RapidAutoForm("lt ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalRecord      :call <SID>RapidAutoForm("lr ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFunc        :call <SID>RapidAutoForm("lf ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncBool    :call <SID>RapidAutoForm("lfb")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncNum     :call <SID>RapidAutoForm("lfn")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncDNum    :call <SID>RapidAutoForm("lfd")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncString  :call <SID>RapidAutoForm("lfs")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncPose    :call <SID>RapidAutoForm("lfp")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncRobt    :call <SID>RapidAutoForm("lfr")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncJointt  :call <SID>RapidAutoForm("lfj")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncToold   :call <SID>RapidAutoForm("lft")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormLocalFuncWobj    :call <SID>RapidAutoForm("lfw")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalProc       :call <SID>RapidAutoForm("gp ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalTrap       :call <SID>RapidAutoForm("gt ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalRecord     :call <SID>RapidAutoForm("gr ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFunc       :call <SID>RapidAutoForm("gf ")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncBool   :call <SID>RapidAutoForm("gfb")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncNum    :call <SID>RapidAutoForm("gfn")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncDNum   :call <SID>RapidAutoForm("gfd")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncString :call <SID>RapidAutoForm("gfs")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncPose   :call <SID>RapidAutoForm("gfp")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncRobt   :call <SID>RapidAutoForm("gfr")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncJointt :call <SID>RapidAutoForm("gfj")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncToold  :call <SID>RapidAutoForm("gft")<cr>
nnoremap <silent><buffer> <plug>RapidAutoFormGlobalFuncWobj   :call <SID>RapidAutoForm("gfw")<cr>
" auto form end

" Function Text Object
if get(g:,'rapidMoveAroundKeyMap',1) " depends on move around key mappings
  xnoremap <silent><buffer> <plug>RapidTxtObjAroundFuncInclCo :<C-U>call <SID>RapidFunctionTextObject(0,1)<CR>
  xnoremap <silent><buffer> <plug>RapidTxtObjAroundFuncExclCo :<C-U>call <SID>RapidFunctionTextObject(0,0)<CR>
  xnoremap <silent><buffer> <plug>RapidTxtObjInnerFunc        :<C-U>call <SID>RapidFunctionTextObject(1,0)<CR>
  onoremap <silent><buffer> <plug>RapidTxtObjAroundFuncInclCo :<C-U>call <SID>RapidFunctionTextObject(0,1)<CR>
  onoremap <silent><buffer> <plug>RapidTxtObjAroundFuncExclCo :<C-U>call <SID>RapidFunctionTextObject(0,0)<CR>
  onoremap <silent><buffer> <plug>RapidTxtObjInnerFunc        :<C-U>call <SID>RapidFunctionTextObject(1,0)<CR>
endif

" comment text objects
if get(g:,'rapidMoveAroundKeyMap',1) " depends on move around key mappings
  xnoremap <silent><buffer> <plug>RapidTxtObjAroundComment     :<C-U>call <SID>RapidCommentTextObject(1)<CR>
  xnoremap <silent><buffer> <plug>RapidTxtObjInnerComment      :<C-U>call <SID>RapidCommentTextObject(0)<CR>
  onoremap <silent><buffer> <plug>RapidTxtObjAroundComment     :<C-U>call <SID>RapidCommentTextObject(1)<CR>
  onoremap <silent><buffer> <plug>RapidTxtObjInnerComment      :<C-U>call <SID>RapidCommentTextObject(0)<CR>
endif

" conceal all structure values
nnoremap <silent><buffer> <plug>RapidConcealStructs       :call <SID>RapidConcealLevel(2)<CR>
nnoremap <silent><buffer> <plug>RapidShowStructsAtCursor  :call <SID>RapidConcealLevel(1)<CR>
nnoremap <silent><buffer> <plug>RapidShowStructs          :call <SID>RapidConcealLevel(0)<CR>

" }}} <plug> mappings

" Finish {{{
let &cpo = s:keepcpo
unlet s:keepcpo
" }}} Finish

" vim:sw=2 sts=2 et fdm=marker
