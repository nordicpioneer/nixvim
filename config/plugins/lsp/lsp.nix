{pkgs, ...}: {
  plugins = {
    lsp-lines = {enable = true;};
    lsp-format = {enable = true;};
    helm = {enable = true;};
    lsp = {
      enable = true;
      servers = {
        markdown_oxide = {
          enable = true;
          # dynamicRegistration is required for Create Unresolved File (and similar)
          extraOptions = {
            capabilities.__raw = ''
              (function()
                local caps = vim.lsp.protocol.make_client_capabilities()
                caps = vim.tbl_deep_extend(
                  "force",
                  caps,
                  require("cmp_nvim_lsp").default_capabilities()
                )
                caps.workspace = caps.workspace or {}
                caps.workspace.didChangeWatchedFiles =
                  caps.workspace.didChangeWatchedFiles or {}
                caps.workspace.didChangeWatchedFiles.dynamicRegistration = true
                return caps
              end)()
            '';
            # Vault activity spam; silence like neobean
            handlers."window/logMessage".__raw = "function() end";
          };
        };
        # R LSP comes from jet.ark (Ark session-aware); do not enable r_language_server
        pyright = {enable = true;};
        html = {enable = true;};
        lua_ls = {enable = true;};
      };

      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gr = {
            action = "references";
            desc = "Goto References";
          };
          gD = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          gI = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          gT = {
            action = "type_definition";
            desc = "Type Definition";
          };
          "<leader>cw" = {
            action = "workspace_symbol";
            desc = "Workspace Symbol";
          };
          # K / <leader>ca via lspsaga (keymaps.extra); rename via extraConfigLua + wall
        };
        diagnostic = {
          "<leader>cd" = {
            action = "open_float";
            desc = "Line Diagnostics";
          };
          "[d" = {
            action = "goto_next";
            desc = "Next Diagnostic";
          };
          "]d" = {
            action = "goto_prev";
            desc = "Previous Diagnostic";
          };
        };
        extra = [
          {
            key = "K";
            action = "<cmd>Lspsaga hover_doc<cr>";
            options.desc = "Hover (Lspsaga)";
          }
          {
            key = "<leader>ca";
            action = "<cmd>Lspsaga code_action<cr>";
            options.desc = "Code Action (Lspsaga)";
          }
        ];
      };
    };
  };
  extraPlugins = with pkgs.vimPlugins; [
    ansible-vim
  ];

  extraConfigLua = ''
    local _border = "rounded"

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, {
        border = _border
      }
    )

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, {
        border = _border
      }
    )

    vim.diagnostic.config{
      float={border=_border}
    };

    require('lspconfig.ui.windows').default_options = {
      border = _border
    }

    local function nixvim_wiki_at_cursor()
      local line = vim.api.nvim_get_current_line()
      local _, col = unpack(vim.api.nvim_win_get_cursor(0))
      for s, inner, e in line:gmatch("()%[%[([^%]]+)%]%]()") do
        if col + 1 >= s and col + 1 < e then
          local title = vim.trim(inner:match("^([^|#]+)") or "")
          return title, s + 2, inner, line
        end
      end
      return nil, nil, nil, line
    end

    local function nixvim_find_notes_by_stem(stem, root)
      if not stem or stem == "" or not root then
        return {}
      end
      local want = (stem .. ".md"):lower()
      return vim.fs.find(function(name)
        return name:lower() == want
      end, { path = root, type = "file", limit = 20 })
    end

    -- Oxide's in-memory index often drops the note after RenameFile; push
    -- watch events and didOpen the new path so [[wikilink]] / gd resolve again.
    local function nixvim_oxide_refresh_renames(client, renames)
      for _, r in ipairs(renames) do
        pcall(function()
          client:notify("workspace/didRenameFiles", {
            files = { { oldUri = r.old, newUri = r.new } },
          })
        end)
        pcall(function()
          client:notify("workspace/didChangeWatchedFiles", {
            changes = {
              { uri = r.old, type = 3 }, -- Deleted
              { uri = r.new, type = 1 }, -- Created
              { uri = r.new, type = 2 }, -- Changed
            },
          })
        end)
        local path = vim.uri_to_fname(r.new)
        local b = vim.fn.bufadd(path)
        vim.fn.bufload(b)
        if vim.bo[b].filetype ~= "markdown" then
          vim.bo[b].filetype = "markdown"
        end
      end
      vim.cmd("silent! wall")
    end

    local function nixvim_bounce_markdown_oxide(bufnr)
      local cfgs = {}
      for _, c in ipairs(vim.lsp.get_clients({ name = "markdown_oxide" })) do
        table.insert(cfgs, vim.deepcopy(c.config))
        pcall(function()
          c:stop(true)
        end)
      end
      for _, cfg in ipairs(cfgs) do
        pcall(vim.lsp.start, cfg)
      end
      vim.wait(3000, function()
        return #vim.lsp.get_clients({ bufnr = bufnr, name = "markdown_oxide" }) > 0
      end)
      return vim.lsp.get_clients({ bufnr = bufnr, name = "markdown_oxide" })[1]
    end

    -- gd: LSP definition, then filesystem fallback for [[wikilinks]] when oxide
    -- index is stale after a rename (link text valid but definition empty).
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto", "rmd" },
      callback = function(ev)
        vim.keymap.set("n", "gd", function()
          local bufnr = ev.buf
          local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/definition" })
          local title = nixvim_wiki_at_cursor()
          local function fs_fallback()
            if not title or title == "" then
              vim.notify("No definition found", vim.log.levels.WARN)
              return
            end
            local root = (clients[1] and clients[1].root_dir) or vim.fn.getcwd()
            local matches = nixvim_find_notes_by_stem(title, root)
            if #matches > 0 then
              vim.cmd.edit(vim.fn.fnameescape(matches[1]))
            else
              vim.notify("No note file for [[" .. title .. "]]", vim.log.levels.WARN)
            end
          end
          if #clients == 0 then
            fs_fallback()
            return
          end
          local client = clients[1]
          local params = vim.lsp.util.make_position_params(0, client.offset_encoding or "utf-16")
          client:request("textDocument/definition", params, function(err, result, ctx, config)
            local empty = result == nil
              or (vim.islist(result) and #result == 0)
              or (type(result) == "table" and not result.uri and not result.targetUri and not result[1])
            if not empty then
              vim.lsp.handlers["textDocument/definition"](err, result, ctx, config)
              return
            end
            fs_fallback()
          end, bufnr)
        end, { buffer = ev.buf, silent = true, desc = "Goto Definition" })
      end,
    })

    -- Rename: on [[wikilink]], resolve definition first, then rename that
    -- note (or update link text only if unresolved). Mid-link <cword> rename
    -- often targets the wrong file.
    vim.keymap.set("n", "<leader>cr", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_get_current_line()
      local current_uri = vim.uri_from_bufnr(bufnr)

      local wiki_inner, wiki_inner_start_byte = nil, nil
      for s, inner, e in line:gmatch("()%[%[([^%]]+)%]%]()") do
        if col + 1 >= s and col + 1 < e then
          wiki_inner = inner
          -- s = first '['; inner text starts two bytes later (after "[[")
          wiki_inner_start_byte = s + 2
          break
        end
      end
      local rename_default = wiki_inner and vim.trim(wiki_inner:match("^([^|#]+)") or "") or nil

      local function wall_after()
        local group = vim.api.nvim_create_augroup("NixvimSaveAfterLspRename", { clear = true })
        local autocmd
        autocmd = vim.api.nvim_create_autocmd("LspRequest", {
          group = group,
          callback = function(ev)
            local request = ev.data and ev.data.request
            if not request or request.method ~= "textDocument/rename" or request.type ~= "complete" then
              return
            end
            if autocmd then
              pcall(vim.api.nvim_del_autocmd, autocmd)
            end
            vim.schedule(function()
              vim.cmd("silent! wall")
            end)
          end,
        })
      end

      local function encoding_for(client)
        return (client and client.offset_encoding) or "utf-16"
      end

      local function byte_to_character(line_text, byte_1based, enc)
        local byte_0 = math.max(byte_1based - 1, 0)
        if enc == "utf-8" then
          return byte_0
        end
        local ok, idx = pcall(vim.str_utfindex, line_text, enc, byte_0)
        if ok then
          return idx
        end
        ok, idx = pcall(vim.str_utfindex, line_text, byte_0)
        if ok then
          return idx
        end
        return byte_0
      end

      local function replace_wikilink_title(old_title, new_title)
        if not wiki_inner or not wiki_inner_start_byte then
          return false
        end
        local suffix = wiki_inner:sub(#old_title + 1)
        local new_inner = new_title .. suffix
        local new_line = line:sub(1, wiki_inner_start_byte - 1)
          .. new_inner
          .. line:sub(wiki_inner_start_byte + #wiki_inner)
        vim.api.nvim_set_current_line(new_line)
        return true
      end

      -- Oxide rename-at-wikilink often renames the *current* buffer, not the
      -- definition target. Always send textDocument/rename against the note URI
      -- we intend to rename (definition / fs match), never against the link site.
      local function apply_rename_on_uri(doc_uri, line_0, char_0, new_name, expected_old_uri)
        local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/rename" })
        if #clients == 0 then
          vim.notify("No LSP client supports rename", vim.log.levels.WARN)
          return
        end
        wall_after()
        local client = clients[1]
        local enc = encoding_for(client)
        local params = {
          textDocument = { uri = doc_uri },
          position = { line = line_0, character = char_0 },
          newName = new_name,
        }
        client:request("textDocument/rename", params, function(err, result)
          local renames = {}
          if result and result.documentChanges then
            for _, ch in ipairs(result.documentChanges) do
              if ch.kind == "rename" then
                table.insert(renames, { old = ch.oldUri, new = ch.newUri })
              end
            end
          end
          if err then
            vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR)
            return
          end
          if not result then
            local old_path = vim.uri_to_fname(doc_uri)
            local new_path = vim.fn.fnamemodify(old_path, ":h") .. "/" .. new_name .. ".md"
            local ok_ren, ren_err = vim.uv.fs_rename(old_path, new_path)
            if not ok_ren then
              vim.notify("Rename: no LSP edits and fs rename failed: " .. tostring(ren_err), vim.log.levels.ERROR)
              return
            end
            replace_wikilink_title(rename_default, new_name)
            local old_buf = vim.fn.bufnr(old_path)
            if old_buf ~= -1 then
              pcall(vim.api.nvim_buf_set_name, old_buf, new_path)
            end
            nixvim_oxide_refresh_renames(client, {
              { old = vim.uri_from_fname(old_path), new = vim.uri_from_fname(new_path) },
            })
            vim.notify("Renamed note file (fs): " .. vim.fn.fnamemodify(new_path, ":t"), vim.log.levels.INFO)
            return
          end
          if expected_old_uri and result.documentChanges then
            for _, ch in ipairs(result.documentChanges) do
              if ch.kind == "rename" and ch.oldUri ~= expected_old_uri then
                local old_path = vim.uri_to_fname(expected_old_uri)
                local new_path = vim.fn.fnamemodify(old_path, ":h") .. "/" .. new_name .. ".md"
                local ok_ren, ren_err = vim.uv.fs_rename(old_path, new_path)
                if ok_ren then
                  replace_wikilink_title(rename_default, new_name)
                  local old_buf = vim.fn.bufnr(old_path)
                  if old_buf ~= -1 then
                    pcall(vim.api.nvim_buf_set_name, old_buf, new_path)
                  end
                  nixvim_oxide_refresh_renames(client, {
                    { old = vim.uri_from_fname(old_path), new = vim.uri_from_fname(new_path) },
                  })
                  vim.notify(
                    "LSP targeted the wrong file; renamed definition note via filesystem.",
                    vim.log.levels.WARN
                  )
                else
                  vim.notify(
                    "Rename aborted (wrong LSP target) and fs rename failed: " .. tostring(ren_err),
                    vim.log.levels.ERROR
                  )
                end
                return
              end
            end
          end
          vim.lsp.util.apply_workspace_edit(result, enc)
          -- Ensure wikilink under cursor title matches new_name
          do
            local cur_line = vim.api.nvim_get_current_line()
            local _, c = unpack(vim.api.nvim_win_get_cursor(0))
            for s, inner, e in cur_line:gmatch("()%[%[([^%]]+)%]%]()") do
              if c + 1 >= s and c + 1 < e then
                local old_title = vim.trim(inner:match("^([^|#]+)") or "")
                if old_title ~= new_name then
                  local suffix = inner:sub(#old_title + 1)
                  local new_line = cur_line:sub(1, s + 1) .. new_name .. suffix .. cur_line:sub(e - 2)
                  vim.api.nvim_set_current_line(new_line)
                end
                break
              end
            end
          end
          vim.cmd("silent! wall")
          if #renames > 0 then
            nixvim_oxide_refresh_renames(client, renames)
          end

          -- If oxide index is still stale, bounce the client once
          local ver_byte = wiki_inner_start_byte
            or (select(2, unpack(vim.api.nvim_win_get_cursor(0))) + 1)
          local ver_char = byte_to_character(vim.api.nvim_get_current_line(), ver_byte, enc)
          client:request("textDocument/definition", {
            textDocument = vim.lsp.util.make_text_document_params(bufnr),
            position = { line = row - 1, character = ver_char },
          }, function(_, def_result)
            local ok = type(def_result) == "table"
              and (def_result.uri or def_result.targetUri
                or (vim.islist(def_result) and def_result[1]
                  and (def_result[1].uri or def_result[1].targetUri)))
            if not ok and #renames > 0 then
              nixvim_bounce_markdown_oxide(bufnr)
            end
          end, bufnr)
        end, bufnr)
      end

      local function rename_via_definition(new_name, char_0)
        local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/definition" })
        if #clients == 0 then
          clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/rename" })
        end
        if #clients == 0 then
          vim.notify("No markdown LSP client attached", vim.log.levels.WARN)
          return
        end
        local client = clients[1]
        local def_params = {
          textDocument = vim.lsp.util.make_text_document_params(bufnr),
          position = { line = row - 1, character = char_0 },
        }
        client:request("textDocument/definition", def_params, function(_, result)
          local target_uri = nil
          if type(result) == "table" then
            if result.uri then
              target_uri = result.uri
            elseif result.targetUri then
              target_uri = result.targetUri
            elseif vim.islist(result) and result[1] then
              target_uri = result[1].uri or result[1].targetUri
            end
          end

          if target_uri then
            if target_uri == current_uri then
              vim.notify(
                "[[" .. rename_default .. "]] resolves to this note. Renaming this file.",
                vim.log.levels.INFO
              )
            else
              vim.notify(
                "Renaming definition target: " .. vim.fn.fnamemodify(vim.uri_to_fname(target_uri), ":t"),
                vim.log.levels.INFO
              )
            end
            apply_rename_on_uri(target_uri, 0, 0, new_name, target_uri)
            return
          end

          local root = client.root_dir or vim.fn.getcwd()
          local matches = nixvim_find_notes_by_stem(rename_default, root)
          if #matches == 1 then
            local path = matches[1]
            local turi = vim.uri_from_fname(path)
            vim.notify("Renaming note file: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
            apply_rename_on_uri(turi, 0, 0, new_name, turi)
            return
          end

          if replace_wikilink_title(rename_default, new_name) then
            vim.notify(
              "Unresolved [[" .. rename_default .. "]]: updated link text only (no note file renamed).",
              vim.log.levels.WARN
            )
          else
            vim.notify("Could not update wikilink text", vim.log.levels.ERROR)
          end
        end, bufnr)
      end

      if rename_default and rename_default ~= "" and wiki_inner_start_byte then
        vim.ui.input({ prompt = "Rename note: ", default = rename_default }, function(input)
          if not input or input == "" then
            return
          end
          local char_0 = byte_to_character(line, wiki_inner_start_byte, encoding_for(
            (vim.lsp.get_clients({ bufnr = bufnr })[1])
          ))
          rename_via_definition(input, char_0)
        end)
      else
        wall_after()
        vim.lsp.buf.rename()
      end
    end, { desc = "Rename", silent = true })
  '';
}
