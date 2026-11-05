{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.tuicr-nvim
  ];

  extraPackages = [
    pkgs.tuicr
  ];

  extraConfigLua = ''
    require("tuicr").setup({
      command = "${pkgs.tuicr}/bin/tuicr",
    })

    vim.keymap.set("n", "<leader>tr", function()
      require("tuicr").run()
    end, { desc = "Tuicr review", silent = true })
  '';
}
