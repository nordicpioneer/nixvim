{pkgs, ...}: let
  # Chromium under Nix needs --no-sandbox; mmdc only accepts it via puppeteerConfigFile (-p).
  mermaidPuppeteerConfig = pkgs.writeText "mermaid-puppeteer.json" ''
    {"args":["--no-sandbox","--disable-setuid-sandbox"]}
  '';

  # d2 PNG export needs Playwright (broken CDN 404 on this package). Render SVG then rasterize.
  # d2 prints "success: ..." on stderr; diagram.nvim treats any stderr as a hard error + hit-enter,
  # so only forward stderr when the command actually fails.
  d2ForDiagram = pkgs.writeShellScriptBin "d2" ''
    set +e
    out_png=""
    for a in "$@"; do
      case "$a" in
        *.png) out_png="$a" ;;
      esac
    done

    run_quiet() {
      local err
      err=$(mktemp)
      "$@" > /dev/null 2>"$err"
      local ec=$?
      if [ $ec -ne 0 ]; then
        ${pkgs.coreutils}/bin/cat "$err" >&2
      fi
      ${pkgs.coreutils}/bin/rm -f "$err"
      return $ec
    }

    if [ -n "$out_png" ]; then
      svg="''${out_png%.png}.svg"
      args=()
      for a in "$@"; do
        if [ "$a" = "$out_png" ]; then
          args+=("$svg")
        else
          args+=("$a")
        fi
      done
      run_quiet ${pkgs.d2}/bin/d2 "''${args[@]}"
      ec=$?
      if [ $ec -eq 0 ] && [ -f "$svg" ]; then
        run_quiet ${pkgs.imagemagick}/bin/magick -background none "$svg" "$out_png"
        ec=$?
        ${pkgs.coreutils}/bin/rm -f "$svg"
      fi
      exit $ec
    fi

    run_quiet ${pkgs.d2}/bin/d2 "$@"
    exit $?
  '';

  # Extended markdown integration: filetype quarto/rmd + Quarto ```{mermaid} fences.
  markdownExtLua = ''
    local renderers = require("diagram/renderers")
    local ts_query = require("vim.treesitter.query")

    ---@type vim.treesitter.Query
    local query = nil

    local supported = {
      mermaid = true,
      plantuml = true,
      d2 = true,
      gnuplot = true,
    }

    ---Normalize fence info strings: "mermaid", "{mermaid}", "{mermaid echo=false}" → "mermaid"
    local function normalize_lang(info)
      if not info then
        return nil
      end
      info = info:gsub("^%s+", ""):gsub("%s+$", "")
      local braced = info:match("^%{([%w_+%-]+)")
      if braced then
        return braced
      end
      return info:match("^([%w_+%-]+)")
    end

    local M = {
      id = "markdown_ext",
      filetypes = { "markdown", "quarto", "rmd" },
      renderers = {
        renderers.mermaid,
        renderers.plantuml,
        renderers.d2,
        renderers.gnuplot,
      },
    }

    M.query_buffer_diagrams = function(bufnr)
      if not query then
        query = ts_query.parse("markdown", "(fenced_code_block (info_string) @info (code_fence_content) @code)")
      end

      local buf = bufnr or vim.api.nvim_get_current_buf()
      local parser = vim.treesitter.get_parser(buf, "markdown")
      parser:parse(true)

      local root = parser:parse()[1]:root()
      local matches = query:iter_captures(root, bufnr)

      ---@type Diagram[]
      local diagrams = {}
      local current_language = nil
      ---@type { start_row: number, start_col: number, end_row: number, end_col: number }
      local current_range = nil
      for id, node in matches do
        local key = query.captures[id]
        local value = vim.treesitter.get_node_text(node, bufnr)
        if node:parent():parent() and node:parent():parent():type() == "block_quote" then
          value = value:gsub("\n>", "\n"):gsub("^>", "")
        end

        if key == "info" then
          local start_row, _start_col, end_row, end_col = node:range()
          current_range = {
            start_row = start_row,
            start_col = 0,
            end_row = end_row,
            end_col = end_col,
          }
          current_language = normalize_lang(value)
        else
          if current_language and supported[current_language] then
            table.insert(diagrams, {
              bufnr = bufnr,
              renderer_id = current_language,
              source = value,
              range = current_range,
            })
          end
        end
      end

      return diagrams
    end

    return M
  '';
in {
  extraFiles."lua/diagram_integrations/markdown_ext.lua".text = markdownExtLua;

  plugins.diagram = {
    enable = true;
    settings = {
      integrations = [
        {__raw = "require('diagram_integrations.markdown_ext')";}
      ];
      renderer_options = {
        # Render resolution (PNG pixels). Independent of image.nvim inline display cap.
        # Needed so <leader>dg → o (system viewer) is sharp; cache is shared with inline preview.
        mermaid = {
          theme = "dark";
          background = "transparent";
          scale = 2;
          width = 2400;
          height = 1600;
          cli_args = [
            "-p"
            "${mermaidPuppeteerConfig}"
          ];
        };
        # Do not set d2.theme_id: CLI -t overrides vars.d2-config.theme-id in the source.
        # Per diagram: vars: { d2-config: { theme-id: 200 } }  # 200 Dark Mauve, 201 Dark Flagship, 0 Neutral
      };
    };
  };

  # Quarto/rmd buffers use the markdown treesitter grammar for fenced blocks.
  # Optional full-size view: cursor in fence → <leader>dg → diagram tab (q / Esc to close).
  extraConfigLua = ''
    vim.treesitter.language.register("markdown", "quarto")
    vim.treesitter.language.register("markdown", "rmd")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto", "rmd" },
      callback = function(ev)
        vim.keymap.set("n", "<leader>dg", function()
          require("diagram").show_diagram_hover()
        end, { buffer = ev.buf, desc = "Diagram: open at cursor" })
      end,
    })
  '';

  extraPackages = [
    pkgs.mermaid-cli
    d2ForDiagram
  ];
}
