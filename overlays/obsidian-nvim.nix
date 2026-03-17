# overlays/obsidian-nvim.nix
final: prev: {
  vimPlugins = prev.vimPlugins // {
    obsidian-nvim = final.vimUtils.buildVimPlugin {
      pname = "obsidian.nvim";
      version = "3.16.0";

      src = final.fetchFromGitHub {
        owner = "obsidian-nvim";
        repo  = "obsidian.nvim";
        rev   = "v3.16.0";
        hash  = "sha256-XqabbTbH3iiSsvEslac9ChIiH6LdJ1vOEYjnmgc42jw=";
      };

      doCheck = false;

      # no required dependencies
    };
  };
}
