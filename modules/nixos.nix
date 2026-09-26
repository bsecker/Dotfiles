{ pkgs, zen-browser, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.niri.enable = true;
  systemd.services.display-manager.path = [ pkgs.niri ];
  services.displayManager.gdm.enable = true;
  hardware.graphics.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

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
