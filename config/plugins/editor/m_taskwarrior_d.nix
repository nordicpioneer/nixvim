{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.nui-nvim # required by m_taskwarrior_d UI (TWView / edit popups)
    pkgs.vimPlugins.m_taskwarrior_d # imported as overlay declared in overlay/...
  ];
  extraConfigLua = ''
    require("m_taskwarrior_d").setup({
      -- Status handling
      task_statuses = { " ", ">", "x", "~" },
      status_map = {
        [" "] = "pending",
        [">"] = "active",
        ["x"] = "completed",
        ["~"] = "deleted",
      },

      -- Checkbox formatting
      list_pattern = { lua = "[%-%*%+]", vim = "[\\-\\*\\+]" },
      checkbox_prefix = "[",
      checkbox_suffix = "]",
      default_list_symbol = "-",

      -- Comments (leave empty unless using Markdown preview tricks)
      comment_prefix = "",
      comment_suffix = "",

      -- Trigger on Markdown
      file_patterns = { "*.md", "*.markdown" },

      display_due_or_scheduled = true,
    })

    -- Upstream apply_context_data does #next_line without nil checks when past EOF.
    do
      local utils = require("m_taskwarrior_d.utils")
      local orig_get_line = utils.get_line
      utils.get_line = function(line_number)
        local line, num = orig_get_line(line_number)
        if line == nil then
          return "", num
        end
        return line, num
      end
    end

    -- Keymaps (manual sync only — no BufEnter/BufWritePre auto-sync.
    -- Auto-sync raced with LSP rename bufload and crashed on nil uuid.)
    vim.keymap.set("n", "<leader>te", "<cmd>TWEditTask<cr>", { desc = "TaskWarrior Edit", silent = true })
    vim.keymap.set("n", "<leader>tv", "<cmd>TWView<cr>", { silent = true })
    vim.keymap.set("n", "<leader>tu", "<cmd>TWUpdateCurrent<cr>", { silent = true })
    vim.keymap.set("n", "<leader>ts", "<cmd>TWSyncTasks<cr>", { desc = "TaskWarrior Sync", silent = true })
    vim.keymap.set("n", "<C-Space>", "<cmd>TWToggle<cr>", { silent = true })
  '';
}
