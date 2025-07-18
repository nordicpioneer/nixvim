{
  autoGroups = {
    filetypes = {};
  };

  files."ftdetect/bicepft.lua".autoCmd = [
    {
      group = "filetypes";
      event = ["BufRead" "BufNewFile"];
      pattern = ["*.bicep" "*.bicepparam"];
      command = "set ft=bicep";
    }
  ];
}
