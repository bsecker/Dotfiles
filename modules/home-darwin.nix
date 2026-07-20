{ config, ... }:
let
  dotfiles = "/etc/nix-darwin";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [ ./home-common.nix ];

  programs.zsh.initContent = ''
    # Add Homebrew (Apple Silicon) to PATH for casks installed via nix-darwin
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';

  # Cmux saves edits directly to this configuration file.
  xdg.configFile."cmux/cmux.json".source = link "xdg/cmux/cmux.json";
  xdg.configFile."ghostty/config".source = ../xdg/ghostty/config;

  # Keep Pi configuration live: edits take effect after Pi's /reload without
  # rebuilding or re-applying Home Manager.
  home.file.".pi/agent/extensions".source = link "pi/extensions";
  # Free Shift+Tab from Pi's thinking-level shortcut for the plan/build toggle.
  home.file.".pi/agent/keybindings.json".source = link "pi/keybindings.json";

  # AeroSpace config
  home.file.".aerospace.toml".source = link ".aerospace.toml";
}
