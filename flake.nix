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
            mkShell {inherit shellHook;};
        };
      };
    };
}
