{
  description = "NPs nvim config for basic R and python development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixvim.url = "github:nix-community/nixvim";

    # OpenCode v1.14.31 Used by:
    #   ./overlays/opencode-openai-codex-auth.nix
    nixpkgs-opencode.url =
      "github:nixos/nixpkgs/73c703c22422b8951895a960959dbbaca7296492";
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
          overlays = import ./overlays {inherit inputs; };
          config = {
            allowUnfree = true;
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
        packages = {
          default = nvim;
          inherit (pkgs)
            opencode-openai-codex-auth
            opencode-with-auth;
        };
        devShells = {
          default = with pkgs;
            mkShell {
              packages = [
                nvim          # Neovim from nixvim
                pkgs.rEnv     # R runtime from overlay
                pkgs.opencode-with-auth # llm coding agents via different subscriptions, apis and providers
              ];

              shellHook = ''
                echo "loaded ide for R + Python"
              '';
            };
        };
      };
    };
}
