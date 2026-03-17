{pkgs, ...}: {
  extraPlugins = [
    pkgs.vimPlugins.obsidian-nvim
  ];

  extraConfigLua = ''
    require("obsidian").setup {
      legacy_commands = false,
      frontmatter = {
        enabled = true,
      },

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
    }
    picker = {
      name = "telescope",
    },
  '';
}
