{ pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/Users/daniel";

  # Set once. Do not change after initial install.
  # See https://nix-community.github.io/home-manager/release-notes.xhtml
  home.stateVersion = "24.11";

  # CLI packages (migrated from Brewfile)
  # GUI apps (casks) remain in Homebrew for now
  home.packages = with pkgs; [
    direnv
    fzf
    git
    git-crypt
    tmux
    vim
    wget
    watch
    pv
    imagemagick
    file        # provides libmagic / the `file` command
    inetutils   # provides telnet
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
