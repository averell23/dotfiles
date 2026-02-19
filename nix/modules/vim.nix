{ pkgs, ... }:

let
  # Plugins not yet packaged in nixpkgs-unstable
  vim-haml = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-haml";
    version = "2024-01-01";
    src = pkgs.fetchFromGitHub {
      owner = "tpope";
      repo = "vim-haml";
      rev = "c30ee7d885aa1a1cf17d856ab932de75ab789d5d";
      sha256 = "0p3dlgrx2h9yn5qlqpwwdh7msrm2y79dgbl7c1rhfv5880bqva7v";
    };
  };

  vim-slim = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-slim";
    version = "2024-01-01";
    src = pkgs.fetchFromGitHub {
      owner = "slim-template";
      repo = "vim-slim";
      rev = "a0a57f75f20a03d5fa798484743e98f4af623926";
      sha256 = "0ylpgjr8lf2wf5jailahzszsk22gxm8hw8fvci24q61052vg9ywq";
    };
  };

  vim-less = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-less";
    version = "2024-01-01";
    src = pkgs.fetchFromGitHub {
      owner = "groenewege";
      repo = "vim-less";
      rev = "6e818d5614d5fc18d95a48c92b89e6db39f9e3d6";
      sha256 = "0rhqcdry8ycnfbg534q4b3hm78an7mnqhiazxik7k08a57dk9dbm";
    };
  };

  dockerfile-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "Dockerfile-vim";
    version = "2024-01-01";
    src = pkgs.fetchFromGitHub {
      owner = "ekalinin";
      repo = "Dockerfile.vim";
      rev = "2a31e6bcea5977209c05c728c4253d82fd873c82";
      sha256 = "0dicf1igsnhmx8cacjj1qc0yxv3fqb2s6bimngxhvrh9jdkqc91j";
    };
  };
in

