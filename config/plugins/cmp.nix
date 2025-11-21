{
  plugins = {
    cmp = {
      enable = true;
      settings = {
        autoEnableSources = true;
        sources = [
          {name = "git";}
          {name = "nvim_lsp";}
          {name = "emoji";}
          {
            name = "buffer"; # text within current buffer
            option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
            keywordLength = 3;
          }
          {
            name = "path"; # file system paths
            keywordLength = 3;
          }
          {
            name = "luasnip"; # snippets
            keywordLength = 3;
          }
        ];
      };
    };
    #cmp-treesitter = {enable = true;};
    cmp-git = {enable = true;}; # git
    cmp-nvim-lsp = {enable = true;}; # lsp
    cmp-emoji = {enable = true;};
    cmp-buffer = {enable = true;}; # text within current buffer
    cmp-path = {enable = true;}; # file system paths
    cmp_luasnip = {enable = true;}; # snippets - completion source for nvim-cmp
    cmp-cmdline = {enable = false;}; # autocomplete for cmdline
    cmp-dictionary = {enable = true;};
    cmp-pandoc-references = {enable = true;};
    cmp-pandoc-nvim = {enable = true;};
  };
  extraConfigLua = ''
        luasnip = require("luasnip")
        kind_icons = {
          Text = "󰊄",
          Method = " ",
          Function = "󰡱 ",
          Constructor = " ",
          Field = " ",
          Variable = "󱀍 ",
          Class = " ",
          Interface = " ",
          Module = "󰕳 ",
          Property = " ",
          Unit = " ",
          Value = " ",
          Enum = " ",
          Keyword = " ",
          Snippet = " ",
          Color = " ",
          File = "",
          Reference = " ",
          Folder = " ",
          EnumMember = " ",
          Constant = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        } 

         local cmp = require'cmp'

     -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
     cmp.setup.cmdline({'/', "?" }, {
       sources = {
         { name = 'buffer' }
       }
     })

    -- Set configuration for specific filetype.
     cmp.setup.filetype('gitcommit', {
       sources = cmp.config.sources({
         { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
       }, {
         { name = 'buffer' },
       })
     })

     -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
     cmp.setup.cmdline(':', {
       sources = cmp.config.sources({
         { name = 'path' }
       }, {
         { name = 'cmdline' }
       }),
     })  '';
}
