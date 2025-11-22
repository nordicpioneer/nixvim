{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.r-nvim #imported as overlay declared in overlay/r-nvim.nix
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
