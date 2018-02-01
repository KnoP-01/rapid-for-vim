" ABB Rapid Command file type plugin for Vim
" Language: ABB Rapid Command
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 1.0.0
" Last Change: 01. Jan 2018
" Credits: Peter Oddings (KnopUniqueListItems/xolox#misc#list#unique)
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

" compatiblity
if exists("g:rapidNoVerbose")
  let g:knopNoVerbose=g:rapidNoVerbose
  unlet g:rapidNoVerbose
endif
if exists("g:rapidRhsQuickfix")
  let g:knopRhsQuickfix = g:rapidRhsQuickfix
  unlet g:rapidRhsQuickfix
endif
if exists("g:rapidLhsQuickfix")
  let g:knopLhsQuickfix = g:rapidLhsQuickfix
  unlet g:rapidLhsQuickfix
endif

" }}} init
" only declare functions once
if !exists("*s:KnopVerboseEcho()")
  " Little Helper {{{

  if !exists("g:knopNoVerbose") || g:knopNoVerbose!=1
    let g:knopVerboseMsgSet = 1
  endif
  function s:KnopVerboseEcho(msg)
    if !exists("g:knopNoVerbose") || g:knopNoVerbose!=1
      if exists('g:knopVerboseMsgSet')
        unlet g:knopVerboseMsgSet
        echo "\nSwitch verbose messages off with \":let g:knopNoVerbose=1\" any time. You may put this in your .vimrc"
        echo " "
      endif
      echo a:msg
    endif
  endfunction " s:knopNoVerbose()

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
    let l:path = substitute(a:path,'$',' ','') " make sure that space is the last char
    let l:path = substitute(l:path,',',' ','g') " literal commas in a:path do not work
    let l:path = substitute(l:path, '\*\* ', '**/'.a:file.' ', 'g')
    let l:path = substitute(l:path, '\.\. ', '../'.a:file.' ', 'g')
    let l:path = substitute(l:path, '\. ',    './'.a:file.' ', 'g')
    let l:path = substitute(l:path, '[\\/] ',  '/'.a:file.' ', 'g')
    return l:path
  endfunction " s:KnopPreparePath()

  function s:KnopQfCompatible()
    " check for qf.vim compatiblity
    if exists('g:loaded_qf') && (!exists('g:qf_window_bottom') || g:qf_window_bottom!=0)
          \&& (exists("g:knopRhsQuickfix") && g:knopRhsQuickfix==1 
          \|| exists("g:knopLhsQuickfix") && g:knopLhsQuickfix==1)
      call s:KnopVerboseEcho("NOTE: \nIf you use qf.vim then g:krlRhsQuickfix, g:krlLhsQuickfix, g:rapidRhsQuickfix and g:rapidLhsQuickfix will not work unless g:qf_window_bottom is 0 (Zero). \nTo use g:<foo>[RL]hsQuickfix put this in your .vimrc: \n  let g:qf_window_bottom = 0\n\n")
      return 0
    endif
    return 1
  endfunction " s:KnopQfCompatible()

  let g:knopPositionQf=1
  function s:KnopOpenQf(ft)
    if getqflist()==[] | return -1 | endif
    cwindow 4
    if getbufvar('%', "&buftype")!="quickfix"
      let l:getback=1
      " noautocmd copen
      copen
    endif
    augroup KnopOpenQf
      au!
      " reposition after closing
      let l:cmd = 'au BufWinLeave <buffer='.bufnr('%').'> let g:knopPositionQf=1'
      execute l:cmd
    augroup END
    if a:ft!='' | let &filetype=a:ft | endif
    if exists('g:knopPositionQf') && s:KnopQfCompatible() 
      unlet g:knopPositionQf
      if exists("g:knopRhsQuickfix") && g:knopRhsQuickfix==1
        wincmd L
      elseif exists("g:knopLhsQuickfix") && g:knopLhsQuickfix==1 
        wincmd H
      endif
    endif
    if exists("l:getback")
      unlet l:getback
      wincmd p
    endif
    return 0
  endfunction " s:KnopOpenQf()

  function s:KnopSearchPathForPatternNTimes(Pattern,path,n,ft)
    let l:cmd = ':noautocmd ' . a:n . 'vimgrep /' . a:Pattern . '/j ' . a:path
    try
      execute l:cmd
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
    if s:KnopOpenQf(a:ft)==-1
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
            \|| synIDattr(synID(line("."),col("."),0),"name")==""
            \)
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

  " }}} Rapid Helper
  " Go Definition {{{

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
            call s:KnopVerboseEcho("Found FOR loop local auto declaration")
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
      call cursor(l:numProcStart,1)
      let l:noneCloseParen = '([^)]|\n)*'
      if search('\c\v^'.l:noneCloseParen.'\('.l:noneCloseParen.'\w(\s|\n)*\zs<'.a:currentWord.'>'.l:noneCloseParen.'\)','cW',line("."))
        call s:KnopVerboseEcho("Found VARIABLE declaration in ARGUMENT list")
        return 0
        "
      endif " search Proc/Func/Trap argument declaration
      "
      " search Proc/Func/Trap local declaration
      call cursor(l:numProcStart,1)
      if search(a:declPrefix.'\zs'.a:currentWord.'>','W',l:numProcEnd)
        call s:KnopVerboseEcho("Found PROC, FUNC or TRAP local VARIABLE declaration")
        return 0
        "
      endif
    endif " search inside Proc/Func/Trap for local declaration
    "
    " search Module local variable declaration
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
        call s:KnopVerboseEcho("Found VARIABLE declaration in this MODULE")
        return 0
        "
      endif
    endwhile " search Module local variable declaration
    " 
    " search Module local proc (et al) declaration
    let l:numEndmodule=s:RapidPutCursorOnModuleAndReturnEndmoduleline()
    if search('\v\c^\s*((local|global|task)\s+)?(proc|func\s+\w+|trap|record)\s+\zs'.a:currentWord.'>','cW',l:numEndmodule)
      call s:KnopVerboseEcho("Found declaration of PROC, FUNC, TRAP or RECORD in this MODULE")
      return 0
      "
    endif " search Module local proc (et al) declaration
    "
    " nothing found in current module, put cursor back where search started
    call cursor(l:numSearchStartLine,l:numSearchStartColumn)
    "
    " search global declaration
    for l:i in ['task', 'system']
      "
      " first fill location list with all (end)?(proc|func|trap|record) and variable
      " declarations with currentWord
      let l:prefix = '/\c\v^\s*(local\s+|task\s+|global\s+)?((var|pers|const)\s+\w+\s+'
      let l:suffix = '>|(end)?(proc|func|trap|record)>)/j' " since this finds all (not only global) ends, the previous must also list local
      if l:i =~ 'task'
        if has("win32")
          let l:path = './*.prg '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.sys'
        else
          let l:path = './*.prg ./*.Prg ./*.PRG '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.Mod '.fnameescape(expand("%:p:h")).'/../PROGMOD/*.MOD '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.sys '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.Sys '.fnameescape(expand("%:p:h")).'/../SYSMOD/*.SYS '
        endif
      elseif l:i =~ 'system'
        if has("win32")
          let l:path = './*.prg '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.sys'
        else
          let l:path = './*.prg ./*.Prg ./*.PRG '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.mod '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.Mod '.fnameescape(expand("%:p:h")).'/../../TASK*/PROGMOD/*.MOD '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.sys '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.Sys '.fnameescape(expand("%:p:h")).'/../../TASK*/SYSMOD/*.SYS '
        endif
      endif
      let l:cmd = ':noautocmd lvimgrep '.l:prefix.a:currentWord.l:suffix.' '.l:path
      try
        execute l:cmd
      catch /^Vim\%((\a\+)\)\=:E480/
        call s:KnopVerboseEcho(":lvimgrep stopped with E480!")
        return -1
        "
      catch /^Vim\%((\a\+)\)\=:E683/
        call s:KnopVerboseEcho(":lvimgrep stopped with E683!")
        return -1
        "
      endtry
      "
      " search for global proc in loclist
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
            call s:KnopVerboseEcho("Found declaration of PROC, FUNC, TRAP or RECORD in this TASK")
          elseif l:i =~ 'system'
            call s:KnopVerboseEcho("Found declaration of PROC, FUNC, TRAP or RECORD in SYSTEM (other task)")
          endif
          call s:KnopOpenQf('rapid')
          return 0
          "
        endif
      endfor
      "
      " then search for global variable in loc list
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
              call s:KnopVerboseEcho("Found VARIABLE declaration in this TASK")
            elseif l:i =~ 'system'
              call s:KnopVerboseEcho("Found VARIABLE declaration in SYSTEM (other task)")
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
    elseif filereadable('./../../../SYSPAR/EIO.cfg')
      let l:path = './../../../SYSPAR/EIO.cfg'
    elseif filereadable('./../../../SYSPAR/EIO.Cfg')
      let l:path = './../../../SYSPAR/EIO.Cfg'
    elseif filereadable('./../../../SYSPAR/EIO.CFG')
      let l:path = './../../../SYSPAR/EIO.CFG'
    else
      call s:KnopVerboseEcho("No EIO.cfg found!")
      return -1
      "
    endif
    let l:strPattern = '\c\v^\s*-name\s+"'.a:currentWord.'>'
    let l:searchResult = s:KnopSearchPathForPatternNTimes(l:strPattern,l:path,1,"rapid")
    if l:searchResult == 0
      call s:KnopVerboseEcho("Found signal(?) in EIO.cfg. The quickfix window will open. See :he quickfix-window")
      return 0
      "
    endif
    "
    return -1
  endfunction " s:RapidSearchUserDefined()

  function <SID>RapidGoDefinition()
    "
    " dont start from within qf or loc window
    if getbufvar('%', "&buftype") == "quickfix" | return | endif
    let l:declPrefix = '\c\v^\s*(local\s+|task\s+|global\s+)?(var|pers|const)\s+\w+\s+'
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
        let l:currentWord = substitute(l:currentWord,'\v^(sys)?func','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a FUNCTION. Start search..."])
        return s:RapidSearchUserDefined(l:declPrefix,l:currentWord)
        "
      elseif l:currentWord =~ '^num.*'
        let l:currentWord = substitute(l:currentWord,'^num','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a NUMBER. No search performed."])
      elseif l:currentWord =~ '^bool.*'
        let l:currentWord = substitute(l:currentWord,'^bool','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a BOOLEAN VALUE. No search performed."])
      elseif l:currentWord =~ '^string.*'
        let l:currentWord = substitute(l:currentWord,'^string','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a STRING. No search performed."])
      elseif l:currentWord =~ '^comment.*'
        let l:currentWord = substitute(l:currentWord,'^comment','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a COMMENT. No search performed."])
      elseif l:currentWord =~ '^inst.*'
        let l:currentWord = substitute(l:currentWord,'^inst','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a Rapid KEYWORD. No search performed."])
      else
        let l:currentWord = substitute(l:currentWord,'^none','','')
        call s:KnopVerboseEcho([l:currentWord,"Could not determine typ of current word. No search performed."])
      endif
      return -1
      "
    endif
    "
    call s:KnopVerboseEcho("Nothing found at or after current cursor pos, which could have a declaration. No search performed.")
    return -1
    "
  endfunction " <SID>RapidGoDefinition()

  " }}} Go Definition
  " Auto Form {{{

  function s:RapidGetGlobal(sAction)
    if a:sAction=~'^[gl]'
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

  function s:RapidPositionForEdit()
    let l:commentline = '^\s*!'
    " empty file
    if line('$')==1 && getline('.')=='' | return | endif
    " proc, func, trap or record
    if search('\v\c^\s*(local\s+)?(proc|func|trap|record|endmodule)>','csW')
      let l:prevline = getline(line('.')-1)
      while l:prevline=~l:commentline
        normal! k
        let l:prevline = getline(line('.')-1)
      endwhile
      normal! O
      normal! O
      if getline(line('.')-1) != ''
        normal! o
      endif
    elseif search('\v\c^\s*endmodule>','csW')
      normal! O
      if getline(line('.')-1) != ''
        normal! o
      endif
    else
      normal! G
      if getline('.') != ''
        normal! o
      endif
      if getline(line('.')-1) != ''
        normal! o
      endif
    endif
  endfunction " s:RapidPositionForEdit()

  function s:RapidPositionForRead()
    call s:RapidPositionForEdit()
    if getline('.')=~'^\s*$'
          \&& line('.')!=line('$')
      delete
    endif
  endfunction " s:RapidPositionForRead()

  function s:RapidReadBody(sBodyFile,sType,sName,sGlobal,sDataType,sReturnVar)
    let l:sBodyFile = glob(fnameescape(g:rapidPathToBodyFiles)).a:sBodyFile
    if !filereadable(glob(l:sBodyFile))
      call s:KnopVerboseEcho([l:sBodyFile,": Body file not readable."])
      return
    endif
    " read body
    call s:RapidPositionForRead()
    let l:cmd = "silent .-1read ".glob(l:sBodyFile)
    execute l:cmd
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
        let l:cmd = "silent normal! " . (l:end-l:start+1) . "=="
        execute l:cmd
      endif
    endif
    " position cursor
    call cursor(l:start,0)
    if search('<|>','cW',l:end)
      call setline('.',substitute(getline('.'),'<|>','','g'))
    endif
  endfunction " s:RapidReadBody()

  function s:RapidDefaultBody(sType,sName,sGlobal,sDataType,sReturnVar)
    call s:RapidPositionForEdit()
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
        let l:cmd = "silent normal! " . (l:end-l:start+1) . "=="
        execute l:cmd
      endif
    endif
    call search('^\s*!','eW',l:end)
  endfunction " s:RapidDefaultBody()

  function <SID>RapidAutoForm(sAction)
    " check input
    if a:sAction !~ '^[ gl][ pftr][ bndsprjtw]$' | return | endif
    if getbufvar('%', "&buftype") == "quickfix" | return | endif
    "
    " get global/local
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
    else
      call s:RapidDefaultBody(l:sType,l:sName,l:sGlobal,l:sDataType,l:sReturnVar)
    endif
    "
    normal! zz
    silent doautocmd User RapidAutoFormPost
    "
  endfunction " <SID>RapidAutoForm()

  " }}} Auto Form 
  " List Def/Usage {{{ 

  function <SID>RapidListDef()
    " dont start from within qf or loc window
    if getbufvar('%', "&buftype")=="quickfix" | return | endif
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
      %substitute/\v\c^.*\|\s*((global\s+|task\s+|local\s+)?(proc|func|trap|record|module)>)/\1/
      0
      if !exists("g:rapidTmpFile")
        let g:rapidTmpFile=tempname()
        augroup rapidDelTmpFile
          au!
          au VimLeavePre * call delete(g:rapidTmpFile)
        augroup END
      endif
      execute 'silent save! ' . g:rapidTmpFile
      setlocal nomodifiable
      if exists("l:getback")
        unlet l:getback
        wincmd p
      endif
    endif
  endfunction " <SID>RapidListDef()

  function <SID>RapidListUsage()
    " dont start from within qf or loc window
    if getbufvar('%', "&buftype")=="quickfix" | return | endif
    "
    if search('\w','cW',line("."))
      let l:currentWord = s:RapidCurrentWordIs()
      if l:currentWord =~ '^userdefined.*'
        let l:currentWord = substitute(l:currentWord,'^userdefined','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be userdefined. Start search..."])
      elseif l:currentWord =~ '\v^(sys)?func.*'
        let l:currentWord = substitute(l:currentWord,'\v^(sys)?func','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a FUNCTION. Start search..."])
      elseif l:currentWord =~ '^num.*'
        let l:currentWord = substitute(l:currentWord,'^num','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a NUMBER. Start search..."])
      elseif l:currentWord =~ '^bool.*'
        let l:currentWord = substitute(l:currentWord,'^bool','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a BOOLEAN VALUE. Start search..."])
      elseif l:currentWord =~ '^string.*'
        let l:currentWord = substitute(l:currentWord,'^string','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a STRING. Start search..."])
      elseif l:currentWord =~ '^comment.*'
        let l:currentWord = substitute(l:currentWord,'^comment','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a COMMENT. Start search..."])
      elseif l:currentWord =~ '^inst.*'
        let l:currentWord = substitute(l:currentWord,'^inst','','')
        call s:KnopVerboseEcho([l:currentWord,"appear to be a Rapid KEYWORD. Start search..."])
      else
        let l:currentWord = substitute(l:currentWord,'^none','','')
        call s:KnopVerboseEcho([l:currentWord,"Could not determine typ of current word. No search performed."])
        return
        "
      endif
      if s:KnopSearchPathForPatternNTimes('\c\v^[^!]*<'.l:currentWord.'>',s:KnopPreparePath(&path,'*'),'','rapid')==0
        call setqflist(s:KnopUniqueListItems(getqflist()))
        " rule out if l:currentWord is part of a strings except in *.cfg files
        let l:qfresult = []
        for l:i in getqflist()
          if get(l:i,'text') =~ '\v\c^([^"]*"[^"]*"[^"]*)*[^"]*<'.l:currentWord.'>'
                \|| bufname(get(l:i,'bufnr')) =~ '\v\c\w+\.cfg$'
            call add(l:qfresult,l:i)
          endif
        endfor
        call setqflist(l:qfresult)
        call s:KnopOpenQf('rapid')
      endif
    else
      call s:KnopVerboseEcho("Nothing found at or after current cursor pos, which could have a declaration. No search performed.")
    endif
  endfunction " <SID>RapidListUsage()

  " }}} List Def/Usage 
  " Format Comments {{{ 

  " TODO decide: abandon this one?
  if exists("g:rapidFormatComments") && g:rapidFormatComments==1
    function <SID>RapidFormatComments()
      "
      normal! m'
      0
      let l:numCurrLine = 1
      let l:numLastLine = (line("$") - 1)
      "
      while l:numCurrLine >= 0 && l:numCurrLine <= l:numLastLine
        if getline(l:numCurrLine) =~ '^\s*!'
          let l:numNextNoneCommentLine = search('^\s*[^ \t!]',"nW")
          if l:numNextNoneCommentLine == 0
            normal! gqG
          elseif l:numNextNoneCommentLine-l:numCurrLine <= 1
            normal! gqq
          else
            execute "normal!" (l:numNextNoneCommentLine-l:numCurrLine-1)."gqj"
          endif
        endif
        " check next line
        let l:searchnextcomment = search('^\s*!',"W")
        if l:searchnextcomment == 0
          normal! G
        endif
        let l:numCurrLine = line(".")
        let l:numLastLine = (line("$") - 1)
      endwhile
      "
    endfunction " <SID>RapidFormatComments()
  endif

  " }}} Format Comments 
  " Funktion Text Object {{{

  if exists("g:rapidMoveAroundKeyMap") && g:rapidMoveAroundKeyMap==1 " depends on move around key mappings
    function s:RapidFunctionTextObject(inner,withcomment)
      if a:inner==1
        let l:n = 1
      else
        let l:n = v:count1
      endif
      if getline('.')!~'\v\c^\s*end(proc|func|trap|record|module)?>'
        silent normal ][
      endif
      silent normal [[
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

  " }}} Funktion Text Object
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
if exists("g:rapidAutoComment") && g:rapidAutoComment==1
  setlocal formatoptions+=r
  setlocal formatoptions+=o
  let b:undo_ftplugin = b:undo_ftplugin." fo<"
endif

" format comments
if exists("g:rapidFormatComments") && g:rapidFormatComments==1
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
endif

" set vims path
if !exists("g:rapidNoPath") || g:rapidNoPath!=1
  let s:rapidpath=&path.'./**,'
  let s:rapidpath=substitute(s:rapidpath,'\/usr\/include,','','g')
  " if finddir('../PROGMOD')         !='' | let s:rapidpath.='../PROGMOD/**,'           | endif
  " if finddir('../SYSMOD')          !='' | let s:rapidpath.='../SYSMOD/**,'            | endif
  if finddir('../../../RAPID')     !='' | let s:rapidpath.='../../../RAPID/TASK*/**,'       | endif
  if finddir('../../../SYSPAR')    !='' | let s:rapidpath.='../../../SYSPAR/**,'      | endif
  if finddir('../../../HOME')      !='' | let s:rapidpath.='../../../HOME/**,'        | endif
  if finddir('../../../BACKINFO')  !='' | let s:rapidpath.='../../../BACKINFO/**,'    | endif
  if finddir('../RAPID')           !='' | let s:rapidpath.='../RAPID/TASK*/**,'             | endif
  if finddir('../SYSPAR')          !='' | let s:rapidpath.='../SYSPAR/**,'            | endif
  if finddir('../HOME')            !='' | let s:rapidpath.='../HOME/**,'              | endif
  if finddir('../BACKINFO')        !='' | let s:rapidpath.='../BACKINFO/**,'          | endif
  if finddir('./SYSPAR')           !='' | let s:rapidpath.='./SYSPAR/**,'             | endif
  execute "setlocal path=".s:rapidpath
  let b:undo_ftplugin = b:undo_ftplugin." pa<"
