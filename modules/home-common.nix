{
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
    # shell tools
    eza
    just
    bun
    github-cli
    nixfmt
    pkgs-unstable.claude-code
    pkgs-unstable.devenv
    bat
    procps
    ripgrep
    fd
    jq
    wget
    ranger
    direnv
    kubectx

    # python
    python3
    uv
    
    
    # neovim and stuff
    tree-sitter
    neovim
    gcc # required for lazyvim treesitter to work, is there a better way than installing gcc globally?
    lazygit
    nodejs # Mason needs npm to install LSP servers (yaml-ls, pyright, dockerfile-ls, etc.)
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
      initContent = ''
        eval "$(devenv hook zsh)"
      '';
    };
  };
}
