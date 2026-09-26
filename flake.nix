{
  description = "nix-darwin, NixOS & Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, home-manager, hunk, ... }:
  let
    mkDarwinSystem = hostModule: nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self;
        pkgs-unstable = import nixpkgs-unstable { system = "aarch64-darwin"; config.allowUnfree = true; };
        inherit hunk;
      };
      modules = [
        ./modules/darwin.nix
        home-manager.darwinModules.home-manager
        { home-manager.extraSpecialArgs = { inherit hunk; }; }
        hostModule
      ];
    };

    mkNixOSSystem = { system ? "x86_64-linux", hostModule }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit self hunk;
        pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
      };
      modules = [
        home-manager.nixosModules.home-manager
        ./modules/nixos.nix
        hostModule
      ];
    };

    mkHome = { system, hostModule }: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

      };
      extraSpecialArgs = {
        pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
        inherit hunk;
      };
      modules = [
        hostModule
      ];
    };
  in
  {
    # Build with: darwin-rebuild build --flake .#Benjamins-MacBook-Pro
    darwinConfigurations."Benjamins-MacBook-Pro" = mkDarwinSystem ./hosts/macos-ethon.nix;

    # Build with: darwin-rebuild build --flake .#Benjamin-Laptop-Home
    darwinConfigurations."Benjamin-Laptop-Home" = mkDarwinSystem ./hosts/macos-personal.nix;

    # Build with: nixos-rebuild build --flake .#BenjaminDesktop-NixOS
    nixosConfigurations."BenjaminDesktop-NixOS" = mkNixOSSystem {
      hostModule = ./hosts/nixos-desktop.nix;
    };

    # Build with: home-manager switch --flake .#benjamin@linux-cdds-laptop
    homeConfigurations."benjamin@linux-cdds-laptop" = mkHome {
      system = "x86_64-linux";
      hostModule = ./hosts/linux-cdds-laptop.nix;
    };
  };
}
