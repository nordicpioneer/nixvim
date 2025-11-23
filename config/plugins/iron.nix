{
  plugins.iron.enable = true;

  extraConfigLua = ''
    local iron   = require("iron.core")
    local view   = require("iron.view")
    local common = require("iron.fts.common")

    iron.setup {
      highlight = { italic = true },
      scratch_repl = true,


      -- where to open REPL
      repl_open_cmd = "botright vertical split",

      repl_definition = {
        r = {
          command = { "radian", "--quiet", "--no-save" },
          format = common.bracketed_paste_r,
        },
        python = {
          command = { "ipython" },
          format = common.bracketed_paste_python,
          block_dividers = { "# %%", "##%%", "#%%" },
        },
        sh = {
          command = { "zsh" },
        },
      },

      -- ⭐ Preferred REPL executables
      preferred = {
        r = "radian",
        python = "ipython",
      },

      -- 🚀 Usable default keymaps
      keymaps = {
        toggle_repl       = "<space>rr",
        restart_repl      = "<space>rR",

        send_motion       = "<space>sm",
        visual_send       = "<space>sc",
        send_line         = "<space>sl",
        send_file         = "<space>sf",
        send_paragraph    = "<space>sp",
        send_until_cursor = "<space>su",

        cr        = "<space>s<CR>",
        interrupt = "<space>s<Space>",
        exit      = "<space>sq>",
        clear     = "<space>cl>",
      },
    }

  '';
}
