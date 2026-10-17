{ inputs }:
# add {inherit inputs; } if separate flake input is needed in overlay
[
  (import ./jet.nix { inherit inputs; })
  (import ./m_taskwarrior_d.nix)
  (import ./dante_nvim.nix)
  (import ./image_nvim.nix)
  (import ./opencode-openai-codex-auth.nix { inherit inputs; })
]
