{ pkgs, ... }: {
  homebrew = {
    enable = true;
    casks = [
      "cmux"
      "scroll-reverser"
      "tailscale"
    ];
  };
}