endif

" conceal structure values (for MoveJ * v2500,z100...)
if exists("g:rapidConcealStructs") && g:rapidConcealStructs==1
      \&& getbufvar('%', "&buftype")!="quickfix" 
  setlocal conceallevel=2
  let b:undo_ftplugin = b:undo_ftplugin." cole<"
endif

" }}} Vim Settings 
" Match It % {{{ 

" matchit support
if exists("loaded_matchit")
  let b:match_words = '^\s*\<if\>\s[^!]\+\<then\>:^\s*\<elseif\>:^\s*\<else\>:^\s*\<endif\>,'
         \.'^\s*\<for\>:^\s*\<endfor\>,'
         \.'^\s*\<while\>:^\s*\<endwhile\>,'
         \.'^\s*\<test\>:^\s*\<case\>:^\s*\<default\>:^\s*\<endtest\>,'
         \.'^\s*\(global\s\+\|local\s\+\|task\s\+\)\?\<\(proc\|func\|trap\|record\)\>:\<raise\>:\<return\>:^\s*\<error\>:\<trynext\>:\<retry\>:^\s*\<undo\>:^\s*\<backward\>:^\s*\<end\(proc\|func\|trap\|record\)\>,'
         \.'^\s*\<module\>:^\s*\<endmodule\>'
  let b:match_ignorecase = 1 " Rapid does ignore case
