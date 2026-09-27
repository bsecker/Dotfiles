{ ... }:
let
  username = "benjaminsecker";
  homeDir = "/Users/${username}";
in {
  homebrew.casks = [ "1password-cli" ];
  system.primaryUser = username;
  users.users.${username} = {
    name = username;
    home = homeDir;
  };

  home-manager.users.${username} = import ../modules/home/darwin.nix;
  home-manager.extraSpecialArgs = {
    inherit username homeDir;
    gitEmail = "benjamin.secker@ethon.ai";
    extraShellAliases = {
      dont = "cd ~/Work/dontpanic";
      morning = "gcloud auth application-default login && aws sso login";
    };
  };
}
