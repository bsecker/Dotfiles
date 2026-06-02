{ extraBrewCasks ? [], extraBrewFormulas ? [], ... }: {
  homebrew = {
    enable = true;
    taps = [ 
      "nikitabobko/tap"
      "BarutSRB/tap"
    ];
    casks = [
      "cmux"
      "scroll-reverser"
      "tailscale"
      "homerow"
      "zen"
      "aerospace"
      "omniwm"
    ] ++ extraBrewCasks;
    brews = [ "htop" ] ++ extraBrewFormulas;
  };
}
