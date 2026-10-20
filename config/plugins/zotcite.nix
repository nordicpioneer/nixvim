{pkgs, ...}: {
  plugins.zotcite = {
    enable = true;
    settings = {
      filetypes = ["markdown" "pandoc" "rmd" "quarto"];
      key_type = "template";
      # Pin default profile; multi-Path= auto-discovery is unreliable.
      zotero_sqlite_path = "/home/adrian/Zotero/zotero.sqlite";
    };
  };

  extraPackages = [pkgs.sqlite];
}
