{
  plugins.image = {
    enable = true;
    settings = {
      backend = "kitty";
      max_height_window_percentage = 50;
      # Enable image.nvim debug log for scroll/overlap diagnosis
      debug = {
        enabled = true;
        level = "debug";
        file_path = "/tmp/image.nvim.debug.log";
        format = "compact";
      };
    };
  };

  # Keep soft-wrap for markdown; positioning relies on image.nvim >= 1.4
  # screenpos renderer (PR #266 / overlay image_nvim.nix → v1.5.1).
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto", "rmd" },
      callback = function()
        vim.opt_local.wrap = true
      end,
    })

    -- #region agent log
    local logpath = "/home/adrian/personal/nixvim/.cursor/debug-2d9e4d.log"
    local function dbg(hid, msg, data)
      local f = io.open(logpath, "a")
      if not f then return end
      f:write(vim.json.encode({
        sessionId = "2d9e4d",
        runId = "post-fix-pr266",
        hypothesisId = hid,
        location = "image.nix",
        message = msg,
        data = data,
        timestamp = os.time() * 1000,
      }) .. "\n")
      f:close()
    end

    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinScrolled", "CursorMoved" }, {
      pattern = { "*.md", "*.qmd", "*.Rmd" },
      callback = function(ev)
        local ok_img, image = pcall(require, "image")
        if not ok_img then
          dbg("H1", "image module missing", { event = ev.event })
          return
        end
        local win = vim.api.nvim_get_current_win()
        local buf = vim.api.nvim_get_current_buf()
        local wininfo = vim.fn.getwininfo(win)[1] or {}
        local imgs = {}
        local ok_get, list = pcall(function()
          return image.get_images({ window = win, buffer = buf })
        end)
        if ok_get and list then
          for _, img in ipairs(list) do
            table.insert(imgs, {
              id = img.id,
              rendered = img.is_rendered,
              x = img.geometry and img.geometry.x or vim.NIL,
              y = img.geometry and img.geometry.y or vim.NIL,
              width = img.image_width or (img.geometry and img.geometry.width) or vim.NIL,
              height = img.image_height or (img.geometry and img.geometry.height) or vim.NIL,
              path = img.path or vim.NIL,
            })
          end
        end
        local rm_ok, rm = pcall(require, "render-markdown")
        local rm_enabled = false
        if rm_ok and rm.get then
          local st = rm.get()
          rm_enabled = st == true or (type(st) == "table" and st.enabled == true)
        end
        local image_src = nil
        pcall(function()
          image_src = debug.getinfo(image.get_images).source
        end)
        dbg("H6", "image state " .. ev.event, {
          event = ev.event,
          filetype = vim.bo[buf].filetype,
          wrap = vim.wo[win].wrap,
          linebreak = vim.wo[win].linebreak,
          win_width = vim.api.nvim_win_get_width(win),
          win_height = vim.api.nvim_win_get_height(win),
          topline = wininfo.topline,
          botline = wininfo.botline,
          cursor = vim.api.nvim_win_get_cursor(0),
          image_count = #imgs,
          images = imgs,
          render_markdown = rm_enabled,
          conceallevel = vim.wo[win].conceallevel,
          image_module = image_src or vim.NIL,
        })
      end,
    })
    -- #endregion
  '';
}
