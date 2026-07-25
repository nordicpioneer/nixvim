# overlays/taskwarrior_nvim.nix
# https://github.com/MattHandzel/taskwarrior.nvim
final: prev: {
  vimPlugins = prev.vimPlugins // {
    taskwarrior-nvim = final.vimUtils.buildVimPlugin {
      pname = "taskwarrior.nvim";
      version = "0.0.0-d63edfc";

      src = final.fetchFromGitHub {
        owner = "MattHandzel";
        repo = "taskwarrior.nvim";
        rev = "d63edfcf14c515423d3ca1592c3414cd4dac19f8";
        hash = "sha256-RFhW4SCq2wJ2U+0hwZxeeKZ+CNBJfX1+Kvrbsv5Kgnw=";
      };
    };
  };
}
