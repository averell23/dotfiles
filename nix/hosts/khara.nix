# khara-specific configuration
{ ... }: {
  homebrew.taps = [ "macos-fuse-t/cask" ];
    homebrew.casks = [
        "blackhole-16ch" # virtual audio driver for WSJT-X audio routing
        "eddie"
        "fuse-t"
        "lm-studio"
        "slack"
    ];
}
