{ pkgs, ... }:

{
  imports = [
    ./modules/git.nix
    ./modules/tmux.nix
    ./modules/vim.nix
    ./modules/zsh.nix
  ];
  home.username = "daniel";
  home.homeDirectory = "/Users/daniel";

  # Set once. Do not change after initial install.
  # See https://nix-community.github.io/home-manager/release-notes.xhtml
  home.stateVersion = "24.11";

  # CLI packages (migrated from Brewfile)
  # GUI apps (casks) remain in Homebrew for now
  home.packages = with pkgs; [
    powerline-fonts
    git
    git-crypt
    tmux
    wget
    watch
    pv
    imagemagick
    file        # provides libmagic / the `file` command
    inetutils   # provides telnet
  ];

  # Direnv: auto-load .envrc files per directory
  # nix-direnv caches Nix dev shells so re-entering is instant
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Dotfile configs managed by Home Manager
  home.file = {
    ".gemrc".source                  = ../ruby/gemrc;
    ".irbrc".source                  = ../ruby/irbrc;
    ".gemini/settings.json".source   = ../gemini/gemini/settings.json;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
