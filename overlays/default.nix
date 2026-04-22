let
  overlayfiles = [
    ./r-nvim.nix
    ./m_taskwarrior_d.nix
  ];
in
map import overlayfiles
