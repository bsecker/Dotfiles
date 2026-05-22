# Dotfiles

My repo for tracking some of my customisation to my laptops/desktops.

## Setup (linux)

```
# base install
sudo apt install curl
# install determinate nix - better and faster than base nix
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
# install flake
nix run home-manager/release-25.11 -- switch --flake github:bsecker/dotfiles#benjamin@linux-desktop -b backup

# ensure that we can use zsh as the default shell (blocked otherwise by chsh)
echo "$(which zsh)" | sudo tee -a /etc/shells
chsh -s $(which zsh)
```


## Setup (macos)

roughly...

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

## TODOs

- [ ] cmux dotfile overriding don't seem to work correctly
- [ ] automate nvim dotfiles, override $EDITOR default to use
- [x] fzf reverse search seems broken on home laptop?
