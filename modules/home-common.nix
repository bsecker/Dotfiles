{
  pkgs,
  pkgs-unstable,
  username,
  homeDir,
  gitEmail,
  config,
  extraShellAliases ? { },
  ...
}:
{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.sessionVariables.SUDO_PROMPT = builtins.readFile ../sudoers.lecture;

  home.packages = with pkgs; [
    # shell tools
    eza
    just
    bun
    github-cli
    nixfmt
    bat
    procps
    ripgrep
    fd
    jq
    wget
    ranger
    direnv
    gnumake
    htop
    btop # kind of nice but idk
    dive
    git-town

    # things I generally want to be more on the bleeding edge on
    pkgs-unstable.claude-code
    pkgs-unstable.devenv
    pkgs-unstable.codex
    pkgs-unstable.opencode
    pkgs-unstable.pi-coding-agent

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

  xdg.configFile."opencode" = {
    source = ../xdg/opencode;
    recursive = true;
    force = true;
  };

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
        oc = "opencode";
        gt = "git town";
        charging = "watch -n 0.1 upower -i $(upower -e | grep BAT)";
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
        theme = "edvardm";
      };
      initContent = ''
        eval "$(devenv hook zsh)"

        # Jump to a worktree by branch name.
        wt() {
          local selection dir branch
          selection=$(git worktree list --porcelain \
            | awk '
                /^worktree / { dir = substr($0, 10) }
                /^branch / {
                  branch = substr($0, 8)
                  sub("refs/heads/", "", branch)
                  print dir "\t" branch
                }
              ' \
            | fzf --query="$1" --with-nth=2.. --delimiter=$'\t') || return
          IFS=$'\t' read -r dir branch <<< "$selection"
          if [ -n "$dir" ]; then
            cd "$dir" || return
            echo "Switched to worktree: $dir (branch: $branch)"
          else
            echo "No worktree found"
            return 1
          fi
        }
      '';
    };
  };
}
