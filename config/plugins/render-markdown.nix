{
  plugins.render-markdown = {
    enable = true;
    settings = {
      file_types = ["markdown" "quarto" "rmd"];
      ignore.__raw = ''
        function(buf)
          return vim.api.nvim_buf_get_name(buf):match("fffile preview$") ~= nil
        end
      '';
      bullet.enabled = true;
      checkbox = {
        enabled = true;
        position = "inline";
        unchecked = {
          icon = " 󰄱 ";
          highlight = "RenderMarkdownUnchecked";
        };
        checked = {
          icon = " 󰱒 ";
          highlight = "RenderMarkdownChecked";
        };
      };
      html = {
        enabled = true;
        comment.conceal = false;
      };
      link = {
        image = "󰥶 ";
        custom.youtu = {
          pattern = "youtu%.be";
          icon = "󰗃 ";
        };
      };
      heading = {
        sign = false;
        icons = ["󰎤 " "󰎧 " "󰎪 " "󰎭 " "󰎱 " "󰎳 "];
      };
      # Neobean: no codeblock chrome without transparent bg
      code.style = "none";
    };
  };
}
