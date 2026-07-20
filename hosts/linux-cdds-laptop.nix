{ ... }:
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
}