{
  programs.vim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      # Buffer / file navigation
      bufexplorer
      mru
      YankRing-vim
      ctrlp-vim
      nerdtree
      vim-nerdtree-tabs

      # Search (ack.vim configured to use ag as backend)
      ack-vim

      # Statusline
      vim-airline
      vim-airline-themes

      # Editing
      vim-surround
      supertab
      tabular

      # Git
      vim-fugitive
      vim-gitgutter

      # Syntax checking
      syntastic

      # Colorscheme
      mayansmoke

      # Language support
      vim-ruby
      vim-rails
      vim-haml
      vim-markdown
      vim-coffee-script
      vim-less
      vim-slim
      vim-puppet
      vim-scala
      dockerfile-vim

      # Test runner
      rspec-vim
    ];

    extraConfig = ''
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Plugin configuration
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      """"""""""""""""""""""""""""""
      " => bufExplorer plugin
      """"""""""""""""""""""""""""""
      let g:bufExplorerDefaultHelp=0
      let g:bufExplorerShowRelativePath=1
      let g:bufExplorerFindActive=1
      let g:bufExplorerSortBy='name'
      map <leader>o :BufExplorer<cr>

      """"""""""""""""""""""""""""""
      " => MRU plugin
      """"""""""""""""""""""""""""""
      let MRU_Max_Entries = 400
      map <leader>f :MRU<CR>

      """"""""""""""""""""""""""""""
      " => YankRing
      """"""""""""""""""""""""""""""
      if has("win16") || has("win32")
          " Don't do anything
      else
          let g:yankring_history_dir = $HOME . '/.vim'
      endif

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

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Nerd Tree and Nerd tree tabs
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      map <leader>nn :NERDTreeTabsToggle<cr>
      map <leader>nb :NERDTreeFromBookmark
      map <leader>nf :NERDTreeFind<cr>

      " Ack (using ag as backend)
      let g:ackprg = 'ag --vimgrep'
      noremap <D-F> :Ack<space>

      " Fugitive
      map <leader>gst :Gstatus<cr>
      map <leader>gci :Gcommit -m
      map <leader>gca :Gcommit -ma
      map <leader>gbl :Gblame<cr>
      map <leader>gg :Git
      map <leader>gpp :Git pp<cr>

      " Syntastic
      let g:syntastic_ruby_checkers = ['mri', 'rubocop']
      let g:synstatic_javascript_checkers = ['jsl']
      map <leader>st :SyntasticCheck<cr>

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => General
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      set history=700

      filetype plugin on
      filetype indent on

      set autoread

      let mapleader = ","
      let g:mapleader = ","

      nmap <leader>w :w!<cr>

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => VIM user interface
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      set so=7
      set wildmenu
      set number
      set wildignore=*.o,*~,*.pyc
      if has("win16") || has("win32")
          set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
      else
          set wildignore+=.git\*,.hg\*,.svn\*
      endif

      set ruler
      set cmdheight=2
      set hid
      set backspace=eol,start,indent
      set whichwrap+=<,>,h,l
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      set lazyredraw
      set magic
      set showmatch
      set mat=2
      set noerrorbells
      set novisualbell
      set t_vb=
      set tm=500
      set foldcolumn=1

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Colors and Fonts
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      syntax enable

      try
          colorscheme mayansmoke
      catch
          colorscheme desert
      endtry

      set background=light

      if has("gui_running")
          set guioptions-=T
          set guioptions-=e
          set t_Co=256
          set guitablabel=%M\ %t
      endif

      set encoding=utf8
      set ffs=unix,dos,mac

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Files, backups and undo
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      set nobackup
      set nowb
      set noswapfile

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Text, tab and indent related
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      set expandtab
      set smarttab
      set shiftwidth=2
      set tabstop=2
      set lbr
      set tw=500

      set ai
      set si
      set wrap

      vnoremap < <gv
      vnoremap > >gv

      """"""""""""""""""""""""""""""
      " => Visual mode related
      """"""""""""""""""""""""""""""
      vnoremap <silent> * :call VisualSelection('f', ${"''"})<CR>
      vnoremap <silent> # :call VisualSelection('b', ${"''"})<CR>

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Moving around, tabs, windows and buffers
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      map j gj
      map k gk

      map <space> /
      map <c-space> ?

      map <silent> <leader><cr> :noh<cr>

      map <C-j> <C-W>j
      map <C-k> <C-W>k
      map <C-h> <C-W>h
      map <C-l> <C-W>l
      map <D-M-Down> <C-W>j
      map <D-M-Up> <C-W>k
      map <D-M-Left> <C-W>h
      map <D-M-Right> <C-W>l

      map <C-Tab> :tabnext<cr>
      map <leader>bd :Bclose<cr>
      map <leader>ba :1,1000 bd!<cr>

      if has("gui_running")
        noremap <C-Tab> :tabnext<cr>
      endif
      map <leader>tt :tabnext<cr>
      map <leader>tn :tabnew<cr>
      map <leader>to :tabonly<cr>
      map <leader>tc :tabclose<cr>
      map <leader>tm :tabmove
      map <leader>t<leader> :tabnext

      map <leader>v "0p

      map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
      map <leader>cd :cd %:p:h<cr>:pwd<cr>

      try
        set switchbuf=useopen,usetab,newtab
        set stal=2
      catch
      endtry

      autocmd BufReadPost *
           \ if line("'\"") > 0 && line("'\"") <= line("$") |
           \   exe "normal! g`\"" |
           \ endif
      set viminfo^=%

      """"""""""""""""""""""""""""""
      " => Status line
      """"""""""""""""""""""""""""""
      set laststatus=2

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Editing mappings
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      map 0 ^

      nmap <M-j> mz:m+<cr>`z
      nmap <M-k> mz:m-2<cr>`z
      vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
      vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

      if has("mac") || has("macunix")
        nmap <D-j> <M-j>
        nmap <D-k> <M-k>
        vmap <D-j> <M-j>
        vmap <D-k> <M-k>
      endif

      func! DeleteTrailingWS()
        exe "normal mz"
        %s/\s\+$//ge
        exe "normal `z"
      endfunc
      autocmd BufWrite *.py     :call DeleteTrailingWS()
      autocmd BufWrite *.coffee :call DeleteTrailingWS()
      autocmd BufWrite *.rb     :call DeleteTrailingWS()
      autocmd BufWrite *.haml   :call DeleteTrailingWS()
      autocmd BufWrite *.sass   :call DeleteTrailingWS()
      autocmd BufWrite *.js     :call DeleteTrailingWS()
      autocmd BufWrite *.slim   :call DeleteTrailingWS()
      autocmd BufWrite *.scss   :call DeleteTrailingWS()
      autocmd BufWrite *.erb    :call DeleteTrailingWS()
      autocmd BufWrite *.html   :call DeleteTrailingWS()
      autocmd BufWrite *.xml    :call DeleteTrailingWS()
      autocmd BufWrite *.json   :call DeleteTrailingWS()
      autocmd BufWrite *.yml    :call DeleteTrailingWS()
      autocmd BufWrite *.yaml   :call DeleteTrailingWS()
      autocmd FocusLost * silent! wa

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => vimgrep searching and cope displaying
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      vnoremap <silent> gv :call VisualSelection('gv', ${"''"})<CR>

      map <leader>vg :vimgrep // **/*.<left><left><left><left><left><left><left>
      map <leader><space> :vimgrep // <C-R>%<C-A><right><right><right><right><right><right><right><right><right>

      vnoremap <silent> <leader>r :call VisualSelection('replace', ${"''"})<CR>

      map <leader>cc :botright cope<cr>
      map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
      map <leader>n :cn<cr>
      map <leader>p :cp<cr>

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Spell checking
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      map <leader>ss :setlocal spell!<cr>

      map <leader>sn ]s
      map <leader>sp [s
      map <leader>sa zg
      map <leader>s? z=

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Misc
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

      map <leader>q :e ~/buffer<cr>

      map <leader>pp :setlocal paste!<cr>

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Helper functions
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      function! CmdLine(str)
          exe "menu Foo.Bar :" . a:str
          emenu Foo.Bar
          unmenu Foo
      endfunction

      function! VisualSelection(direction, extra_filter) range
          let l:saved_reg = @"
          execute "normal! vgvy"

          let l:pattern = escape(@", '\\/.*$^~[]')
          let l:pattern = substitute(l:pattern, "\n$", "", "")

          if a:direction == 'b'
              execute "normal ?" . l:pattern . "^M"
          elseif a:direction == 'gv'
              call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.' . a:extra_filter)
          elseif a:direction == 'replace'
              call CmdLine("%s" . '/'. l:pattern . '/')
          elseif a:direction == 'f'
              execute "normal /" . l:pattern . "^M"
          endif

          let @/ = l:pattern
          let @" = l:saved_reg
      endfunction

      function! HasPaste()
          if &paste
              return 'PASTE MODE  '
          en
          return ${"''"}
      endfunction

      command! Bclose call <SID>BufcloseCloseIt()
      function! <SID>BufcloseCloseIt()
         let l:currentBufNum = bufnr("%")
         let l:alternateBufNum = bufnr("#")

         if buflisted(l:alternateBufNum)
           buffer #
         else
           bnext
         endif

         if bufnr("%") == l:currentBufNum
           new
         endif

         if buflisted(l:currentBufNum)
           execute("bdelete! ".l:currentBufNum)
         endif
      endfunction

      """"""""""""""""""""""""""""""
      " => Python section
      """"""""""""""""""""""""""""""
      let python_highlight_all = 1
      au FileType python syn keyword pythonDecorator True None False self

      au BufNewFile,BufRead *.jinja set syntax=htmljinja
      au BufNewFile,BufRead *.mako set ft=mako

      au FileType python map <buffer> F :set foldmethod=indent<cr>

      au FileType python inoremap <buffer> $r return
      au FileType python inoremap <buffer> $i import
      au FileType python inoremap <buffer> $p print
      au FileType python inoremap <buffer> $f #--- PH ----------------------------------------------<esc>FP2xi
      au FileType python map <buffer> <leader>1 /class
      au FileType python map <buffer> <leader>2 /def
      au FileType python map <buffer> <leader>C ?class
      au FileType python map <buffer> <leader>D ?def

      """"""""""""""""""""""""""""""
      " => JavaScript section
      """"""""""""""""""""""""""""""
      au FileType javascript setl fen
      au FileType javascript setl nocindent

      au FileType javascript imap <c-t> AJS.log();<esc>hi
      au FileType javascript imap <c-a> alert();<esc>hi

      au FileType javascript inoremap <buffer> $r return
      au FileType javascript inoremap <buffer> $f //--- PH ----------------------------------------------<esc>FP2xi

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => GUI related
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      if has("mac") || has("macunix")
          set gfn=Menlo:h14
          set shell=/bin/bash
      elseif has("win16") || has("win32")
          set gfn=Bitstream\ Vera\ Sans\ Mono:h10
      elseif has("linux")
          set gfn=Monospace\ 10
          set shell=/bin/bash
      endif

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Persistent undo
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      try
          set undodir=$HOME/.vim/undo
          set undofile
      catch
      endtry

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Command mode related
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      cno $h e ~/
      cno $d e ~/Desktop/
      cno $j e ./
      cno $c e <C-\>eCurrentFileDir("e")<cr>
      cno $q <C-\>eDeleteTillSlash()<cr>

      cnoremap <C-A> <Home>
      cnoremap <C-E> <End>
      cnoremap <C-K> <C-U>

      cnoremap <C-P> <Up>
      cnoremap <C-N> <Down>

      map ½ $
      cmap ½ $
      imap ½ $

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Parenthesis/bracket
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      vnoremap $1 <esc>`>a)<esc>`<i(<esc>
      vnoremap $2 <esc>`>a]<esc>`<i[<esc>
      vnoremap $3 <esc>`>a}<esc>`<i{<esc>
      vnoremap $$ <esc>`>a"<esc>`<i"<esc>
      vnoremap $q <esc>`>a'<esc>`<i'<esc>
      vnoremap $e <esc>`>a"<esc>`<i"<esc>

      inoremap $1 ()<esc>i
      inoremap $2 []<esc>i
      inoremap $3 {}<esc>i
      inoremap $4 {<esc>o}<esc>O
      inoremap $q ${"''"}<esc>i
      inoremap $e ""<esc>i
      inoremap $t <><esc>i

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => General abbreviations
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Omni complete functions
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      autocmd FileType css set omnifunc=csscomplete#CompleteCSS

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Extended helper functions
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      func! DeleteTillSlash()
          let g:cmd = getcmdline()

          if has("win16") || has("win32")
              let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\]\\).*", "\\1", "")
          else
              let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
          endif

          if g:cmd == g:cmd_edited
              if has("win16") || has("win32")
                  let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
              else
                  let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
              endif
          endif

          return g:cmd_edited
      endfunc

      func! CurrentFileDir(cmd)
          return a:cmd . " " . expand("%:p:h") . "/"
      endfunc

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => MacVim
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      if has("gui_macvim")
        macmenu &File.New\ Tab key=<nop>
      endif
    '';
  };
}
