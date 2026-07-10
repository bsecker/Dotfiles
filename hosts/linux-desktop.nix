{ ... }:
let
  username = "benjamin";
  homeDir = "/home/${username}";
in
{
  imports = [ ../modules/home-linux.nix ];

  _module.args = {
    inherit username homeDir;
    gitEmail = "benjamin.secker@gmail.com";
  };
}
