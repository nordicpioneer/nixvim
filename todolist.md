
# General Configuration
- [x] ./settings.nix
- [x] ./keymaps.nix
- [x] ./auto_cmds.nix
    - Remove
        - ftdetect/terraformft.lua
        
- [x] ./file_types.nix
    - Remove file

# Themes
- [x] ./plugins/themes/default.nix
    - Removed integrations objects
        - neotree
        - notify
        - native_lsp
    - Keep
        - functionality
            - cmp
        - custom gui and formatting
            - gitsigns
            - which_key
            - illuminate (highlight other instances of word/varname
            - mini base16?
    - 
        
        

# Completion
./plugins/cmp/cmp.nix
./plugins/cmp/lspkind.nix

# Snippets
./plugins/snippets/luasnip.nix

# Editor plugins and configurations
./plugins/editor/neo-tree.nix
./plugins/editor/treesitter.nix
./plugins/editor/undotree.nix
./plugins/editor/illuminate.nix
./plugins/editor/indent-blankline.nix
./plugins/editor/todo-comments.nix
./plugins/editor/navic.nix

# UI plugins
./plugins/ui/bufferline.nix
./plugins/ui/lualine.nix
./plugins/ui/startup.nix

# LSP and formatting
./plugins/lsp/lsp.nix
./plugins/lsp/conform.nix
./plugins/lsp/fidget.nix

# Git
./plugins/git/lazygit.nix
./plugins/git/gitsigns.nix

# Utils
./plugins/utils/telescope.nix
./plugins/utils/whichkey.nix
./plugins/utils/extra_plugins.nix
./plugins/utils/mini.nix
./plugins/utils/markdown-preview.nix
./plugins/utils/obsidian.nix
