"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Important: 
"       This requries that you install https://github.com/amix/vimrc !
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""
" => Load pathogen paths
""""""""""""""""""""""""""""""
call pathogen#infect('~/.dotfiles/vim/vundle')
call pathogen#infect('~/.dotfiles/vim/default_plugins')
call pathogen#helptags()

set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.dotfiles/vim/default_plugins/vundle
call vundle#rc()

Bundle 'bufexplorer.zip'

""""""""""""""""""""""""""""""
" => bufExplorer plugin
""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>


Bundle 'mru.vim'

""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
let MRU_Max_Entries = 400
map <leader>f :MRU<CR>


Bundle 'YankRing.vim'

""""""""""""""""""""""""""""""
" => YankRing
""""""""""""""""""""""""""""""
if has("win16") || has("win32")
    " Don't do anything
else
    let g:yankring_history_dir = '~/.dotfiles/vim/temp_dirs/'
endif


Bundle 'ctrlp.vim'

""""""""""""""""""""""""""""""
" => CTRL-P
""""""""""""""""""""""""""""""
let g:ctrlp_working_path_mode = 0

if has("gui_macvim")
  let g:ctrlp_map = '<D-t>'
else
  let g:ctrlp_map = '<A-t>'
endif
map <c-b> :CtrlPBuffer<cr>

let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'


""""""""""""""""""""""""""""""
" => Peepopen
""""""""""""""""""""""""""""""
" map <leader>j :PeepOpen<cr>
" see https://peepcode.com/products/peepopen


""""""""""""""""""""""""""""""
" => snipMate (beside <TAB> support <CTRL-j>)
""""""""""""""""""""""""""""""
" ino <c-j> <c-r>=snipMate#TriggerSnippet()<cr>
" snor <c-j> <esc>i<right><c-r>=snipMate#TriggerSnippet()<cr>


""""""""""""""""""""""""""""""
" => Vim grep
""""""""""""""""""""""""""""""
" let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
" set grepprg=/bin/grep\ -nH



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree and Nerd tree tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'scrooloose/nerdtree'
Bundle 'jistr/vim-nerdtree-tabs'

map <leader>nn :NERDTreeTabsToggle<cr>
map <leader>nb :NERDTreeFromBookmark 
map <leader>nf :NERDTreeFind<cr>

Bundle 'ack.vim'

" Ack
noremap <D-F> :Ack 
      
Bundle 'amix/open_file_under_cursor.vim'
Bundle 'Lokaltog/vim-powerline'
Bundle 'tpope/vim-surround'
" Bundle 'AutoComplPop'
Bundle 'ervandew/supertab'

Bundle 'tpope/vim-fugitive'
map <leader>gst :Gstatus<cr>
map <leader>gci :Gcommit -m 
map <leader>gca :Gcommit -ma 
map <leader>gbl :Gblame<cr>
map <leader>gg :Git 
map <leader>gpp :Git pp<cr>

" Color schemes
Bundle 'mayansmoke'

" Global Search&Replace
Bundle 'greplace.vim'

" File type plugins
Bundle 'vim-coffee-script'
Bundle 'groenewege/vim-less'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-rails'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-haml'
Bundle 'slim-template/vim-slim'

" Reenable the filtype
filetype on           " Enable filetype detection
