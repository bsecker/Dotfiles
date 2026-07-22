{ pkgs, config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
  mkNiriService = command: {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = command;
      Restart = "on-failure";
    };

    Install.WantedBy = [ "niri.service" ];
  };
in
{
  imports = [ ./home-common.nix ];

  fonts.fontconfig.enable = true;
  systemd.user.services.swaybg = mkNiriService "${pkgs.swaybg}/bin/swaybg -m fill -i %h/Dotfiles/wallpapers/6.jpg";
  systemd.user.services.wlsunset = mkNiriService "${pkgs.wlsunset}/bin/wlsunset -t 3500 -s 19:00";
  systemd.user.services.swayidle = mkNiriService "${pkgs.swayidle}/bin/swayidle -w timeout 601 '${pkgs.niri}/bin/niri msg action power-off-monitors' timeout 600 '/usr/bin/swaylock -f' before-sleep '/usr/bin/swaylock -f'";

  # Linux-only home-manager config goes here (i3, polybar, picom, etc.)
  home = {

    # so that gnome etc can find the nix-installed apps
    sessionVariables = {
      XDG_DATA_DIRS = "$HOME/.nix-profile/share:/var/lib/snapd/desktop:/usr/local/share:/usr/share:/nix/var/nix/profiles/default/share";
    };

    packages = with pkgs; [
      nerd-fonts.iosevka
      nerd-fonts.ubuntu-mono
      # signal-desktop # this causes issues with electron trying to rebuild from source, takes forever, don't bother
      # zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default # this doesn't really work with graphics accelleration on ubuntu without nixGL, so lets just skip it for now
      brightnessctl
      wlsunset
    ];

    # Keep Pi configuration live: edits take effect after Pi's /reload without
    # rebuilding or re-applying Home Manager.
    file.".pi/agent/extensions".source = link "pi/extensions";
    # Free Shift+Tab from Pi's thinking-level shortcut for the plan/build toggle.
    file.".pi/agent/keybindings.json".source = link "pi/keybindings.json";
  };

  # LazyVim writes part of its configuration at runtime.
  xdg.configFile."nvim".source = link "xdg/nvim";

  # Keep Niri's configuration writable outside the Nix store.
  xdg.configFile."niri".source = link "xdg/niri";
  xdg.configFile."niri".force = true;

  # Keep Waybar's configuration writable outside the Nix store.
  xdg.configFile."waybar".source = link "xdg/waybar";
  xdg.configFile."waybar".force = true;

  xdg.configFile."mako".source = link "xdg/mako";

  # Swaylock does not modify its configuration at runtime.
  xdg.configFile."swaylock".source = ../xdg/swaylock;
}
