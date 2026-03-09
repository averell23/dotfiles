# khara-specific configuration
{ ... }: {
  homebrew.taps = [ "macos-fuse-t/cask" ];
    homebrew.casks = [
        "fuse-t"
        "lm-studio"
        "slack"
    ];
}
