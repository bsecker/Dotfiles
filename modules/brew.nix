{ extraBrewCasks ? [], extraBrewFormulas ? [], ... }: {
  homebrew = {
    enable = true;
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
