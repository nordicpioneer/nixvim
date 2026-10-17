# Markdown writing helpers inspired by linkarzu/neobean (no vault-path hardcoding).
{pkgs, ...}: {
  extraPackages = [pkgs.trash-cli];

  plugins.which-key.settings.spec = [
    {
      __unkeyed-1 = "<leader>m";
      group = "markdown";
    }
  ];

  extraConfigLua = ''
    -- Bold: wrap word under cursor / visual selection with **, or unwrap if already bold
    local function toggle_bold_visual()
      local start_row, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
      local end_row, end_col = unpack(vim.fn.getpos("'>"), 2, 3)
      if start_row > end_row or (start_row == end_row and start_col > end_col) then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
      end
      local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
      if #lines == 0 then
        return
      end
      local selected
      if #lines == 1 then
        selected = lines[1]:sub(start_col, end_col)
      else
        lines[1] = lines[1]:sub(start_col)
        lines[#lines] = lines[#lines]:sub(1, end_col)
        selected = table.concat(lines, "\n")
      end
      local replacement
      if selected:match("^%*%*.*%*%*$") and #selected >= 4 then
        replacement = selected:sub(3, -3)
      else
        replacement = "**" .. selected .. "**"
      end
      local new_lines = vim.split(replacement, "\n", { plain = true })
      vim.api.nvim_buf_set_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, new_lines)
    end

    local function toggle_bold_normal()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local buf = vim.api.nvim_get_current_buf()
      local row = cursor_pos[1] - 1
      local col = cursor_pos[2]
      local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
      if line:sub(col + 1, col + 1):match("%*") then
        vim.notify("Cursor is on an asterisk, run inside the bold text", vim.log.levels.WARN)
        return
      end
      local left = line:sub(1, col)
      local right = line:sub(col + 1)
      local left_stars = left:reverse():find("%*%*")
      local right_stars = right:find("%*%*")
      if left_stars and right_stars then
        local bold_start = col - left_stars
        local bold_end = col + right_stars
        local inner = line:sub(bold_start + 2, bold_end - 1)
        local new_line = line:sub(1, bold_start - 1) .. inner .. line:sub(bold_end + 2)
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { new_line })
        return
      end
      -- Bold the word under cursor
      local cword = vim.fn.expand("<cword>")
      if cword == "" then
        return
      end
      local word_col = vim.fn.match(line, "\\<" .. vim.fn.escape(cword, "\\") .. "\\>")
      if word_col < 0 then
        return
      end
      -- Prefer the occurrence nearest the cursor
      local search_from = 0
      local best = word_col
      while word_col >= 0 do
        if math.abs(word_col - col) <= math.abs(best - col) then
          best = word_col
        end
        search_from = word_col + #cword
        word_col = vim.fn.match(line, "\\<" .. vim.fn.escape(cword, "\\") .. "\\>", search_from)
      end
      local new_line = line:sub(1, best)
        .. "**"
        .. cword
        .. "**"
        .. line:sub(best + #cword + 1)
      vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { new_line })
    end

    vim.keymap.set("v", "<leader>mb", function()
      toggle_bold_visual()
    end, { desc = "Markdown bold selection", silent = true })

    vim.keymap.set("n", "<leader>mb", function()
      toggle_bold_normal()
    end, { desc = "Markdown bold word/toggle", silent = true })

    -- Strikethrough visual selection with ~~
    vim.keymap.set("v", "<leader>mx", function()
      local start_row, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
      local end_row, end_col = unpack(vim.fn.getpos("'>"), 2, 3)
      if start_row > end_row or (start_row == end_row and start_col > end_col) then
        start_row, end_row = end_row, start_row
        start_col, end_col = end_col, start_col
      end
      local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
      if #lines == 0 then
        return
      end
      local selected
      if #lines == 1 then
        selected = lines[1]:sub(start_col, end_col)
      else
        lines[1] = lines[1]:sub(start_col)
        lines[#lines] = lines[#lines]:sub(1, end_col)
        selected = table.concat(lines, "\n")
      end
      local replacement
      if selected:match("^%~%~.*%~%~$") and #selected >= 4 then
        replacement = selected:sub(3, -3)
      else
        replacement = "~~" .. selected .. "~~"
      end
      local new_lines = vim.split(replacement, "\n", { plain = true })
      vim.api.nvim_buf_set_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, new_lines)
    end, { desc = "Markdown strikethrough selection", silent = true })

    -- Toggle leading "- " bullet on the current line
    vim.keymap.set("n", "<leader>md", function()
      local row = vim.api.nvim_win_get_cursor(0)[1] - 1
      local line = vim.api.nvim_get_current_line()
      local new_line
      if line:match("^(%s*)%- ") then
        new_line = line:gsub("^(%s*)%- ", "%1", 1)
      elseif line:match("^(%s*)%-") then
        new_line = line:gsub("^(%s*)%-", "%1", 1)
      else
        local indent = line:match("^(%s*)") or ""
        new_line = indent .. "- " .. line:sub(#indent + 1)
      end
      vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
    end, { desc = "Markdown toggle bullet", silent = true })

    -- Insert checkbox task (- [ ])
    vim.keymap.set({ "n", "i" }, "<leader>ml", function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.api.nvim_get_current_line()
      if line:match("^%s*$") then
        vim.api.nvim_set_current_line("- [ ] ")
        vim.api.nvim_win_set_cursor(0, { row, 6 })
      else
        local indent = line:match("^(%s*)") or ""
        vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. "- [ ] " })
        vim.api.nvim_win_set_cursor(0, { row + 1, #indent + 6 })
      end
      if vim.fn.mode() ~= "i" then
        vim.cmd("startinsert!")
      end
    end, { desc = "Markdown insert checkbox", silent = true })

    -- Neobean-style: trash current file after typing "del"
    vim.keymap.set("n", "<leader>fD", function()
      local current_file = vim.fn.expand("%:p")
      if not current_file or current_file == "" then
        vim.api.nvim_echo({ { "No file to delete", "WarningMsg" } }, false, {})
        return
      end
      if vim.fn.executable("trash") == 0 then
        vim.api.nvim_echo({
          { "Trash utility not installed (trash-cli).\n", "ErrorMsg" },
        }, false, {})
        return
      end
      vim.ui.input({
        prompt = "Type 'del' to delete the file '" .. current_file .. "': ",
      }, function(input)
        if input ~= "del" then
          vim.api.nvim_echo({ { "File deletion canceled.", "Normal" } }, false, {})
          return
        end
        local ok = pcall(function()
          vim.fn.system({ "trash", current_file })
          if vim.v.shell_error ~= 0 then
            error("trash failed")
          end
        end)
        if ok then
          vim.api.nvim_echo({
            { "File deleted from disk:\n", "Normal" },
            { current_file, "Normal" },
          }, false, {})
          vim.cmd("bd!")
        else
          vim.api.nvim_echo({
            { "Failed to delete file:\n", "ErrorMsg" },
            { current_file, "ErrorMsg" },
          }, false, {})
        end
      end)
    end, { desc = "Delete current file (trash)", silent = true })
  '';
}
