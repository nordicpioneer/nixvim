# MattHandzel/taskwarrior.nvim — edit Taskwarrior as a markdown buffer
# https://github.com/MattHandzel/taskwarrior.nvim
#
# Defaults kept except sort_key: <leader>ts is used by m_taskwarrior_d (TWSyncTasks).
#   <leader>ta  quick capture
#   <leader>tt  open task buffer (:Tw)
#   <leader>tf  filter (task buffer)
#   <leader>tS  sort (task buffer; remapped from <leader>ts)
#   <leader>tg  group (task buffer)
#   <leader>tpa register cwd as project
{ pkgs, ... }: {
  extraPlugins = [
    pkgs.vimPlugins.taskwarrior-nvim
  ];

  extraConfigLua = ''
    require("taskwarrior").setup({
      sort_key = "<leader>tS",
    })
  '';
}
