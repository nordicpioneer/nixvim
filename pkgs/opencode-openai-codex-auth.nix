{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "opencode-openai-codex-auth";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "numman-ali";
    repo = "opencode-openai-codex-auth";
    rev = "v${version}";
    hash = "sha256-Kz2n5BpHqirc2AxE4huJJ5LOPyy9jVOydQnqE+AlZOc=";
  };

  npmDepsHash = "sha256-YioaOUkDoC9j/vwtQ+tlg8vBCTobM0rlbiBvqyMUNpA=";

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    local target="$out/lib/node_modules/opencode-openai-codex-auth"

    mkdir -p "$target"

    cp -r ./* "$target"/

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex auth plugin for OpenCode";
    homepage = "https://github.com/numman-ali/opencode-openai-codex-auth";
    license = licenses.mit;
  };
}
