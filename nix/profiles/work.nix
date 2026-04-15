# Work profile: tools and casks for work machines
{ pkgs, ... }: {
  home-manager.users.daniel.home.packages = with pkgs; [
    # Personal CLI tools
    k9s
  ];
  homebrew.casks = [
    "dash"         # documentation browser
    "docker-desktop"
    "google-drive"
    "claude"
    "claude-code"
    "copilot-cli"
    "gcloud-cli"
    "lm-studio"
    "postman"      # API testing
    "sequel-ace"   # database client
    "signal"
    "slack"
    "thunderbird"
    "tunnelblick"  # VPN
    "visual-studio-code"
    "zen"
  ];
}
