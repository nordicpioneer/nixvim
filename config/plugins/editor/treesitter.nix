{pkgs, ...}: {
  plugins = {
    treesitter = {
      enable = true;
      folding = false;
      nixvimInjections = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
    };

    # ui context for functions, loops, objects etc.
    treesitter-context = {
      enable = true;
    };

    # refactor objects
    treesitter-refactor = {
      enable = true;
      settings = {
        smart_rename = {
          enable = true;
          keymaps.smart_rename = "grr";
        };
        highlight_current_scope.enable = true;
      };
    };

    treesitter-textobjects = {
      enable = true;

      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
            "ii" = "@conditional.inner";
            "ai" = "@conditional.outer";
            "il" = "@loop.inner";
            "al" = "@loop.outer";
            "at" = "@comment.outer";
          };
        };

        move = {
          enable = true;
          goto_next_start = {
            "]m" = "@function.outer";
            "]]" = "@class.outer";
          };
          goto_next_end = {
            "]M" = "@function.outer";
            "][" = "@class.outer";
          };
          goto_previous_start = {
            "[m" = "@function.outer";
            "[[" = "@class.outer";
          };
          goto_previous_end = {
            "[M" = "@function.outer";
            "[]" = "@class.outer";
          };
        };

        swap = {
          enable = true;
          swap_next = {
            "<leader>a" = "@parameter.inner";
          };
          swap_previous = {
            "<leader>A" = "@parameter.outer";
          };
        };
      };
    };
  };
}
