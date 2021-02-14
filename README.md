```
                                             _           _______
                                            /.\\        /  ___  \_________  _
 ___       ___    ____    _____   ____      \_/ \       | /   \     ____  \/ |   _____
|   \     /   \  |    \  |_   _| |    \       \  \      | | O |  _________/\_|  /  | o\
|  _ |   |  _  | |  _  |   | |   |  _  |       \--\     | \___/ /             _/  _/  /
| | ||   | | | | | | | |   | |   | | | |       | o |     \      \       /\   /.\ / | |
| |_| \  | |_| | | |_| |   | |   | |_| |       /--/       \  \\  \      \/\  \_//  | |
|  __  | |  _  | |  ___|  _| |_  |     |      /  /         \  \\  \      \ \      /  |
|_|  \_| |_| |_| |_|     |_____| |____/     _/  /           \   _  \      \-\     |  o\_
                                           / \ /            |  /.\  |     |o|     /_____\
                 for Vim                  | o |_      _____/   \_/  |     /-/     |     |
               by Knosowski                \_/__|__  |____   ______/     / /      |_____|
                                           |___ ___\ |    \_____   |    /  |
                                            |  \__ |  \___________/     | o \__
                                            |______|  |           |     \______\
        industrial robot programming                  |           |      |     |
                                                      |___________|      |_____|
```
# rapid-for-vim

**READ [FAQ][2] FIRST** if you want more than just syntax highlight and 
automatic indenting. It is a quick overview over the most important options 
and mappings provided by Rapid for Vim. For more details see the [help][3] file.

## Introduction:

Rapid for [Vim][10] (7.4 or later) is a collection of Vim scripts to help
programming [ABB industrial robots][9]. 

