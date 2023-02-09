set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

Plugin 'derekwyatt/vim-scala'
Plugin 'jlanzarotta/bufexplorer'

""""""""""""""""""""""""""""""
" => bufExplorer plugin
""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>

Plugin 'yegappan/mru'

""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
let MRU_Max_Entries = 400
map <leader>f :MRU<CR>

Plugin 'vim-scripts/YankRing.vim'

""""""""""""""""""""""""""""""
" => YankRing
""""""""""""""""""""""""""""""
if has("win16") || has("win32")
    " Don't do anything
else
    let g:yankring_history_dir = '~/.dotfiles/vim/temp_dirs/'
endif

Plugin 'ctrlpvim/ctrlp.vim'

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
map <leader>t :CtrlP<cr>

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
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'

map <leader>nn :NERDTreeTabsToggle<cr>
map <leader>nb :NERDTreeFromBookmark
map <leader>nf :NERDTreeFind<cr>

Plugin 'rking/ag.vim'

" Ack
noremap <D-F> :Ag

Plugin 'amix/open_file_under_cursor.vim'
Plugin 'Lokaltog/vim-powerline'
Plugin 'tpope/vim-surround'
" Bundle 'AutoComplPop'
Plugin 'ervandew/supertab'

Plugin 'tpope/vim-fugitive'
map <leader>gst :Gstatus<cr>
map <leader>gci :Gcommit -m
map <leader>gca :Gcommit -ma
map <leader>gbl :Gblame<cr>
map <leader>gg :Git
map <leader>gpp :Git pp<cr>

" Syntastic
Plugin 'scrooloose/syntastic'
let g:syntastic_ruby_checkers = ['mri', 'rubocop']
let g:synstatic_javascript_checkers = ['jsl']
map <leader>st :SyntasticCheck<cr>

" Tabular
Plugin 'godlygeek/tabular'

Plugin 'airblade/vim-gitgutter'

" rspec runner
" Bundle 'thoughtbot/vim-rspec'
" let g:rspec_command = "!bundle exec rspec {spec}"
" command Spek :call RunCurrentSpecFile()<CR>
" command Spekk :call RunLastSpec()<CR>
" map <Leader>sk :call RunCurrentSpecFile()<CR>
" map <Leader>skk :call RunLastSpec()<CR>

Plugin 'skwp/vim-rspec'

" Color schemes
Plugin 'vim-scripts/mayansmoke'

" Global Search&Replace
Plugin 'vim-scripts/greplace.vim'

" Command-T file open
Plugin 'wincent/command-t'

" File type plugins
Plugin 'vim-coffee-script'
Plugin 'groenewege/vim-less'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-rails'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-haml'
Plugin 'slim-template/vim-slim'
Plugin 'rodjek/vim-puppet'
Plugin 'ekalinin/Dockerfile.vim'

" Dash integration (Mac)
Plugin 'rizzatti/funcoo.vim'
Plugin 'rizzatti/dash.vim'
" Reenable the filtype
filetype on           " Enable filetype detection


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
