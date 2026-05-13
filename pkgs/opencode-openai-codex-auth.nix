{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script ? null,
}:

buildNpmPackage (finalAttrs: {
  pname = "opencode-openai-codex-auth";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "numman-ali";
    repo = "opencode-openai-codex-auth";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Kz2n5BpHqirc2AxE4huJJ5LOPyy9jVOydQnqE+AlZOc=";
  };

  npmDepsHash = "sha256-YioaOUkDoC9j/vwtQ+tlg8vBCTobM0rlbiBvqyMUNpA=";

  passthru =
    lib.optionalAttrs (nix-update-script != null) {
      updateScript = nix-update-script { };
    };

  meta = {
    description = "OpenAI Codex authentication plugin for OpenCode";
    homepage = "https://github.com/numman-ali/opencode-openai-codex-auth";
    changelog = "https://github.com/numman-ali/opencode-openai-codex-auth/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
