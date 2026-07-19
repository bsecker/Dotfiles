default:
    @just --list

home:
    sudo darwin-rebuild switch --flake .#Benjamin-Laptop-Home

work:
    home-manager switch --flake .#benjamin@linux-cdds-laptop

desktop:
    home-manager switch --flake .#benjamin@linux-desktop

update:
    nix flake update

# build and show diff
builddiff flake:
    home-manager build --flake {{ flake }}
    nix store diff-closures \
        "$HOME/.local/state/nix/profiles/home-manager" \
        ./result
    rm -f ./result
