# rapid-for-vim

## Introduction:

Have a look at [tl:dr][2] to get a very quick overview over the most important
options provided by Rapid for Vim. For more details see the [help][3] file.

Rapid for Vim (7.4 or later) is a collection of Vim scripts to help programing
ABB industrial robots. 

It provides

* syntax highlighting, 
* auto indention,
* concealing of structure values (e.g. MoveJ \* v2500...),
* mappings and settings to navigate through code in a backup folder structure
  and 
* mappings to insert a body of a new PROC, FUNC, TRAP et al based on user
  defined templates or hopefully sane defaults. 

Most of this is optional, though some things are default on. Have a look in
the [rapid-options][6] section in the help for more details.

**Note:** Keep your files to be edited in one folder or in a regular robot
backup folder structure. Rapid for Vim modifies 'path' by default accordingly.

## Installation:

Extract the most recent [release][1] and copy the folders 
`/doc`, `/ftdetect`, `/ftplugin`, `/indent` and `/syntax` 
into your `~/.vim/` or `%USERPROFILE%\vimfiles\` directory. 
Overwrite rapid.\* files from older installation. 

To fully use these scripts put >

    filetype plugin indent on
    syntax on

in your .vimrc

You may have to run >

    :helptags ~/.vim/doc/

or >

    :helptags ~/vimfiles/doc/

to use the help within Vim after installation. >

    :help rapid

Or just open the file .../doc/rapid.txt

## Content description

    ~/.vim/doc/rapid.txt
    ~/.vim/ftdetect/rapid.vim
    ~/.vim/ftplugin/rapid.vim
    ~/.vim/indent/rapid.vim
    ~/.vim/syntax/rapid.vim

You may use all these independently from one another. Just don't mix versions
of different releases. Some features may work better when all files are loaded.

#### ~/.vim/doc/rapid.txt
Help file. This should help you to use these plugins to your best advantage.
You may want to look into the [help][3] prior to installation.  
Requires >

    :helptags ~/.vim/doc
  
  
#### ~/.vim/ftdetect/rapid.vim
Detects Rapid files based on their file name and content. Rapid files are
checked for the presence of a MODULE line or any %%% HEADER. In case of an
empty file you need to `:set filetype=rapid` manually.  
.../ftdetect/rapid.vim also corrects mixed line endings (unix/dos-mix to unix)
in \*.cfg files if |g:rapidAutoCorrCfgLineEnd| is set to 1.
Requires >

    :filetype on
  
  
#### ~/.vim/ftplugin/rapid.vim
Sets various vim options and provides key mappings and concealing. It supports
commentary [vimscript #3695][7] and matchit [vimscript #39][8]. All key
mappings are optional.  
Requires >

    :filetype plugin on
  
  
#### ~/.vim/indent/rapid.vim
Sets indent related vim options. Sets indention to 2 spaces by default,
optional.  
Requires >

    :filetype indent on
  
  
#### ~/.vim/syntax/rapid.vim
Does make life more colorful. Unfortunately some features of the other files
may work better with syntax on. This should not stop you from trying syntax
off if you like.  
Requires >

    :syntax on
  
  
## tl:dr

Q: Why so many options?  
A: I try not to interfere with user settings to much. So I made most of the
   settings that get changed optional.

Q: I'm here to feed my kids, not to read. Do you have a quick suggestion on
   krl settings for my |.vimrc|?  
A: Yes: >

    let g:rapidMoveAroundKeyMap=1 " [[, ]], [] and ][ jumps around PROC/FUNC..
    let g:rapidGoDefinitionKeyMap=1 " gd shows the declaration of curr. word
    let g:rapidListDefKeyMap=1 " <leader>f shows all PROC/FUNC.. in curr. file
    let g:rapidListUsageKeyMap=1 " <leader>u shows all appearance of curr. word
    let g:rapidAutoFormKeyMap=1 " <leader>n inserts a body for a new PROC etc
    let g:rapidConcealStructsKeyMap=1 " <F2>/<F3> to conceal/show struct values
    let g:rapidShowError=1 " shows some syntax errors
    let g:rapidRhsQuickfix=1 " open quickfix window on the right hand side
    let g:qf_window_bottom=0 " if qf.vim exists and you use g:rapidRhsQuickfix
    let g:rapidAutoCorrCfgLineEnd=1 " auto correct \*.cfg line terminator
    " if you use colorscheme tortus use:
    " let g:rapidNoHighLink=1 " even more colors
    " don't forget
    " filetype plugin indent on

## Self promotion

If you like this plugin please rate it on [vim.org][4]. If you don't but you
think it could be useful if this or that would be different, don't hesitate to
email me or even better open an [issue][5]. With a little luck and good
timing you may find me on irc://irc.freenode.net/#vim as KnoP if you have any
questions.  
If you need assistance with your robot project [visit us][9].

[1]: https://github.com/KnoP-01/rapid-for-vim/releases/latest
[2]: https://github.com/KnoP-01/rapid-for-vim#tldr
[3]: https://github.com/KnoP-01/rapid-for-vim/blob/master/doc/rapid.txt#L134
[6]: https://github.com/KnoP-01/rapid-for-vim/blob/master/doc/rapid.txt#L175
[4]: https://vim.sourceforge.io/scripts/script.php?script_id=5348
[5]: https://github.com/KnoP-01/rapid-for-vim/issues
[7]: https://vim.sourceforge.io/scripts/script.php?script_id=3695
[8]: https://vim.sourceforge.io/scripts/script.php?script_id=39
[9]: http://www.graeff.de
