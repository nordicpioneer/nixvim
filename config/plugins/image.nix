{
  plugins.image = {
    enable = true;
    settings = {
      backend = "kitty";
      max_height_window_percentage = 50;
      # Markdown/HTML docs: snacks.image (soft-wrap safe). Keep this plugin
      # for diagram.nvim / jet / hijack of standalone image files.
      integrations = {
        markdown.enabled = false;
        html.enabled = false;
        css.enabled = false;
      };
    };
  };

  # Soft-wrap for markdown; snacks.image owns inline doc images.
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto", "rmd" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
      end,
    })
  '';
}
