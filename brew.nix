{ pkgs, ... }: {
  homebrew = {
    enable = true;
    casks = [
      "cmux"
    ];
  };
}