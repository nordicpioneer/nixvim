# overlays/dante_nvim.nix
# https://github.com/S1M0N38/dante.nvim (depends on S1M0N38/ai.nvim)
final: prev: {
  vimPlugins = prev.vimPlugins // {
    ai-nvim = final.vimUtils.buildVimPlugin {
      pname = "ai.nvim";
      version = "0.0.0-d773fe5";

      src = final.fetchFromGitHub {
        owner = "S1M0N38";
        repo = "ai.nvim";
        rev = "d773fe5d8a06e3be5855ad60e1bdcffab33edc48";
        hash = "sha256-lsxW8KZq5QKou/IYldBtLJw0X8k8OVUyGYSNc5CDQ1k=";
      };
    };

    dante-nvim = final.vimUtils.buildVimPlugin {
      pname = "dante.nvim";
      version = "0.0.0-64208d2";

      src = final.fetchFromGitHub {
        owner = "S1M0N38";
        repo = "dante.nvim";
        rev = "64208d2b9123d5b794b805ceb1032c57d953298f";
        hash = "sha256-1vGn99RAjx1PAUHvyXsafRSljU9eTLn/BO+Mh4jZZ1A=";
      };

      dependencies = [final.vimPlugins.ai-nvim];
    };
  };
}
