# Dotfiles

My repo for tracking some of my customisation to my laptops/desktops.

## Setup (Ubuntu)

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

# Install tailscale manually
curl -fsSL https://tailscale.com/install.sh | sh

# Install zen manually (couldn't get hardware acceleration working, didn't want to go down the NixGL route)
# see also https://alternativebit.fr/posts/nixos/nix-opengl-and-ubuntu-integration-nightmare/
curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | $SHELL

# Install other stuff manually:
# Cursor
# Discord (tbh this does work with nix but is a bit laggy)
# Alacritty

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

linux

- [x] fix nerd fonts not applying
- [ ] install i3 or equivalent

## Things to look into

```
Status Bar: waybar, eww, or custom scripts
Notifications: mako, swaync, or dunst
App Launcher: rofi, wofi, fuzzel, or tofi
Screen Locking: swaylock, hyprlock, or gtklock
Idle Management: swayidle, hypridle
System Tools: htop, btop, nm-applet, blueman, pavucontrol
Audio Control: pavucontrol, pamixer scripts
Brightness Control: brightnessctl with custom bindings
Clipboard Manager: clipman, cliphist, or wl-clipboard scripts
Wallpaper Management: swaybg, swww, hyprpaper, or wpaperd
Theming: manually configuring gtk, qt, various apps, bars, compositor gaps and colors
Power Management: custom scripts or additional daemons
Greeter: gdm, sddm, lightdm, greetd
```
