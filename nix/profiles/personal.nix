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
    "exactscan"
    "gramps"
    "handbrake-app"
    "signal"
    "slack"
    "teamviewer"
    "telegram"
    "threema@beta"
    "grandperspective" # disk usage
    "vlc"
    "whatsapp"
    "zoom"
  ];
}
