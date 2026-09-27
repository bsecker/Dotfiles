{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.niri;
  dotfiles = "${config.home.homeDirectory}/Dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
  pomodoro = pkgs.writeShellScriptBin "pomodoro" ''
    exec ${pkgs.python3.withPackages (pythonPackages: [ pythonPackages.evdev ])}/bin/python ${dotfiles}/xdg/pomodoro/pomodoro.py "$@"
  '';
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
  waybarBase = builtins.head (builtins.fromJSON (builtins.readFile ../../xdg/waybar/template.json));
  waybarConfig = waybarBase // {
    "group/system" = waybarBase."group/system" // {
      modules = if cfg.hasBacklight then waybarBase."group/system".modules
        else builtins.filter (name: name != "backlight") waybarBase."group/system".modules;
    };
  };
in
{
  options.dotfiles.niri = {
    hostConfig = lib.mkOption {
      type = lib.types.path;
      description = "Host-specific Niri KDL included after the shared configuration.";
    };
    hasBacklight = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to show the laptop backlight control in Waybar.";
    };
  };

  config = {
    home.packages = with pkgs; [
      kitty
      fuzzel
      waybar
      mako
      swaylock
      brightnessctl
      wlsunset
      wl-clipboard
      pomodoro
      xwayland-satellite
    ];

    systemd.user.services.swaybg = mkNiriService "${pkgs.swaybg}/bin/swaybg -m fill -i %h/Dotfiles/wallpapers/6.jpg";
    # Waybar does not auto-discover the generated file named "config".
    systemd.user.services.waybar = mkNiriService "${pkgs.waybar}/bin/waybar --config ${config.xdg.configHome}/waybar/config --style ${config.xdg.configHome}/waybar/style.css";
    systemd.user.services.mako = mkNiriService "${pkgs.mako}/bin/mako";
    systemd.user.services.wlsunset = mkNiriService "${pkgs.wlsunset}/bin/wlsunset -t 3500 -s 19:00";
    systemd.user.services.swayidle = mkNiriService "${pkgs.swayidle}/bin/swayidle -w timeout 601 'niri msg action power-off-monitors' timeout 600 '${pkgs.swaylock}/bin/swaylock -f' before-sleep '${pkgs.swaylock}/bin/swaylock -f'";
    systemd.user.services.pomodoro = mkNiriService "${pomodoro}/bin/pomodoro daemon";
    systemd.user.services.openai-codex-usage = {
      Unit.Description = "Refresh OpenAI Codex usage cache";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.nodejs}/bin/node ${dotfiles}/scripts/openai-codex-usage-refresh.mjs";
      };
    };
    systemd.user.timers.openai-codex-usage = {
      Unit.Description = "Refresh OpenAI Codex usage cache every five minutes";
      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "5m";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    xdg.configFile."niri/config.kdl".text = ''
      include "${../../xdg/niri/common.kdl}"
      include "${cfg.hostConfig}"
    '';
    xdg.configFile."waybar/config".text = builtins.toJSON [ waybarConfig ];
    xdg.configFile."waybar/style.css".source = ../../xdg/waybar/style.css;
    xdg.configFile."waybar/scripts".source = link "xdg/waybar/scripts";
    xdg.configFile."mako".source = ../../xdg/mako;
    xdg.configFile."fuzzel/fuzzel.ini".source = ../../xdg/fuzzel/fuzzel.ini;
    xdg.configFile."swaylock".source = ../../xdg/swaylock;
    xdg.dataFile."applications/chromium_daemon.desktop".source = ../../xdg/applications/chromium_daemon.desktop;
  };
}
