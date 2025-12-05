let
  overlayfiles = [
    # remove r IDE for minimal configuration ./r-nvim.nix
  ];
in
map import overlayfiles
