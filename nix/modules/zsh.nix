{ pkgs, lib, ... }:

let
  # Fetch the averell zsh theme from GitHub and place it where oh-my-zsh expects it
  averellThemeDir = pkgs.runCommand "averell-zsh-theme" { } ''
    mkdir -p $out/themes
    cp ${pkgs.fetchFromGitHub {
      owner = "averell23";
      repo = "zsh_theme_averell";
      rev = "f1be8d1abd4cac05a19a4b5c30e33cc3a74d5b2c";
      sha256 = "0dg0b71anbqsk16402c9xx7l0zs99lyigszlhgf1ibl3dcqbb9z9";
    }}/averell.zsh-theme $out/themes/averell.zsh-theme
  '';
in

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    history = {
      size = 10000;
      save = 10000;
      extended = true;   # add timestamps
      ignoreDups = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "asdf" "git" "brew" "bundler" "gem" "vagrant" ];
      # Points $ZSH_CUSTOM to the Nix store path containing themes/averell.zsh-theme
      custom = "${averellThemeDir}";
      theme = "averell";
    };

    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    shellAliases = {
      # Nix-managed vim (overrides Homebrew's vim so plugins and config are loaded)
      vim = "$HOME/.nix-profile/bin/vim";

      # Shell
      reload = ". ~/.zshrc";
      cdd = "cd ~/Desktop";
      cdt = "cd ~/Code/averell23/theurgananimals";
      pubkey = "more ~/.ssh/id_dsa.public | pbcopy | echo '=> Public key copied to pasteboard.'";
      upall = "git co -f db/schema.rb &> /dev/null ; git pp && script/update";

      # System / navigation
      cdot = "cd ~/.dotfiles";
      cdn = "cd ~/Code/averell23/notizen";
      devserv = "forego start -f ~/.Procfile.servers";
      grep = "grep --color";
      sgrep = "grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS}";

      # Git shorthand
      gl = "git pull --prune";
      glog = "git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
      gp = "git push origin HEAD";
      gd = "git diff";
      gc = "git commit";
      gca = "git commit -a";
      gco = "git checkout";
      gb = "git branch";
      gcb = "git branch --show-current";
      gs = "git status -sb";
      grm = "git status | grep deleted | awk '{print $3}' | xargs git rm";

      # Ruby / Rails
      bx = "bundle exec";
      spek = "bundle exec rspec";
      br = "bundle exec rails";
      pum = "puma -p 3666";
      cco = "complex_config";
      cdb = "cd $HOME/Code/betterplace/betterplace";
      cda = "cd $HOME/Code/betterplace/betterplace-provisioning";
      cde = "cd $HOME/Code/betterplace/epo";
      cdx = "cd $HOME/Code/betterplace/xform";
      cdc = "cd $HOME/Code/betterplace/coupons";
      cdk = "cd $HOME/Code/betterplace/betterplace-kubernetes-prd";
      cdm = "cd $HOME/Code/betterplace/me";

      # Kubernetes
      kubs = "kubectl --kubeconfig=$HOME/.kube/betterplace-staging";
    };

    sessionVariables = {
      DOTFILES = "$HOME/.dotfiles";
      EDITOR = "vim";
      LSCOLORS = "exfxcxdxbxegedabagacad";
      CLICOLOR = "true";
      BASTION_USER = "daniel.hahn";
      DISPLAY = ":0";
      GOPATH = "$HOME/Code/go";
      HOMEBREW_AUTO_UPDATE_SECS = "259200";
    };

    # All initContent runs after oh-my-zsh in the generated .zshrc.
    # PATH setup here is still in effect for every user command.
    initContent = ''
      # Homebrew (architecture-dependent path)
      export ARCH="$(uname -m)"
      if [ "$ARCH" = "arm64" ]; then
        export HOMEBREW_HOME="/opt/homebrew"
      fi
      export PATH="$HOMEBREW_HOME/bin:$HOMEBREW_HOME/sbin:$PATH"
      export PATH="$DOTFILES/bin:/usr/local/cli-plugins:$PATH"
      export MANPATH="$HOMEBREW_HOME/man:$HOMEBREW_HOME/mysql/man:$HOMEBREW_HOME/git/man:$MANPATH"

      # asdf shims (managed by Homebrew)
      export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

      # OpenSSL build flags for native gem / extension compilation
      export LDFLAGS="-L$HOMEBREW_HOME/opt/openssl/lib"
      export CPPFLAGS="-I$HOMEBREW_HOME/opt/openssl/include"

      # Additional tool paths
      export PATH="$PATH:$HOME/.local/bin"
      export PATH="$PATH:$HOME/.lmstudio/bin"
      export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

      # Shell options
      setopt NO_BG_NICE NO_HUP NO_LIST_BEEP
      setopt LOCAL_OPTIONS LOCAL_TRAPS
      setopt HIST_VERIFY PROMPT_SUBST CORRECT
      setopt COMPLETE_IN_WORD IGNORE_EOF
      setopt complete_aliases
      setopt extended_glob nobeep

      # Keybindings
      bindkey '^[^[[D' backward-word
      bindkey '^[^[[C' forward-word
      bindkey '^[[5D' beginning-of-line
      bindkey '^[[5C' end-of-line
      bindkey '^[[3~' delete-char
      bindkey '^?' backward-delete-char

      # Load custom functions from dotfiles
      fpath=($DOTFILES/zsh/functions $fpath)
      autoload -Uz $DOTFILES/zsh/functions/*(.:t)
      zle -N newtab

      # GNU ls aliases (requires Homebrew coreutils)
      if command -v gls &>/dev/null; then
        alias ls="gls -F --color"
        alias l="gls -lAh --color"
        alias ll="gls -l --color"
        alias la="gls -A --color"
      fi

      # Git prompt helper functions (used by the averell theme)
      source $DOTFILES/git/prompt.zsh

      # iTerm2 shell integration
      source $DOTFILES/iterm/startup.zsh
      test -e ~/.iterm2_shell_integration.zsh && source ~/.iterm2_shell_integration.zsh

      # SSH helpers
      bps() { ssh betterplace@bp-$1.betterops.de }
      epo() { ssh betterplace@epo-$1.betterops.de }
      dha-bps() { ssh daniel.hahn@bp-$1.betterops.de }
      dha-epo() { ssh daniel.hahn@epo-$1.betterops.de }

      # Secrets (git-crypt encrypted)
      [[ -f $DOTFILES/system/tokens.secret.zsh ]] && source $DOTFILES/system/tokens.secret.zsh

      # Local and machine-specific overrides
      [[ -f ~/.localrc ]] && source ~/.localrc
      [[ -f ~/.profile ]] && source ~/.profile
    '';
  };
}