endif

" }}} Match It
" Move Around and Function Text Object key mappings {{{ 

if exists("g:rapidMoveAroundKeyMap") && g:rapidMoveAroundKeyMap>=1
  " Move around functions
  nnoremap <silent><buffer> [[ :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?<(proc\|func\|trap\|record\|module)>', 'bs')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> [[ :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?<(proc\|func\|trap\|record\|module)>', 'bsW')<Bar>:unlet b:knopCount<CR>
  nnoremap <silent><buffer> ]] :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?<(proc\|func\|trap\|record\|module)>', 's')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> ]] :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*(global\s+\|local\s+\|task\s+)?<(proc\|func\|trap\|record\|module)>', 'sW')<Bar>:unlet b:knopCount<CR>
  nnoremap <silent><buffer> [] :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>', 'bse')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> [] :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>', 'bseW')<Bar>:unlet b:knopCount<CR>
  nnoremap <silent><buffer> ][ :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>', 'se')<Bar>:unlet b:knopCount<CR>
  vnoremap <silent><buffer> ][ :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\c\v^\s*end(proc\|func\|trap\|record\|module)>', 'seW')<Bar>:unlet b:knopCount<CR>
  " Move around comments
  nnoremap <silent><buffer> [! :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '^\(\s*!.*\n\)\@<!\(\s*!\)', 'bs')<Bar>:unlet b:knopCount<cr>
  vnoremap <silent><buffer> [! :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '^\(\s*!.*\n\)\@<!\(\s*!\)', 'bsW')<Bar>:unlet b:knopCount<cr>
  nnoremap <silent><buffer> ]! :<C-U>let b:knopCount=v:count1<Bar>:                     call <SID>KnopNTimesSearch(b:knopCount, '\v^\s*!.*\ze\n\s*([^!\t ]\|$)', 'se')<Bar>:unlet b:knopCount<cr>
  vnoremap <silent><buffer> ]! :<C-U>let b:knopCount=v:count1<Bar>:exe "normal! gv"<Bar>call <SID>KnopNTimesSearch(b:knopCount, '\v^\s*!.*\ze\n\s*([^!\t ]\|$)', 'seW')<Bar>:unlet b:knopCount<cr>
  if g:rapidMoveAroundKeyMap==2
    " inner and around function text objects
    vnoremap <silent><buffer> aF :<C-U>call <SID>RapidFunctionTextObject(0,1)<CR>
    vnoremap <silent><buffer> af :<C-U>call <SID>RapidFunctionTextObject(0,0)<CR>
    vnoremap <silent><buffer> if :<C-U>call <SID>RapidFunctionTextObject(1,0)<CR>
    omap <silent><buffer> aF :normal VaF<CR>
    omap <silent><buffer> af :normal Vaf<CR>
    omap <silent><buffer> if :normal Vif<CR>
  endif
