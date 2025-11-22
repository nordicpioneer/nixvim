let
  overlayfiles = [
    ./r-nvim.nix
  ];
in
map import overlayfiles
