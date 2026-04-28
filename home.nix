{ config, pkgs, ... }: {
  home.stateVersion = "25.11";

  home.packages = [
    pkgs.eza
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Benjamin Secker";
        email = "benjamin.secker@ethon.ai";
      };
    };
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        dont = "cd ~/Work/dontpanic";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        ws = "workstation";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "z" ];
        theme = "robbyrussell";
      };
    };
  };

  # cmux settings  - out of store symlink so that we can make edits to the file from cmux
  xdg.configFile."cmux/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "/etc/nix-darwin/.config/cmux/settings.json";
}
