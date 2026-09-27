{ pkgs, ... }:
{
  # Ubuntu's desktop environment also needs to see Nix-installed applications.
  home.sessionVariables.XDG_DATA_DIRS = "$HOME/.nix-profile/share:/var/lib/snapd/desktop:/usr/local/share:/usr/share:/nix/var/nix/profiles/default/share";
  home.packages = [
    pkgs._1password-gui
    (pkgs.writeShellScriptBin "laptop-time-report" ''
      exec ${pkgs.python3}/bin/python "$HOME/Dotfiles/scripts/laptop-time-report" "$@"
    '')
  ];
}
