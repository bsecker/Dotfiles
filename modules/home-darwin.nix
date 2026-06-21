{ config, ... }:
{
  imports = [ ./home-common.nix ];

  programs.zsh.initContent = ''
    # Add Homebrew (Apple Silicon) to PATH for casks installed via nix-darwin
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  '';

  # out of store symlinks so that we can make edits to the file from cmux and it comes up in repo
  # cmux settings
  xdg.configFile."cmux/cmux.json".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nix-darwin/.config/cmux/cmux.json";

  # AeroSpace config
  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink "/etc/nix-darwin/.aerospace.toml";
}
