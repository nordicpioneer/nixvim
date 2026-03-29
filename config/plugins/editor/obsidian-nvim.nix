{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.obsidian-nvim
  ];

  extraConfigLua = ''
    require("obsidian").setup({
      legacy_commands = false,

      frontmatter = {
        enabled = true,
      },

      note = {},

      workspaces = {
        {
          path = "~/personal/obsidian.personal",
          name = "personal",
          overrides = {
            templates = {
              folder = "050 Templates",
            },
          },
        }
      },

      daily_notes = {
        enabled = true,
        folder = "dagbok",
        date_format = "YYYY-MM-DD",
        default_tags = { "notater/dagbok" },
      },

      ui = {
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#008080" },
          ObsidianExtLinkIcon = { fg = "#008080" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },

      picker = {
        name = "telescope",
      },
    })  
  '';
}
