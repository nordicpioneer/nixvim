let
  overlayfiles = [
    # remove r IDE for minimal configuration ./r-nvim.nix
    ./m_taskwarrior_d.nix
    ./taskwarrior_nvim.nix
    ./obsidian-nvim.nix
  ];
in
map import overlayfiles
