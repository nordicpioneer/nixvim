# overlays/jet.nix — jet.nvim + jet.ark + jet.ipy + Ark/Jet binaries
{ inputs }:
final: prev:
let
  inherit (final) lib stdenv fetchurl fetchFromGitHub;

  # Ark needs newer rustc than the main flake nixpkgs; pull the binary from a
  # pinned nixpkgs that already packages it (binary-cache friendly).
  arkPkgs = import inputs.nixpkgs-ark {
    system = final.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };

  jetVersion = "0.0.8";

  # Prebuilt Jet releases (wurli/jet). pkgs.jet in nixpkgs is unrelated (borkdude/jet).
  jetTarget =
    if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64 then
      "x86_64-unknown-linux-gnu"
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64 then
      "aarch64-unknown-linux-gnu"
    else if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
      "aarch64-apple-darwin"
    else
      throw "wurli/jet ${jetVersion}: no prebuilt binary for ${stdenv.hostPlatform.system}";

  jetHashes = {
    "x86_64-unknown-linux-gnu" = {
      bin = "sha256-UmbZ0T4WpCVNYgTZJoNNwU1BL/ClO4NVo8OgGmkZ5dw=";
      lib = "sha256-/lobr9BIw/uzBRgqdd6iCxLxsHmDfUCTJ9wChQizGao=";
    };
    "aarch64-unknown-linux-gnu" = {
      bin = "sha256-tnYlkIqsKQXKEJag4CbqTg+UrDTb1H0hjn5sGfb9MHM=";
      lib = "sha256-8UjcAa2731A6gHB9GcJXi4vI4VjpmHwEtdTnUBGMtfs=";
    };
    "aarch64-apple-darwin" = {
      bin = "sha256-dZ6udjLzOb2IB0bIf8cIfDXYC6symNZw5ollaKAncqY=";
      lib = "sha256-76kjFapHJ0HI7exyYQGYY6QDsDg61R6TeVQrY63iU6c=";
    };
  };

  jetHashesFor = jetHashes.${jetTarget};

  # R env for Ark (no nvimcom / languageserver — Ark provides session LSP)
  rEnv = prev.radianWrapper.override {
    wrapR = true;
  };

  # Prefer Ark from nixpkgs-ark; ensure our rEnv is on PATH for R_HOME / packages.
  ark = final.writeShellScriptBin "ark" ''
    export PATH="${rEnv}/bin''${PATH:+:$PATH}"
    # Prefer R libraries from rEnv when set
    if [ -z "''${R_LIBS_SITE:-}" ]; then
      export R_LIBS_SITE="$(${lib.getExe' rEnv "Rscript"} -e 'cat(Sys.getenv("R_LIBS_SITE"))')"
    fi
    exec ${arkPkgs.ark}/bin/ark "$@"
  '';

  jetBinSrc = fetchurl {
    url = "https://github.com/wurli/jet/releases/download/v${jetVersion}/jet-${jetTarget}.tar.gz";
    hash = jetHashesFor.bin;
  };

  jetLibSrc = fetchurl {
    url = "https://github.com/wurli/jet/releases/download/v${jetVersion}/jet_lua-${jetTarget}.tar.gz";
    hash = jetHashesFor.lib;
  };

  # Combine Jet CLI + Lua module into one package
  jet-cli = stdenv.mkDerivation {
    pname = "jet-cli";
    version = jetVersion;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ final.autoPatchelfHook ];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib
      tar -xzf ${jetBinSrc} -C $out/bin --strip-components=1
      tar -xzf ${jetLibSrc} -C $out/lib --strip-components=1
      # Keep only the binary and shared library
      find $out/bin -type f ! -name jet -delete
      find $out/lib -type f ! -name 'libjet_lua.*' -delete
      chmod +x $out/bin/jet
      runHook postInstall
    '';

    meta = {
      description = "Jet Jupyter kernel supervisor CLI and Lua library (wurli/jet)";
      homepage = "https://github.com/wurli/jet";
      license = lib.licenses.mit;
      mainProgram = "jet";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  };

  # Default ipykernel kernelspec for Jet (project venvs still preferred by jet.ipy)
  pythonEnv = final.python3.withPackages (ps: [ ps.ipykernel ]);

  ipykernel-spec = final.runCommand "ipykernel-spec" { } ''
    mkdir -p $out/kernels/python3
    cat > $out/kernels/python3/kernel.json <<EOF
    {
      "argv": [
        "${pythonEnv}/bin/python",
        "-m",
        "ipykernel_launcher",
        "-f",
        "{connection_file}"
      ],
      "display_name": "Python 3 (nix)",
      "language": "python"
    }
    EOF
  '';
in
{
  inherit rEnv ark jet-cli ipykernel-spec pythonEnv;

  vimPlugins = prev.vimPlugins // {
    jet-nvim = final.vimUtils.buildVimPlugin {
      pname = "jet.nvim";
      version = "0.3.0-505c7e5";
      src = fetchFromGitHub {
        owner = "wurli";
        repo = "jet.nvim";
        rev = "505c7e578d96dec40df33f57c1e3c33d51c30973";
        hash = "sha256-+O5jWecU+rFt7/gxP7iCmt26lujSOuypF1GyphpPBJQ=";
      };
      # jet.core.engine requires libjet_lua via package.loadlib at require-time
      doCheck = false;
      runtimeDeps = [ jet-cli ];
    };

    jet-ark = final.vimUtils.buildVimPlugin {
      pname = "jet.ark";
      version = "0.0.0-dc16a50";
      src = fetchFromGitHub {
        owner = "wurli";
        repo = "jet.ark";
        rev = "dc16a50005bc87226dfff35e3ee00c553f332512";
        hash = "sha256-4BlBYhs8UHSh9tL7HSVtCm7/4SFkjhZN968JvSmM8Zg=";
      };
      dependencies = [ final.vimPlugins.jet-nvim ];
      doCheck = false;
      runtimeDeps = [
        ark
        rEnv
      ];
    };

    jet-ipy = final.vimUtils.buildVimPlugin {
      pname = "jet.ipy";
      version = "0.0.0-34f5d97";
      src = fetchFromGitHub {
        owner = "wurli";
        repo = "jet.ipy";
        rev = "34f5d97fc059578b4b05d7825633001a619f941e";
        hash = "sha256-lyHTv1/LCSNNUq2t9aqoG2OwLCeCL/hZYRN0vzhiH0w=";
      };
      dependencies = [ final.vimPlugins.jet-nvim ];
      doCheck = false;
      runtimeDeps = [
        pythonEnv
        ipykernel-spec
      ];
    };
  };
}
