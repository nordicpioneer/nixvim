{ inputs }:
# add {inherit inputs; } if separate flake input is needed in overlay
[
  (import ./r-nvim.nix)
  (import ./m_taskwarrior_d.nix)
  (import ./taskwarrior_nvim.nix)
  (import ./opencode-openai-codex-auth.nix { inherit inputs; })
]
