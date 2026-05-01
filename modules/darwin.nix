{ self, pkgs, ... }: {
  environment.systemPackages = [
    pkgs.vim
    pkgs.fzf
  ];

  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.enable = false;

  system.defaults = {
    CustomUserPreferences = {
      "com.apple.Siri" = {
        "UAProfileCheckingStatus" = 0;
        "siriEnabled" = 0;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };

      spaces.spans-displays = true;

      "com.microsoft.VSCode" = {
        ApplePressAndHoldEnabled = false;
      };

      # also for Cursor, yes this is really the bundle ID
      # https://forum.cursor.com/t/cursor-bundle-identifier/779/4
      "com.todesktop.230313mzl4w4u92" = {
        ApplePressAndHoldEnabled = false;
      };

      "md.obsidian" = {
        ApplePressAndHoldEnabled = false;
      };
    };

    controlcenter.BatteryShowPercentage = true;
    trackpad.Clicking = true;

    dock.autohide = true;
    dock.autohide-delay = 0.25;
    dock.appswitcher-all-displays = true;

    hitoolbox.AppleFnUsageType = "Do Nothing";

    NSGlobalDomain = {
      InitialKeyRepeat = 20;
      KeyRepeat = 2;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  nixpkgs.overlays = [
    (_final: _super: {
      direnv = _super.direnv.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
  programs.direnv.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  imports = [ ./brew.nix ];
}
