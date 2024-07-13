{
  plugins.obsidian = {
    enable = true;
    settings = {
      workspaces = [
        {
          name = "Personal";
          path = "~/github/Obsidian-backupfork";
        }
      ];
      templates = {
        subdir = "Templates";
        dateFormat = "%Y-%m-%d";
        timeFormat = "%H:%M";
        substitutions = {};
      };

      dailyNotes = {
        folder = "001 journals";
        dateFormat = "%Y-%m-%d";
        aliasFormat = "%B %-d, %Y";
      };
    };
  };
}
