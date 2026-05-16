{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, home-manager }:
  let
    mkSystem = hostModule: nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self;
        pkgs-unstable = import nixpkgs-unstable { system = "aarch64-darwin"; config.allowUnfree = true; };
      };
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
