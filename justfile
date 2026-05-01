default:
    @just --list

switch-home:
    sudo darwin-rebuild switch --flake .#Benjamin-Laptop-Home

switch-work:
    sudo darwin-rebuild switch --flake .#Benjamins-MacBook-Pro
