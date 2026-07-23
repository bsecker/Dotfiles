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
    show() {
      local issue_id commit pr_url
      if [[ "$*" =~ '(CD-[0-9]+)' ]]; then
        issue_id="''${match[1]}"
        xdg-open "https://patrikcd.atlassian.net/browse/$issue_id"
      elif [[ "$*" =~ '(^|[^[:alnum:]])([0-9a-fA-F]{7,40})($|[^[:alnum:]])' ]]; then
        commit="''${match[2]}"
        if git rev-parse --verify --quiet "$commit^{commit}" >/dev/null; then
          pr_url=$(gh api "repos/{owner}/{repo}/commits/$commit/pulls" --jq '.[0].html_url') || return
          if [[ -n "$pr_url" ]]; then
            xdg-open "$pr_url"
          else
            print -u2 "No pull request found for commit: $commit"
            return 1
          fi
        else
          print -u2 "Commit not found in the current repository: $commit"
          return 1
        fi
      else
        print -u2 "Usage: show <text containing CD-1234 or a git commit hash>"
        return 1
      fi
    }
  '';
}
