{pkgs, ...}: {
  # nui.nvim is also pulled in by m_taskwarrior_d; listed here so this module stands alone.
  extraPlugins = [
    pkgs.vimPlugins.nui-nvim
  ];

  extraPackages = [
    pkgs.taskwarrior-tui
  ];

  extraConfigLua = ''
    vim.keymap.set("n", "<leader>tt", function()
      local Popup = require("nui.popup")
      local event = require("nui.utils.autocmd").event

      local popup = Popup({
        enter = true,
        focusable = true,
        border = {
          style = "rounded",
          text = {
            top = " taskwarrior-tui ",
            top_align = "center",
          },
        },
        position = "50%",
        size = {
          width = "90%",
          height = "85%",
        },
      })

      popup:mount()
      vim.cmd("terminal taskwarrior-tui")
      vim.cmd("startinsert")

      popup:on(event.TermClose, function()
        popup:unmount()
      end)

      vim.keymap.set("n", "q", function()
        popup:unmount()
      end, { buffer = popup.bufnr, silent = true, desc = "Close taskwarrior-tui" })
    end, { desc = "Taskwarrior TUI", silent = true })
  '';
}
