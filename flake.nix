{
  description = "NPs nvim config for basic R and python development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };

  outputs = {
    nixpkgs,
    nixvim,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = { system, pkgs, self', lib, ... }: 
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = import ./overlays;  # overlays/default.nix → list of overlays
          config = {
            allowUnfreePredicate = pkg:
              builtins.elem (lib.getName pkg) [
                "claude-code"
              ];
          };
        };
        nixvim' = nixvim.legacyPackages.${system};
        nvim = nixvim'.makeNixvimWithModule {
          inherit pkgs;
          module = ./config;
        };
      in {
        packages.default = nvim;
        devShells = {
          default = with pkgs;
            mkShell {
              packages = [
                nvim          # Neovim from nixvim
                pkgs.rEnv     # R runtime from overlay
                #pkgs.python312
                #pkgs.python312Packages.python-lsp-server
              ];

              shellHook = ''
                echo "loaded ide for R + Python"
              '';
            };
        };
      };
    };
}
