# overlays/tuicr_nvim.nix
# CLI is packaged here because the flake's locked nixpkgs does not yet
# include pkgs.tuicr; sources/hashes match nixpkgs-unstable's package.nix.
final: prev: {
  tuicr = final.callPackage ../pkgs/tuicr.nix {};

  vimPlugins = prev.vimPlugins // {
    tuicr-nvim = final.vimUtils.buildVimPlugin {
      pname = "tuicr.nvim";
      version = "0-unstable-2026-04-11";

      src = final.fetchFromGitHub {
        owner = "xendarboh";
        repo = "tuicr.nvim";
        rev = "8b84a000ecc2126ffd2394c188a23f83912779ea";
        hash = "sha256-HwDUq4aXRGLaoy6IgnMqldRCtlT0UrZKyhL4qqBOrds=";
      };
    };
  };
}