endif

" }}} Move Around and Function Text Object key mappings
" Other configurable key mappings {{{ 

if exists("g:rapidGoDefinitionKeyMap") && g:rapidGoDefinitionKeyMap==1
  " gd mimic
  nnoremap <silent><buffer> gd :call <SID>RapidGoDefinition()<CR>
endif
if exists("g:rapidListDefKeyMap") && g:rapidListDefKeyMap==1
  " list all PROCs of current file
  nnoremap <silent><buffer> <leader>f :call <SID>RapidListDef()<CR>
endif
if exists("g:rapidListUsageKeyMap") && g:rapidListUsageKeyMap==1
  " list all uses of word under cursor
  nnoremap <silent><buffer> <leader>u :call <SID>RapidListUsage()<CR>
endif
if exists("g:rapidConcealStructsKeyMap") && g:rapidConcealStructsKeyMap==1
  " conceal struct values, usefull for * robtargets
  nnoremap <silent><buffer> <F2> :setlocal conceallevel=2<CR>
  nnoremap <silent><buffer> <F3> :setlocal conceallevel=0<CR>
endif

if exists("g:rapidAutoFormKeyMap") && g:rapidAutoFormKeyMap==1
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

" }}} Configurable mappings
" <PLUG> mappings {{{ 

" gd mimic 
nnoremap <silent><buffer> <plug>RapidGoDef :call <SID>RapidGoDefinition()<CR>

" list all PROCs of current file
nnoremap <silent><buffer> <plug>RapidListDef :call <SID>RapidListDef()<CR>

" list usage
nnoremap <silent><buffer> <plug>RapidListUse :call <SID>RapidListUsage()<cr>

" conceal struct values
nnoremap <silent><buffer> <plug>RapidConcealStructs :setlocal conceallevel=2<CR>
nnoremap <silent><buffer> <plug>RapidShowStructs    :setlocal conceallevel=0<CR>

" format comments
nnoremap <silent><buffer> <plug>RapidFormatComments :call <SID>RapidFormatComments()<CR>

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

" }}} <plug> mappings
" Finish {{{ 

let &cpo = s:keepcpo
unlet s:keepcpo

" }}} Finish
" vim:sw=2 sts=2 et fdm=marker
