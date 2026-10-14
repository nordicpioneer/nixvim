{pkgs, ...}: {
  plugins.diagram = {
    enable = true;
    settings = {
      integrations = [
        {__raw = "require('diagram.integrations.markdown')";}
      ];
      renderer_options.mermaid.theme = "dark";
    };
  };

  extraPackages = [
    pkgs.mermaid-cli
  ];
}
