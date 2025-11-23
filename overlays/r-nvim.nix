# overlays/r-nvim.nix
final: prev: {
  # 1) Add nvimcom as an R package, built from the R.nvim repo
  rPackages = prev.rPackages // {
    nvimcom = final.rPackages.buildRPackage {
      name = "nvimcom";
      src = final.fetchFromGitHub {
        owner = "R-nvim";
        repo  = "R.nvim";
        rev   = "v0.99.1";
        sha256 = "sha256-GUnRsFF6MlUcFfEsNmm0zXauG3+Pf22OOJNXszOvs+M=";
      };
      sourceRoot = "source/nvimcom";
    };
  };

  # 2) rEnv = radianWrapper + extra R packages (languageserver + nvimcom)
  rEnv = prev.radianWrapper.override {
    wrapR = true;
    recommendedPackages =
      prev.radianWrapper.recommendedPackages
      ++ (with final.rPackages; [
        languageserver
        nvimcom
      ]);
  };

  # 3) R.nvim plugin with rEnv as runtime dependency
  vimPlugins = prev.vimPlugins // {
    r-nvim = final.vimUtils.buildVimPlugin {
      pname = "R.nvim";
      version = "2025-08-20"; # arbitrary label
      src = final.fetchFromGitHub {
        owner = "R-nvim";
        repo  = "R.nvim";
        rev   = "v0.99.1";
        sha256 = "sha256-GUnRsFF6MlUcFfEsNmm0zXauG3+Pf22OOJNXszOvs+M=";
      };
      # rEnv will be pulled into the Neovim runtime as a dependency
      runtimeDeps = [ final.rEnv ];
    };
  };
}

