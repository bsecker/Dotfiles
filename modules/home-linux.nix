{ pkgs, config, ... }:
{
  imports = [ ./home-common.nix ];

  fonts.fontconfig.enable = true;

  # Linux-only home-manager config goes here (i3, polybar, picom, etc.)
  home = {

    # so that gnome etc can find the nix-installed apps
    sessionVariables = {
      XDG_DATA_DIRS = "$HOME/.nix-profile/share:/var/lib/snapd/desktop:/usr/local/share:/usr/share:/nix/var/nix/profiles/default/share";
    };

    packages = with pkgs; [
      nerd-fonts.ubuntu-mono
      # signal-desktop # this causes issues with electron trying to rebuild from source, takes forever, don't bother
      # zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default # this doesn't really work with graphics accelleration on ubuntu without nixGL, so lets just skip it for now
    ];

    # copy nvim config
    # file.".config/nvim".source = ../nvim; # direct symlinks don't work when lazyvim wants to write files, lets do an out of store symlink
    file.".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/Dotfiles/nvim";
  };
}
