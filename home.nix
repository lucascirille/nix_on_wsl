
{ config, pkgs, ... }:

{
  home.username = "dotneit";
  home.homeDirectory = "/home/dotneit";

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    git
    curl
    wget
    neovim
    ripgrep
    fd
    fzf
    htop
  ];

  programs.home-manager.enable = true;
}
