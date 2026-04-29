{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      # NOTE: I struggle to run apps that need a GUI or get put in /Applications because Gatekeeper gets in the way
      # use homebrew for those apps instead until I figure out how to fix this
      environment.systemPackages =
        [ 
          pkgs.vim 
          pkgs.fzf
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # turn off nix management as determinate nix looks after it
      # TODO make compatible with both approaches?
      nix.enable = false;

     # TODO not portable
     system.primaryUser = "benjaminsecker";
     users.users.benjaminsecker = {
       name = "benjaminsecker";
       home = "/Users/benjaminsecker";
     };

     system.defaults = {
        CustomUserPreferences = {
          # Disable siri
          "com.apple.Siri" = {
            "UAProfileCheckingStatus" = 0;
            "siriEnabled" = 0;
          };
          # Disable personalized ads 
          "com.apple.AdLib" = {
            allowApplePersonalizedAdvertising = false;
          };

          # Enable spaces to span displays
          spaces.spans-displays = true;


          # Disable press-and-hold accent popup in VS Code so key repeat works (e.g. for Vim mode)
          "com.microsoft.VSCode" = {
            ApplePressAndHoldEnabled = false;
          };

          # also for Cursor, yes this is really the bundle ID
          # https://forum.cursor.com/t/cursor-bundle-identifier/779/4
          "com.todesktop.230313mzl4w4u92" = {
            ApplePressAndHoldEnabled = false;
          };

          # also for Obsidian
          "md.obsidian" = {
            ApplePressAndHoldEnabled = false;
          };
        };

        # Show battery percentage in the menu bar
        controlcenter.BatteryShowPercentage = true;

        # Allow touch to click
        trackpad.Clicking = true;

        # Hide the dock after a small delay of inactivity
        dock.autohide = true;
        dock.autohide-delay = 0.25;
        # display app switcher on all displays
        dock.appswitcher-all-displays = true;

        # turn off emojis on fn key
        hitoolbox.AppleFnUsageType = "Do Nothing";
        
        # update key repeat interval
        NSGlobalDomain = {
          InitialKeyRepeat = 20;
          KeyRepeat = 2;
        };
    };

    # replace caps lock with esc
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # direnv
    nixpkgs.overlays = [
      (_final: _super: {
        direnv = _super.direnv.overrideAttrs (_: {
          doCheck = false;
        });
      })
    ];
    programs.direnv.enable=true;

    # homebrew
    # note: when setting up a new machine, install homebrew manually first
    imports = [ ./brew.nix ];

    # sudo with touch ID 
    security.pam.services.sudo_local.touchIdAuth = true;
  };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Benjamins-MacBook-Pro
    darwinConfigurations."Benjamins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.benjaminsecker = import ./home.nix;
        }
      ];
    };
  };
}
