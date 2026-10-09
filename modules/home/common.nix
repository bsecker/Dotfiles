{
  pkgs,
  pkgs-unstable,
  hunk,
  worktrunk,
  username,
  homeDir,
  gitEmail,
  config,
  extraShellAliases ? { },
  ...
}:
let
  gen-kubeconfig = pkgs.writeShellApplication {
    name = "gen-kubeconfig";
    runtimeInputs = with pkgs; [
      kubectl
      gnused
      coreutils
    ];
    text = builtins.readFile ../../scripts/gen_kubeconfig.sh;
  };
in
{
  imports = [
    hunk.homeManagerModules.default
    worktrunk.homeModules.default
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.sessionVariables.SUDO_PROMPT = builtins.readFile ../../sudoers.lecture;

  home.packages = with pkgs; [
    # shell tools
    eza
    vim
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
    kubectx
    gnumake
    htop
    btop
    dive
    git-town
    gen-kubeconfig

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
  programs.hunk = {
    enable = true;
    enableGitIntegration = true;
  };
  programs.worktrunk = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."opencode" = {
    source = ../../xdg/opencode;
    recursive = true;
    force = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      alias.s = "town switch";
      user = {
        name = "Benjamin Secker";
        email = gitEmail;
      };
      push.autoSetupRemote = true;
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      # Zsh requires finite limits; use its maximum supported history size
      history = {
        size = 2147483647;
        save = 2147483647;
      };

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
        fucking = "sudo";
        lah = "ls -lah";
        cat = "bat";
        oc = "opencode";
        ghs = "gh stack";
        lg = "lazygit";
        dot = "cd ~/Dotfiles; nvim ."; 

        # Git aliases
        gloga = "git log --oneline --decorate --color --graph --all";
        ghpr = "gh pr view --web";
        gt = "git town";
        push = "git push --force-with-lease";
        amend = "git commit --amend --no-edit";
        staged = "git diff --staged";
        scanwifi = "nmcli device wifi list --rescan yes";
        wtl = "wt list";
        wts = "wt switch";
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

        # Jump to a worktree by branch name, or create a new one.
        wt-old() {
          local selection dir branch repo_root worktree_dir upstream_branch
          selection=$(
            {
              printf '__new_worktree__\tnew worktree\n'
              git worktree list --porcelain \
                | awk '
                    /^worktree / { dir = substr($0, 10) }
                    /^branch / {
                      branch = substr($0, 8)
                      sub("refs/heads/", "", branch)
                      print dir "\t" branch
                    }
                  '
            } | fzf --query="$1" --with-nth=2.. --delimiter=$'\t'
          ) || return
          IFS=$'\t' read -r dir branch <<< "$selection"

          if [ "$dir" = '__new_worktree__' ]; then
            read -r "branch?New worktree name/branch: " || return
            [ -n "$branch" ] || return
            repo_root=$(git rev-parse --show-toplevel) || return
            worktree_dir="$(dirname "$repo_root")/worktrees/$branch"
            if git show-ref --verify --quiet "refs/heads/$branch"; then
              git worktree add "$worktree_dir" "$branch" || return
            else
              upstream_branch=$(git for-each-ref --format='%(refname:short)' "refs/remotes/*/$branch" | awk 'NR == 1')
              if [ -n "$upstream_branch" ]; then
                git worktree add --track -b "$branch" "$worktree_dir" "$upstream_branch" || return
              else
                git worktree add "$worktree_dir" -b "$branch" || return
              fi
            fi
            cd "$worktree_dir" || return
            echo "Switched to worktree: $worktree_dir (branch: $branch)"
          elif [ -n "$dir" ]; then
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
