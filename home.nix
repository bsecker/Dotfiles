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
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        dont = "cd ~/Work/dontpanic";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        ws = "workstation";
        tf = "tofu";
        terraform = "tofu";
        tfi = "tofu init";
        tfp = "tofu plan";
        tfa = "tofu apply";
        tfyeet = "tofu apply -auto-approve";
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
