- never run `just` commands or `nix switch` commands without approval first
- validate both generated Niri host configurations with `niri validate -c <generated-config>` after Niri configuration changes
- when I refer to pi, I am talking about pi agent, not raspberry pi

## Configuration ownership

- `hosts/` selects a machine's modules and contains its identity, hardware, and
  personal overrides. A new host opts in to capabilities explicitly.
- `modules/nixos/` and `modules/darwin/` own system services, login sessions,
  hardware integration, and system defaults. Put packages in
  `environment.systemPackages` only if the system (or every user) needs them.
- `modules/home/common.nix` owns my cross-platform user tools and shell;
  `modules/home/linux.nix` and `darwin.nix` own OS-wide user settings.
  `modules/home/niri.nix` is an opt-in graphical desktop capability shared by
  NixOS and Ubuntu. Personal CLI tools and applications go in `home.packages`.
- `modules/home/ubuntu.nix` holds workarounds for standalone Home Manager on
  Ubuntu. Ubuntu installs Niri and its login session; Home Manager configures
  my Niri user environment. On NixOS, `modules/nixos/niri-session.nix` owns
  Niri's system integration instead.
- `modules/darwin/brew.nix` owns common Homebrew casks; a macOS host can add
  casks directly via `homebrew.casks`. Use casks for applications installed via
  Homebrew, not for tools already managed by Home Manager.

The Niri module generates `~/.config/niri/config.kdl` with includes of
`xdg/niri/common.kdl` and the host KDL selected in `hosts/`. Niri needs version
25.11 or newer for includes (check the Ubuntu-installed version). Put shared
bindings and layout in `common.kdl`, outputs and hardware workarounds in the
host KDL. Waybar uses `xdg/waybar/template.json` as its common JSON template; the
Home Manager Niri module hides laptop-only backlight controls on the desktop.
Keep the checkout at `~/Dotfiles` on Linux: several user scripts and live
symlinks rely on that path.

Build before switching: `nixos-rebuild build --flake .#BenjaminDesktop-NixOS`
on NixOS, `home-manager build --flake .#benjamin@linux-cdds-laptop` on Ubuntu,
or `darwin-rebuild build --flake .#<host>` on macOS. Validate each generated
Niri config with `niri validate -c <path-to-generated-config>`.
