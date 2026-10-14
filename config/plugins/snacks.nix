{
  plugins.snacks = {
    enable = true;
    settings = {
      input.enabled = true;
      picker.enabled = true;
      terminal.enabled = true;
      # Jet plots / markdown diagrams use image.nvim instead (see image.nix)
      image.enabled = false;
    };
  };
}
