# Pin a recent image.nvim for diagram.nvim / jet (markdown docs use snacks.image).
final: prev: {
  vimPlugins = prev.vimPlugins // {
    image-nvim = final.vimUtils.buildVimPlugin {
      pname = "image.nvim";
      version = "1.5.1";

      src = final.fetchFromGitHub {
        owner = "3rd";
        repo = "image.nvim";
        rev = "v1.5.1";
        hash = "sha256-brDtVYD3O+7N2RdQPIx2+6P+faXafoJDUITy0z0cIuA=";
      };

      # Example/repro script at repo root, not a loadable module
      nvimSkipModule = ["minimal-setup"];
    };
  };
}
