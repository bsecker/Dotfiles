# Dotfiles

My repo for tracking some of my customisation to my laptops/desktops.


## Setup

roughly
```
# install homebrew manually, first
sudo mkdir -p /etc/nix-darwin
sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
cd /etc/nix-darwin
git clone https://github.com/bsecker/dotfiles
# move everything inside to /etc/nix-darwin

# took a few tries to get working, follow nix-darwin instructions on github first
sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin/nix-darwin-25.11#darwin-rebuild -- switch
   --flake .#Benjamin-Laptop-Home 2>&1
```
