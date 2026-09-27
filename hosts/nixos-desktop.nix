{ config, lib, modulesPath, pkgs, zen-browser, ... }:
let
  username = "benjamin";
  homeDir = "/home/${username}";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules/nixos/niri-session.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/03f56901-2904-46fd-82a0-806317458e10";
    fsType = "btrfs";
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/03f56901-2904-46fd-82a0-806317458e10";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/03f56901-2904-46fd-82a0-806317458e10";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7BBA-669F";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia.open = false;
  programs.steam.enable = true;

  networking.hostName = "BenjaminDesktop-NixOS";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_GB.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "Benjamin";
    extraGroups = [ "networkmanager" "wheel" ];
  };




  nixpkgs.config.allowUnfree = true;
  services.openssh.enable = true;

  system.stateVersion = "26.05";

  home-manager.extraSpecialArgs = {
    inherit username homeDir;
    gitEmail = "benjamin.secker@gmail.com";
    extraShellAliases = { };
  };
  home-manager.users.${username} = {
    imports = [ ../modules/home/linux.nix ../modules/home/niri.nix ];
    home.packages = [
      pkgs.firefox-bin
      zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    dotfiles.niri.hostConfig = ../xdg/niri/nixos-desktop.kdl;
    dotfiles.niri.hasBacklight = false;
  };
}
