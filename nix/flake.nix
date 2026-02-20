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
      mkDarwin = system: hostModules:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs   = true;
              home-manager.useUserPackages = true;
              home-manager.users.daniel    = import ./home.nix;
            }
          ] ++ hostModules;
        };
    in {
      darwinConfigurations = {
        "Crimple" = mkDarwin "aarch64-darwin" [ ./hosts/crimple.nix ];
        "khara"   = mkDarwin "aarch64-darwin" [ ./hosts/khara.nix ];
      };
    };
}
