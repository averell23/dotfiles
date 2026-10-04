# Personal profile: tools and casks for personal use
{ pkgs, ... }: {
  home-manager.users.daniel.home.packages = with pkgs; [
    # Personal CLI tools
    deno
  ];
  homebrew.casks = [
    "balenaetcher"
    "claude"
    "cyberduck"    # file transfer
    "cryptomator"
    "eddie"
    "exactscan"
    "gramps"
    "handbrake-app"
    "libreoffice"
    "nextcloud"
    "signal"
    "slack"
    "teamviewer"
    "telegram"
    "tunnelblick"
    "threema@beta"
    "grandperspective" # disk usage
    "vlc"
    "whatsapp"
    "zoom"
  ];
}
