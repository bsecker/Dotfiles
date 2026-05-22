{ pkgs, config, zen-browser, ... }:
{
  imports = [ ./home-common.nix ];

  fonts.fontconfig.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "UbuntuMono Nerd Font Mono";
        size = 13;
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
      };

      decoration = {
        rounding = 10;
      };

      bind = [
        "$mod, Q, killactive"
        "$mod, RETURN, exec, kitty"
        "ALT, R, submap, resize"
      ];

      windowrulev2 = [
        "bordersize 2, class:^(kitty)$"
      ];

      exec-once = "waybar";
    };

    extraConfig = ''
      submap = resize
      binde = , right, resizeactive, 10 0
      binde = , left, resizeactive, -10 0
      bind = , escape, submap, reset
      submap = reset
    '';
  };

  # Linux-only home-manager config goes here (i3, polybar, picom, etc.)
  home = {
    packages = with pkgs; [
      zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      nerd-fonts.ubuntu-mono
    ];
    
    # copy nvim config
    # file.".config/nvim".source = ../nvim; # direct symlinks don't work when lazyvim wants to write files, lets do an out of store symlink
    file.".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/Dotfiles/nvim";
  };
}
