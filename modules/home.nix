{ config, pkgs, username, homeDir, gitEmail, extraShellAliases ? {}, ... }: {
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";

  home.packages = [
    pkgs.eza
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "Benjamin Secker";
      email = gitEmail;
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

      initContent = ''
        # Add Homebrew (Apple Silicon) to PATH for casks installed via nix-darwin
        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      '';

      shellAliases = {
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
        kc = "kubectl";
        please = "sudo";
        lah = "ls -lah";
      } // extraShellAliases;

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "z" "colored-man-pages" "docker-compose" "docker" "kubectl"];
        theme = "af-magic";
      };
    };
  };

  # cmux settings - out of store symlink so that we can make edits to the file from cmux
  xdg.configFile."cmux/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "/etc/nix-darwin/.config/cmux/settings.json";
}
