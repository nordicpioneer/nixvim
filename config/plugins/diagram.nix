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
in {
  plugins.diagram = {
    enable = true;
    settings = {
      integrations = [
        {__raw = "require('diagram.integrations.markdown')";}
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

  # Optional full-size view when inline image.nvim scaling is hard to read.
  # Cursor inside a mermaid/d2 fence → <leader>dg → diagram tab (q / Esc to close).
  extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown" },
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
