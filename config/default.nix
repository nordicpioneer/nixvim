_: {
  imports = [
    # General Configuration
    ./settings.nix
    ./keymaps.nix
    ./auto_cmds.nix
    ./file_types.nix

    # lsp completion
    ./cmp.nix
    # Themes
    ./themes.nix

    # ide
    ./ide.nix
  ];
}
