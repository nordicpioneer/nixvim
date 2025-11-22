{pkgs, ...}: {
  extraPlugins = [
    {
      plugin = pkgs.vimUtils.buildVimPlugin {
        name = "r-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "R-nvim";
          repo = "r.nvim";
          rev = "382858fcf23aabbf47ff06279baf69d52260b939";
          hash = "sha256-j2rXXO7246Nh8U6XyX43nNTbrire9ta9Ono9Yr+Eh9M=";
        };
        nvimSkipModules = [
          "r.pdf.sumatra"
          "r.roxygen"
          "r.format"
        ];
      };
    }
  ];
  extraConfigLua = ''
    -- Extended R.nvim configuration (from docs)
    ---@type RConfigUserOpts
    local opts = {
      hook = {
        on_filetype = function()
          -- <CR> sends current line / selection to R
          vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
          vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})
        end,
      },
      R_args = { "--quiet", "--no-save" },
      min_editor_width = 72,
      rconsole_width = 78,
      objbr_mappings = {
        -- Object browser mappings
        c = "class",  -- call R functions
        ["<localleader>gg"] = "head({object}, n = 15)", -- {object} gets replaced
        v = function()
          -- Run Lua function: toggle object browser view
          require("r.browser").toggle_view()
        end,
      },
      disable_cmds = {
        "RClearConsole",
        "RCustomStart",
        "RSPlot",
        "RSaveClose",
      },
    }
    
    require("r").setup(opts)
  '';
}
