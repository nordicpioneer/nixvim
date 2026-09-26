{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [
    jet-nvim
    jet-ark
    jet-ipy
  ];

  # Make Ark/Jet/ipykernel kernelspecs discoverable; ImageMagick for Snacks.image
  extraPackages = [
    pkgs.ark
    pkgs.jet-cli
    pkgs.rEnv
    pkgs.pythonEnv
    pkgs.imagemagick
  ];

  extraConfigLuaPost = ''
    -- Jet Jupyter kernel supervisor (R via Ark, Python via ipykernel)
    vim.env.JUPYTER_PATH = table.concat({
      "${pkgs.ipykernel-spec}",
      vim.env.JUPYTER_PATH or "",
    }, ":")

    require("jet").setup({
      binary_path = "${pkgs.jet-cli}/bin/jet",
      library_path = "${pkgs.jet-cli}/lib/libjet_lua.${
      if pkgs.stdenv.hostPlatform.isDarwin
      then "dylib"
      else "so"
    }",
    })

    require("jet.ark").setup({
      ark_binary_path = "${pkgs.ark}/bin/ark",
    })

    require("jet.ipy").setup({})

    local jet_api = require("jet.api")
    local jet_range = require("jet.core.send.range")

    -- Snacks can leave jetimg blank after hide/show; re-attach shortly after enter
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = "*",
      group = vim.api.nvim_create_augroup("jet.img.refresh", { clear = true }),
      callback = function(ev)
        if vim.bo[ev.buf].filetype ~= "jetimg" and vim.bo[ev.buf].filetype ~= "image" then
          return
        end
        local session_id = vim.b[ev.buf].jet and vim.b[ev.buf].jet.session_id
        if not session_id then
          return
        end
        vim.defer_fn(function()
          if not vim.api.nvim_buf_is_valid(ev.buf) then
            return
          end
          local k = jet_api.get_kernel_by_id(session_id)
          if k and k.bufs and k.bufs.img then
            k.bufs.img:display()
          end
        end, 50)
      end,
    })

    local with_kernel = function(cb)
      jet_api.get_kernel({
        filetype = vim.bo.filetype,
        current = true,
        status = { "connected", "connecting" },
      }, cb)
    end

    local send_range = function(range)
      local code = range:code({ comments = false })
      if code then
        with_kernel(function(k)
          k:send_repl(code)
        end)
      end
    end

    local toggle_repl = function(ft)
      return function()
        jet_api.get_kernel({ filetype = ft }, function(k)
          k:term_toggle()
        end)
      end
    end

    -- REPL control: <leader>r*
    vim.keymap.set("n", "<leader>rr", toggle_repl("r"), { desc = "Toggle R (Jet)" })
    vim.keymap.set("n", "<leader>rp", toggle_repl("python"), { desc = "Toggle Python (Jet)" })
    vim.keymap.set("n", "<leader>rt", function()
      jet_api.get_kernel({ filetype = vim.bo.filetype }, function(k)
        k:term_toggle()
      end)
    end, { desc = "Toggle REPL (Jet)" })

    vim.keymap.set("n", "<leader>rR", function()
      local ft = vim.bo.filetype
      jet_api.get_kernel({
        filetype = ft,
        status = { "connected", "connecting", "disconnected", "unknown" },
      }, function(k)
        k:close("restart")
        vim.schedule(function()
          jet_api.get_kernel({ filetype = ft }, function(nk)
            nk:term_toggle()
          end)
        end)
      end)
    end, { desc = "Restart REPL (Jet)" })

    vim.keymap.set("n", "<leader>ri", function()
      with_kernel(function(k)
        k:interrupt()
      end)
    end, { desc = "Interrupt (Jet)" })

    vim.keymap.set("n", "<leader>rq", function()
      with_kernel(function(k)
        k:close("user")
      end)
    end, { desc = "Quit REPL (Jet)" })

    vim.keymap.set("n", "<leader>rc", function()
      with_kernel(function(k)
        local term = k.bufs and k.bufs.term
        if term and term.job_id then
          vim.fn.chansend(term.job_id, "\x0c")
        end
      end)
    end, { desc = "Clear REPL (Jet)" })

    vim.keymap.set("n", "<leader>rf", function()
      local buf = vim.api.nvim_get_current_buf()
      local line_count = vim.api.nvim_buf_line_count(buf)
      send_range(jet_range.new({
        buf = buf,
        start_row = 0,
        start_col = 0,
        end_row = line_count,
        end_col = 0,
      }))
    end, { desc = "Send file (Jet)" })

    -- Operator: go{motion} sends code to the matching Jet kernel
    local go_send = jet_api.handle_motion(function(range, filetype)
      jet_api.get_kernel({
        filetype = filetype,
        current = true,
        status = { "connected", "connecting" },
      }, function(k)
        local code = range:code({ comments = false })
        if code then
          k:send_repl(code)
        end
      end)
    end)

    vim.keymap.set({ "n", "x" }, "go", go_send, { desc = "Execute code (Jet)", expr = true })

    -- Expression textobject (enhanced for R/Python by jet.ark / jet.ipy)
    vim.keymap.set({ "x", "o" }, "ie", function()
      local expr = jet_api.get_expr()
      if not expr then
        local pos = jet_api.next_expr_boundary({
          current_ok = false,
          boundary = "start",
        })
        expr = pos and jet_api.get_expr(pos)
      end
      if expr then
        expr:textobject()
      end
    end, { desc = "textobject (jet): in expression" })

    vim.keymap.set("n", "]e", function()
      local pos = jet_api.next_expr_boundary({ direction = 1, boundary = "start" })
      if pos then
        vim.fn.cursor(pos:to_cursor())
      end
    end, { desc = "Next expression (Jet)" })

    vim.keymap.set("n", "[e", function()
      local pos = jet_api.next_expr_boundary({ direction = -1, boundary = "start" })
      if pos then
        vim.fn.cursor(pos:to_cursor())
      end
    end, { desc = "Previous expression (Jet)" })

    -- Enter sends only in code buffers (not ArkVars / jetrepl / other fts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "r", "rmd", "quarto", "python" },
      group = vim.api.nvim_create_augroup("jet.send.enter", { clear = true }),
      callback = function(ev)
        vim.keymap.set("n", "<Enter>", "goie]e", {
          buffer = ev.buf,
          remap = true,
          desc = "Send expression (Jet)",
        })
        vim.keymap.set("x", "<Enter>", "go", {
          buffer = ev.buf,
          remap = true,
          desc = "Send selection (Jet)",
        })
      end,
    })

    -- ArkVars Variables pane: Enter toggles expand (upstream uses Space)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "arkvars",
      group = vim.api.nvim_create_augroup("jet.arkvars.enter", { clear = true }),
      callback = function(ev)
        vim.keymap.set("n", "<CR>", " ", {
          buffer = ev.buf,
          remap = true,
          desc = "Toggle expand (ArkVars)",
        })
      end,
    })
  '';
}
