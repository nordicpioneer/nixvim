{ inputs }:

final: prev:

let
  opencodePkgs = import inputs.nixpkgs-opencode {
    system = final.stdenv.hostPlatform.system;

    config = {
      allowUnfree = true;
    };
  };
in {
  opencode = opencodePkgs.opencode;

  opencode-openai-codex-auth =
    final.callPackage ../pkgs/opencode-openai-codex-auth.nix {};

  opencode-with-auth =
    prev.writeShellScriptBin "opencode" ''
      export NODE_PATH="${final.opencode-openai-codex-auth}/lib/node_modules"
      exec ${final.opencode}/bin/opencode "$@"
    '';
}
