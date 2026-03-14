{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.m_taskwarrior_d #imported as overlay declared in overlay/...
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

    -- Keymaps
    vim.keymap.set("n", "<leader>te", "<cmd>TWEditTask<cr>", { desc = "TaskWarrior Edit", silent = true })
    vim.keymap.set("n", "<leader>tv", "<cmd>TWView<cr>", { silent = true })
    vim.keymap.set("n", "<leader>tu", "<cmd>TWUpdateCurrent<cr>", { silent = true })
    vim.keymap.set("n", "<leader>ts", "<cmd>TWSyncTasks<cr>", { silent = true })
    vim.keymap.set("n", "<C-Space>", "<cmd>TWToggle<cr>", { silent = true })

    -- Auto sync Markdown buffers
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePre" }, {
      group = vim.api.nvim_create_augroup("TWTask", { clear = true }),
      pattern = { "*.md", "*.markdown" },
      callback = function()
        vim.cmd("TWBufQueryTasks")
        vim.cmd("TWSyncTasks")
      end,
    })
  '';
}

