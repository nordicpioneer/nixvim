{
  plugins = {
    cmp = {
      enable = true;
      settings = {
        autoEnableSources = true;
        # nixvim does not ship default insert mappings; without these the
        # menu can open/filter but Tab / C-n / C-p / CR cannot select.
        mapping = {
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = ''
            cmp.mapping(function(fallback)
              local ls = require("luasnip")
              if cmp.visible() then
                cmp.select_next_item()
              elseif ls.expand_or_jumpable() then
                ls.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" })
          '';
          "<S-Tab>" = ''
            cmp.mapping(function(fallback)
              local ls = require("luasnip")
              if cmp.visible() then
                cmp.select_prev_item()
              elseif ls.jumpable(-1) then
                ls.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" })
          '';
        };
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
     })

     -- Re-apply insert mappings after other cmp.setup.* calls (preserve sources).
     do
       local cur = cmp.get_config()
       cmp.setup(vim.tbl_deep_extend("force", cur, {
         mapping = cmp.mapping.preset.insert({
           ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
           ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
           ["<C-b>"] = cmp.mapping.scroll_docs(-4),
           ["<C-f>"] = cmp.mapping.scroll_docs(4),
           ["<C-Space>"] = cmp.mapping.complete(),
           ["<C-e>"] = cmp.mapping.abort(),
           ["<CR>"] = cmp.mapping.confirm({ select = true }),
           ["<Tab>"] = cmp.mapping(function(fallback)
             local ls = require("luasnip")
             if cmp.visible() then
               cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
             elseif ls.expand_or_jumpable() then
               ls.expand_or_jump()
             else
               fallback()
             end
           end, { "i", "s" }),
           ["<S-Tab>"] = cmp.mapping(function(fallback)
             local ls = require("luasnip")
             if cmp.visible() then
               cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
             elseif ls.jumpable(-1) then
               ls.jump(-1)
             else
               fallback()
             end
           end, { "i", "s" }),
         }),
       }))
     end

     -- #region agent log
     cmp.event:on("menu_opened", function()
       local keys = {}
       for k, _ in pairs(cmp.get_config().mapping or {}) do
         keys[#keys + 1] = tostring(k)
       end
       table.sort(keys)
       local f = io.open("/home/adrian/personal/nixvim/.cursor/debug-2d9e4d.log", "a")
       if f then
         f:write(vim.json.encode({
           sessionId = "2d9e4d",
           runId = "cmp-menu",
           hypothesisId = "H10",
           location = "cmp.nix:menu_opened",
           message = "cmp menu opened",
           data = {
             visible = cmp.visible(),
             mapping_keys = keys,
             progpath = vim.v.progpath,
             pumvisible = vim.fn.pumvisible(),
           },
           timestamp = os.time() * 1000,
         }) .. "\n")
         f:close()
       end
     end)
     -- #endregion
  '';
}
