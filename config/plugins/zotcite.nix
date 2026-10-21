{pkgs, ...}: {
  plugins.zotcite = {
    enable = true;
    settings = {
      filetypes = ["markdown" "pandoc" "rmd" "quarto"];
      # Packaged zotcite (pynvim) uses SQL_path → env ZoteroSQLpath.
      SQL_path = "/home/adrian/Zotero/zotero.sqlite";
    };
  };

  extraPython3Packages = p: [p.pyyaml];
  extraPackages = [pkgs.sqlite];

  extraConfigLua = ''
    -- :Zcite → Telescope + insert on Enter
    -- :Zseek → same Telescope UI, Enter only echoes (no insert)
    vim.api.nvim_create_user_command("Zcite", function()
      require("zotcite.get").citation()
    end, { desc = "Zotcite: insert citation at cursor" })

    -- Pre-map Plug so packaged create_map does not bind <C-x><C-b>.
    vim.keymap.set("i", "<Plug>ZCite", function()
      require("zotcite.get").citation()
    end, { silent = true, desc = "Zotcite: insert citation" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "pandoc", "rmd", "quarto" },
      callback = function(ev)
        pcall(vim.keymap.del, "i", "<C-x><C-b>", { buffer = ev.buf })
      end,
    })

    -- #region agent log
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.schedule(function()
          local f = io.open("/home/adrian/personal/nixvim/.cursor/debug-2d9e4d.log", "a")
          if f then
            f:write(vim.json.encode({
              sessionId = "2d9e4d",
              runId = "commands-only",
              hypothesisId = "H14",
              location = "zotcite.nix:VimEnter",
              message = "commands-only build fingerprint",
              data = {
                probe = "commands-only-v1",
                progpath = vim.v.progpath,
                has_Zcite = vim.fn.exists(":Zcite") == 2,
                has_leader_zc = vim.fn.maparg("<leader>zc", "n") ~= "",
              },
              timestamp = os.time() * 1000,
            }) .. "\n")
            f:close()
          end
        end)
      end,
    })
    -- #endregion
  '';
}
