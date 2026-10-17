# Pin image.nvim >= 1.4.0 for wrap-correct positioning via vim.fn.screenpos
# (https://github.com/3rd/image.nvim/pull/266 — fixes #62).
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
    };
  };
}
