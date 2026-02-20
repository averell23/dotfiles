{
  description = "Daniel's Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = system: hostModule:
        let pkgs = nixpkgs.legacyPackages.${system};
        in home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix hostModule ];
        };
    in {
      homeConfigurations = {
        "daniel@Crimple" = mkHome "aarch64-darwin" ./hosts/crimple.nix;
        "daniel@khara"   = mkHome "aarch64-darwin" ./hosts/khara.nix;
      };
    };
}
