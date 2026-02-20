# khara-specific Home Manager configuration
{ pkgs, ... }: {
  home.packages = with pkgs; [
    youtube-dl
  ];
}
