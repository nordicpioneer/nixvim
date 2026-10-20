{pkgs, ...}: let
  # Chromium under Nix needs --no-sandbox; mmdc only accepts it via puppeteerConfigFile (-p).
  mermaidPuppeteerConfig = pkgs.writeText "mermaid-puppeteer.json" ''
    {"args":["--no-sandbox","--disable-setuid-sandbox"]}
  '';
in {
  plugins.snacks = {
    enable = true;
    settings = {
      input.enabled = true;
      picker.enabled = true;
      terminal.enabled = true;
      # Inline markdown images + ```mermaid with soft-wrap (unicode placeholders).
      # image.nvim markdown integration is disabled — it misplaces Kitty
      # graphics when wrap is on (even with PR #266 / v1.5.1). Keep
      # image.nvim for diagram.nvim (d2/plantuml/…) / jet programmatic rendering.
      # Mermaid fences: snacks only (diagram.nvim mermaid disabled — dual render).
      image = {
        enabled = true;
        doc = {
          enabled = true;
          inline = true;
          float = true;
          max_width = 80;
          max_height = 40;
        };
        convert.mermaid.__raw = ''
          function()
            local theme = vim.o.background == "light" and "neutral" or "dark"
            return {
              "-i", "{src}",
              "-o", "{file}",
              "-b", "transparent",
              "-t", theme,
              "-s", "{scale}",
              "-p", "${mermaidPuppeteerConfig}",
            }
          end
        '';
      };
    };
  };

  extraPackages = [pkgs.mermaid-cli];
}
