{ pkgs, config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  imports = [ ./common.nix ];

  fonts.fontconfig.enable = true;
  programs.zsh.shellAliases = {
    charging = "watch -n 0.1 upower -i $(upower -e | grep BAT)";
    scanwifi = "nmcli device wifi list --rescan yes";
  };
  home = {
    packages = with pkgs; [
      nerd-fonts.iosevka
      nerd-fonts.ubuntu-mono
    ];

    # Keep Pi configuration live: edits take effect after Pi's /reload without
    # rebuilding or re-applying Home Manager.
    file.".pi/agent/extensions".source = link "pi/extensions";
    # Free Shift+Tab from Pi's thinking-level shortcut for the plan/build toggle.
    file.".pi/agent/keybindings.json".source = link "pi/keybindings.json";
  };

  # LazyVim writes part of its configuration at runtime.
  xdg.configFile."nvim".source = link "xdg/nvim";

  xdg.configFile."ranger/rc.conf".source = link "xdg/ranger/rc.conf";
  xdg.configFile."ranger/rifle.conf".source = link "xdg/ranger/rifle.conf";
}
