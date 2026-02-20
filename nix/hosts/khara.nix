# khara-specific configuration
{ ... }: {
  # No GUI casks on khara

  # youtube-dl was previously a Homebrew package; managed by Nix now
  home-manager.users.daniel = { pkgs, ... }: {
    home.packages = with pkgs; [ youtube-dl ];
  };
}
