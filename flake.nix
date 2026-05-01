{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    mkSystem = hostModule: nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self; };
      modules = [
        ./modules/darwin.nix
        home-manager.darwinModules.home-manager
        hostModule
      ];
    };
  in
  {
    # Build with: darwin-rebuild build --flake .#Benjamins-MacBook-Pro
    darwinConfigurations."Benjamins-MacBook-Pro" = mkSystem ./hosts/work.nix;

    # Build with: darwin-rebuild build --flake .#Benjamin-Laptop-Home
    darwinConfigurations."Benjamin-Laptop-Home" = mkSystem ./hosts/personal.nix;
  };
}
