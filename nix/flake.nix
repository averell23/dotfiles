{
  description = "Daniel's nix-darwin and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      # profiles/defaults.nix is always included; pass additional profiles per machine.
      mkDarwin = system: profiles:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./profiles/defaults.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs   = true;
              home-manager.useUserPackages = true;
              home-manager.users.daniel    = import ./home.nix;
            }
          ] ++ profiles;
        };
    in {
      darwinConfigurations = {
        "Crimple" = mkDarwin "aarch64-darwin" [
          ./profiles/work.nix
          ./profiles/personal.nix
        ];
        "khara" = mkDarwin "aarch64-darwin" [
          ./hosts/khara.nix
        ];
      };
    };
}
