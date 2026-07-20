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
    ] ++ extraBrewCasks;
    brews = [ "htop" ] ++ extraBrewFormulas;
  };
}
