{ extraBrewCasks ? [], extraBrewFormulas ? [], ... }: {
  homebrew = {
    enable = true;
    # taps = [ "nikitabobko/tap" ];
    casks = [
      "cmux"
      "scroll-reverser"
      "tailscale"
      "homerow"
      "zen"
      # "aerospace"
    ] ++ extraBrewCasks;
    brews = [ "htop" ] ++ extraBrewFormulas;
  };
}
