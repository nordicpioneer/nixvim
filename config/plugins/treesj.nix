{
  plugins.treesj = {
    enable = true;
    settings = {
      # Defaults (<leader>m/j/s) clash with markdown <leader>m*
      use_default_keymaps = false;
      max_join_length = 120;
      cursor_behavior = "hold";
      notify = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>cs";
      action.__raw = "function() require('treesj').split() end";
      options.desc = "TreeSJ split";
      options.silent = true;
    }
    {
      mode = "n";
      key = "<leader>cj";
      action.__raw = "function() require('treesj').join() end";
      options.desc = "TreeSJ join";
      options.silent = true;
    }
  ];
}
