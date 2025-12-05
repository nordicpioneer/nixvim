_: {
  imports = [
    # General Configuration
    ./settings.nix
    ./keymaps.nix
    ./auto_cmds.nix

    # Themes and UI
    ./plugins/themes.nix
    ./plugins/web-devicons.nix
    #    ./plugins/bufferline.nix
    ./plugins/startup.nix
    ./plugins/mini-hipatterns.nix
    ./plugins/bullets.nix

    # Completion
    ./plugins/cmp.nix

    # Snippets
    #    ./plugins/snippets/luasnip.nix

    # Editor plugins and configurations
    ./plugins/mini-files.nix
    ./plugins/mini-jump2d.nix
    ./plugins/comment.nix
    ./plugins/editor/treesitter.nix
    # +10 // line 10
    #  plugins.treesitter-textobjects = {
    #    enable = false;

    ./plugins/editor/undotree.nix
    ./plugins/editor/illuminate.nix
    ./plugins/editor/indent-blankline.nix
    ./plugins/editor/todo-comments.nix

    # LSP and formatting
    ./plugins/lsp/lsp.nix

    # Git
    ./plugins/git/lazygit.nix
    ./plugins/git/gitsigns.nix

    # Utils
    ./plugins/telescope.nix
    ./plugins/whichkey.nix
    #./plugins/r-nvim.nix
    #./plugins/iron.nix
  ];
}