It provides
* syntax highlighting,
* indenting,
* concealing of structure values (e.g. MoveJ \* v2500...),
* support for commentary [vimscript #3695][7], matchit [vimscript #39][8], 
    matchup [vimscript #5624][11] and endwise [vimscript #2386][12],
* mappings and settings to navigate through code in a backup folder structure,
* text objects for functions and comments,
* completion of words from known or custom global files like EIO.cfg,
* mappings to insert a body of a new PROC, FUNC, TRAP et al based on user
    defined templates or hopefully sane defaults.

**Note:** Keep your files to edit in one folder or in a regular robot 
backup folder structure. Rapid for Vim modifies 'path' accordingly.
**Note to Linux users:** Keep your files to edit on a FAT file system.  
Some features need the case insensitive file system to work properly.


## Installation:

### Installation with [vim-plug][14]:  ~  

Put this in your .vimrc:  >

    call plug#begin('~/.vim/plugged')
      Plug 'KnoP-01/rapid-for-vim'
    call plug#end()
    syntax off                 " undo what plug#begin() did to syntax
    filetype plugin indent off " undo what plug#begin() did to filetype
    syntax on                  " syntax and filetype on in that order
    filetype plugin indent on  " syntax and filetype on in that order

For the first installation run: >

    :PlugInstall

Update every once in a while with: >

    :PlugUpdate

### Manual installation:  ~  

Extract the most recent [release][1] and copy the folders 
`/doc`, `/ftdetect`, `/ftplugin`, `/indent` and `/syntax` 
into your `~/.vim/` or `%USERPROFILE%\vimfiles\` directory. 
Overwrite rapid.\* files from older installation. 

Put the following in your .vimrc: >

    syntax on                  " syntax and filetype on in that order
    filetype plugin indent on  " syntax and filetype on in that order

You may have to run >

    :helptags ~/.vim/doc/

or >

    :helptags ~/vimfiles/doc/

to use the help within Vim after installation. >

    :help rapid


## FAQ

Q: How do I disable an annoying feature of rapid-for-vim?  
A: Disable feature in your `vimrc`, see [rapid-options][6] for details: >

    let g:rapidShortenQFPath   = 0 " don't shorten paths in quickfix
    let g:rapidAutoComment     = 0 " don't continue comments with o, O or Enter
    let g:rapidFormatComments  = 0 " don't break comment lines automatically
    let g:rapidCommentIndent   = 1 " indent comments starting in 1st column too
    let g:rapidSpaceIndent     = 0 " don't change 'sts', 'sw', 'et' and 'sr'
    "let g:rapidConcealStructs = 0 " switch concealing off completely
    "let g:rapidConcealStructs = 1 " show structure values at cursorline (default)
    let g:rapidConcealStructs  = 2 " conceal all structure values

Q: Which keys get mapped to what? Will that override my own mappings?  
A: rapid-for-vim will not override existing mappings unless the corresponding
   option is explicitly set. To use different key bindings see :help 
   [rapid-key-mappings][13] for <Plug> mappings.  
   Otherwise rapid-for-vim create the following mappings: >

    <F2> Show all structure values
    <F3> Show structure values at cursorline
    <F4> Conceal all structure values
            Override existing mapping with
        let g:rapidConcealStructKeyMap = 1

    gd Go to or show definition of variable or func, proc et al.
            Does override Vim's default. Make Vim's default available with 
        nnoremap gd gd
            Override existing mapping with
        let g:rapidGoDefinitionKeyMap = 1

    <leader>u List all significant references of word under cursor.
            Override existing mapping with
        let g:rapidListUsageKeyMap = 1

    <leader>f List all PROC/FUNC/TRAP/RECORD of the current file.
            Override existing mapping with
        let g:rapidListDefKeyMap = 1

    [[ Move around functions. Takes a count.
    ]] Move around functions. Takes a count.
    [] Move around functions. Takes a count.
    ][ Move around functions. Takes a count.
    [; Move around comments. Takes a count.
    ]; Move around comments. Takes a count.
            Does override existing mappings and Vim's default.
            Disable override existing mappings and Vim's default with
        let g:rapidMoveAroundKeyMap = 0

    if Inner function text object.
    af Around function text object.
    aF Around function text object including preceding comments.
            Depends on g:rapidMoveAroundKeyMap not existing or =1.
            Override existing mapping with
        let g:rapidFunctionTextObject = 1

    ic Inner comment text object.
    ac Around comment text object.
            Depends on g:rapidMoveAroundKeyMap not existing or =1.
            Override existing mapping with
        let g:rapidCommentTextObject = 1

    <leader>n Inserts a new PROC/FUNC/TRAP/RECORD.
            Override existing mapping with
        let g:rapidAutoFormKeyMap = 1

Q: When I switch syntax off I get false indentation sometimes?
A: Indentation partly depends on `syntax on` . If you have strings with ! or
   keywords in it Indentation may get confused without syntax on. It should
   do fine for the most part of your editing. See next question.

Q: Does rapid-for-vim provide a mapping for indenting the whole file?  
A: No, but you may put the following in your .vimrc or
   `~/.vim/after/ftplugin/rapid.vim`: >

    nnoremap ANYKEY gg=G``zz

or if you don't use syntax highlighting >

    nnoremap ANYKEY :syntax on<bar>normal gg=G``zz<cr>:syntax off<cr>

Q: Scrolling feels sluggish. What can I do?  
A: Switch error highlighting off: >

    let g:rapidShowError = 0      " better performance

Q: Still sluggish!  
A: Switch syntax off or jump instead of scroll!  

Q: Where are the nice and informative messages?  
A: `:let g:knopVerbose=1` any time.  

## Self promotion

If you like this plugin please rate it on [vim.org][4]. If you don't but you
think it could be useful if this or that would be different, don't hesitate to
email me or even better open an [issue][5]. With a little luck and good
timing you may find me on irc://irc.freenode.net/#vim as KnoP in case you have
any questions.  

[1]: https://github.com/KnoP-01/rapid-for-vim/releases/latest
[2]: https://github.com/KnoP-01/rapid-for-vim#FAQ
[3]: https://github.com/KnoP-01/rapid-for-vim/blob/master/doc/rapid.txt#L203
[4]: https://www.vim.org/scripts/script.php?script_id=5348
[5]: https://github.com/KnoP-01/rapid-for-vim/issues
[6]: https://github.com/KnoP-01/rapid-for-vim/blob/master/doc/rapid.txt#L221
[7]: https://github.com/tpope/vim-commentary
[8]: https://www.vim.org/scripts/script.php?script_id=39
[9]: https://new.abb.com/products/robotics/industrial-robots
[10]: https://www.vim.org/
[11]: https://github.com/andymass/vim-matchup
[12]: https://github.com/tpope/vim-endwise
[13]: https://github.com/KnoP-01/rapid-for-vim/blob/master/doc/rapid.txt#L233
[14]: https://github.com/junegunn/vim-plug
