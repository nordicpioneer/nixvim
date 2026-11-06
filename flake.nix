{
  description = "Nixvim config for R (jet.ark) and Python (jet.ipy) development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixvim.url = "github:nix-community/nixvim";

    # Ark (posit-dev) needs a newer nixpkgs/rustc than the main pin; used only for pkgs.ark
    nixpkgs-ark.url =
      "github:nixos/nixpkgs/4975466d324710c576dc11ad614684e6bd8cad8e";
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
            ark
            jet-cli
            tuicr;
        };
        devShells = {
          default = with pkgs;
            mkShell {
              packages = [
                nvim          # Neovim from nixvim
                pkgs.rEnv     # R runtime for Ark
                pkgs.ark      # Ark R Jupyter kernel
                pkgs.jet-cli  # Jet CLI + Lua lib
                pkgs.pythonEnv # Python + ipykernel
              ];

              shellHook = ''
                echo "loaded ide for R (jet.ark) + Python (jet.ipy)"
                export JUPYTER_PATH="${pkgs.ipykernel-spec}''${JUPYTER_PATH:+:$JUPYTER_PATH}"
              '';
            };
        };
      };
    };
}
