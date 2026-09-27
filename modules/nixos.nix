# TODO:
# this is pretty tied to my home PC, not really "generic" in case I get more nixos machines
{ pkgs, zen-browser, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # login and display manager
  programs.niri.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "niri";
  systemd.services.display-manager.path = [ pkgs.niri ];

  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${config.programs.niri.package}/bin/niri-session";
  #       user = "benjamin"; # todo wire in from host
  #     };
  #   };
  # };
  #
  # # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
  # # unit which shadows the imported user-manager PATH. Disabling the default
  # # lets niri inherit the full PATH set up by niri-session.
  # systemd.user.services.niri.enableDefaultPath = false;

  # nvidia 
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia.open = false; # use proprietary drivers

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.steam.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    firefox-bin
  ];
}
