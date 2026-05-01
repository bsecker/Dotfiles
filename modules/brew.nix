{ extraBrewCasks ? [], extraBrewFormulas ? [], ... }: {
  homebrew = {
    enable = true;
    casks = [
      "cmux"
      "scroll-reverser"
      "tailscale"
      "homerow"
      "codex"
    ] ++ extraBrewCasks;
    brews = extraBrewFormulas;
  };
}
