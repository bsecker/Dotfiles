{ lib, ... }:
let
  username = "benjamin";
  homeDir = "/home/${username}";
in
{
  imports = [ ../modules/home-linux.nix ];

  _module.args = {
    inherit username homeDir;
    gitEmail = "benjamin.secker@cdds.ai";
    extraShellAliases = {
      ws = "cd ~/Work/cdds_ws";
      notes = "cd ~/Work/cdds_notes";
    };
  };

  programs.zsh.initContent = lib.mkAfter ''
    jira() {
      local issue_id
      if [[ "$*" =~ '(CD-[0-9]+)' ]]; then
        issue_id="''${match[1]}"
        xdg-open "https://patrikcd.atlassian.net/browse/$issue_id"
      else
        print -u2 "Usage: jira <text containing CD-1234>"
        return 1
      fi
    }
  '';
}
