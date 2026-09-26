_: {
  plugins.snacks = {
    enable = true;
    settings = {
      input.enabled = true;
      picker.enabled = true;
      terminal.enabled = true;
      # Required by jet.nvim / jet.ark for plot windows (Kitty graphics protocol)
      image = {
        enabled = true;
        force = true; # paint even if terminal detection fails
      };
    };
  };
}
