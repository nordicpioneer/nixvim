# overlays/m_taskwarrior_d.nix
final: prev: {
  vimPlugins = prev.vimPlugins // {
    m_taskwarrior_d = final.vimUtils.buildVimPlugin {
      pname = "m_taskwarrior_d.nvim";
      version = "0.10.0";

      src = final.fetchFromGitHub {
        owner = "huantrinh1802";
        repo  = "m_taskwarrior_d.nvim";
        rev   = "v0.10.0";
        hash = "sha256-N2xwOoDxWSdp0cqkl1WHuSFeO1lypDsB35PpEa061W8=";
      };

      runtimeDeps = [
        final.vimPlugins.nui-nvim
      ];
    };
  };
}
