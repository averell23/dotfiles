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
    discount  # Markdown-to-HTML CLI, provides `markdown` command (was: Homebrew markdown)
    ffmpeg
    file        # provides libmagic / the `file` command
    git
    git-crypt
    gnupg
    htop
    imagemagick
    imagemagick
    inetutils   # provides telnet
    k6
    links2    # text-mode web browser (was: Homebrew links)
    mas       # Mac App Store CLI (was: Homebrew mas)
    pv
    readline
    silver-searcher-ng
    sqlite
    tmux
    watch
    wget
    yt-dlp
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
