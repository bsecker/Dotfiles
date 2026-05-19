{
  config,
  pkgs,
  pkgs-unstable,
  username,
  homeDir,
  gitEmail,
  extraShellAliases ? { },
  ...
}:
{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    eza
    uv
    just
    bun
    github-cli
    nixfmt
    pkgs-unstable.claude-code
    bat
    procps
    ripgrep
    fd
    jq
    wget
    lazygit
    neovim
    tree-sitter
    pkgs-unstable.devenv
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Benjamin Secker";
        email = gitEmail;
      };
      push.autoSetupRemote = true;
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
        cat = "bat";
        gloga = "git log --oneline --decorate --color --graph --all";
      }
      // extraShellAliases;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "z"
          "colored-man-pages"
          "docker-compose"
          "docker"
          "kubectl"
        ];
        theme = "af-magic";
      };
    };
  };

  # out of store symlinks so that we can make edits to the file from cmux and it comes up in repo
  # cmux settings
  xdg.configFile."cmux/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nix-darwin/.config/cmux/settings.json";

  # AeroSpace config
  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nix-darwin/.aerospace.toml";
}
