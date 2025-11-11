{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
     #R-nvim
  ];
}
