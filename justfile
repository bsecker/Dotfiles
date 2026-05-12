default:
    @just --list

home:
    sudo darwin-rebuild switch --flake .#Benjamin-Laptop-Home

work:
    sudo darwin-rebuild switch --flake .#Benjamins-MacBook-Pro
