default:
    @just --list

home:
    sudo darwin-rebuild switch --flake .#Benjamin-Laptop-Home

work:
    home-manager switch --flake .#benjamin@linux-cdds-laptop

desktop:
    sudo nixos-rebuild switch --flake path:.#BenjaminDesktop-NixOS

update:
    nix flake update

# build and show diff
builddiff flake:
    home-manager build --flake {{ flake }}
    nix store diff-closures \
        "$HOME/.local/state/nix/profiles/home-manager" \
        ./result
    rm -f ./result
