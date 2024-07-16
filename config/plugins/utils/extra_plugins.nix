{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-web-devicons
    quarto-nvim
  ];
}
