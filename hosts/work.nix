{ pkgs, ... }:
let
  username = "benjaminsecker";
  homeDir = "/Users/${username}";
in {
  _module.args = {
    extraBrewCasks = [];
    extraBrewFormulas = [];
  };
  system.primaryUser = username;
  users.users.${username} = {
    name = username;
    home = homeDir;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.${username} = import ../modules/home.nix;
  home-manager.extraSpecialArgs = {
    inherit username homeDir;
    gitEmail = "benjamin.secker@ethon.ai";
    extraShellAliases = {
      dont = "cd ~/Work/dontpanic";
    };
  };
}
