{ extraBrewCasks ? [], extraBrewFormulas ? [], ... }: {
  homebrew = {
    enable = true;
    casks = [
      "cmux"
      "scroll-reverser"
      "tailscale"
      "homerow"
    ] ++ extraBrewCasks;
    brews = [ "htop" ] ++ extraBrewFormulas;
  };
}
