{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-web-devicons
    quarto-nvim
  ];
  plugins.otter.enable = true;
  plugins.jupytext.enable = true;
  plugins.molten.enable = true;
}
