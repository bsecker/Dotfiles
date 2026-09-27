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
    home-manager-darwin.url = "github:nix-community/home-manager/release-25.11";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixpkgs-unstable, home-manager, home-manager-darwin, hunk, zen-browser, ... }:
  let
    unstableFor = system: import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    homeManagerIntegration = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
    };
    mkDarwinSystem = hostModule: nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self;
        pkgs-unstable = unstableFor "aarch64-darwin";
        inherit hunk;
      };
      modules = [
        ./modules/darwin/base.nix
        home-manager-darwin.darwinModules.home-manager
        homeManagerIntegration
        { home-manager.extraSpecialArgs = {
            inherit hunk;
            pkgs-unstable = unstableFor "aarch64-darwin";
          };
        }
        hostModule
      ];
    };

    mkNixOSSystem = { system ? "x86_64-linux", hostModule }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit self hunk zen-browser;
        pkgs-unstable = unstableFor system;
      };
      modules = [
        home-manager.nixosModules.home-manager
        homeManagerIntegration
        { home-manager.extraSpecialArgs = {
            inherit hunk;
            pkgs-unstable = unstableFor system;
          };
        }
        ./modules/nixos/base.nix
        hostModule
      ];
    };

    mkHome = { system, hostModule }: home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

      };
      extraSpecialArgs = {
        pkgs-unstable = unstableFor system;
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
