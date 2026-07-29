{
  plugins.aerial.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<leader>oo";
      action = "<cmd>AerialToggle!<CR>";
      options = {
        silent = true;
        desc = "Aerial toggle";
      };
    }
    {
      mode = "n";
      key = "<leader>on";
      action = "<cmd>AerialNavToggle<CR>";
      options = {
        silent = true;
        desc = "Aerial nav";
      };
    }
    {
      mode = "n";
      key = "<leader>j";
      action = "<cmd>AerialNext<CR>";
      options = {
        silent = true;
        desc = "Aerial next";
      };
    }
    {
      mode = "n";
      key = "<leader>k";
      action = "<cmd>AerialPrev<CR>";
      options = {
        silent = true;
        desc = "Aerial prev";
      };
    }
    {
      mode = "n";
      key = "<A-j>";
      action = "<cmd>AerialNext<CR>";
      options = {
        silent = true;
        desc = "Aerial next";
      };
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<cmd>AerialPrev<CR>";
      options = {
        silent = true;
        desc = "Aerial prev";
      };
    }
  ];
}
