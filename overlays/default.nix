let
  overlayfiles = [
    # remove r IDE for minimal configuration ./r-nvim.nix
    ./m_taskwarrior_d.nix
  ];
in
map import overlayfiles
