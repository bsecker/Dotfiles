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

  # TODO add kitty font
  programs.kitty.enable = true; 

#  wayland.windowManager.hyprland = {
#    enable = false;
#    settings = {
#      "$mod" = "SUPER";
#
#      general = {
#        gaps_in = 5;
#        gaps_out = 20;
#        border_size = 2;
#      };
#
#      decoration = {
#        rounding = 10;
#      };
#
#      bind = [
#        "$mod, Q, killactive"
#        "$mod, RETURN, exec, kitty"
#        "ALT, R, submap, resize"
#      ];
#
#      windowrulev2 = [
#        "bordersize 2, class:^(kitty)$"
#      ];
#
#      exec-once = "waybar";
#    };
#
#    extraConfig = ''
#      submap = resize
#      binde = , right, resizeactive, 10 0
#      binde = , left, resizeactive, -10 0
#      bind = , escape, submap, reset
#      submap = reset
#    '';
#  };

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = {
      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };

      layout = {
        gaps = 8;
        border.width = 2;
      };

      binds = {
        "Mod+Return".action.spawn = [ "kitty" ];
        "Mod+Q".action.close-window = {};
        "Mod+H".action.focus-column-left = {};
        "Mod+L".action.focus-column-right = {};
        "Mod+J".action.focus-window-down = {};
        "Mod+K".action.focus-window-up = {};
        "Mod+Shift+H".action.move-column-left = {};
        "Mod+Shift+L".action.move-column-right = {};
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+Shift+1".action.move-window-to-workspace = 1;
        "Mod+Shift+2".action.move-window-to-workspace = 2;
        "Mod+Shift+3".action.move-window-to-workspace = 3;
        "Mod+Shift+E".action.quit = {};
        "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+" ];
        "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-" ];
        "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
      };
    };
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
