{ pkgs, ... }:
let
  username = "benjamin";
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
  home-manager.users.${username} = {
    imports = [ ../modules/home.nix ];
    # React Native development https://reactnative.dev/docs/set-up-your-environment?platform=android
    programs.zsh.sessionVariables = {
      JAVA_HOME = "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home";
      ANDROID_HOME = "$HOME/Library/Android/sdk";
    };
    programs.zsh.initContent = ''
      export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
    '';
  };
  home-manager.extraSpecialArgs = {
    inherit username homeDir;
    gitEmail = "benjamin.secker@gmail.com";
    extraShellAliases = {
      hl="/Users/benjamin/Personal/Projects/homelab/homelab.sh";
    };
  };
}
