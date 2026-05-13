{
  description = "NPs nvim config for basic R and python development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixvim.url = "github:nix-community/nixvim";

    # OpenCode v1.14.30 Used by:
    #   ./overlays/opencode-openai-codex-auth.nix
    # v1.14.35 segfaulted on aarch64-linux here, while v1.14.30 works
    # with opencode-openai-codex-auth browser subscription login.
    nixpkgs-opencode.url =
      "github:nixos/nixpkgs/c6d65881c5624c9cae5ea6cedef24699b0c0a4c0";
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
                mkdir -p "$HOME/.config/opencode"

                cp ${./config/opencode.json} "$HOME/.config/opencode/opencode.json"
                chmod u+w "$HOME/.config/opencode/opencode.json"
              '';
            };
        };
      };
    };
}
