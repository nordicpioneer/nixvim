# www-gem cli_task-nvim workflow (tasks.lua)
# https://www-gem.codeberg.page/cli_task-nvim/
# Source: https://codeberg.org/www-gem/Scripts (tasks.lua)
#
# Keymaps (leader = <Space> typically):
#   <leader>ta  create/update task from #TW line
#   <leader>td  delete task + line
#   <leader>tc  mark completed
#   <leader>ti  task info notify
#   <leader>tU  task undo (patched from <leader>tu to avoid clash with m_taskwarrior_d)
#
# Requires: taskwarrior (`task`), jq, and plugins.comment (gcc) on PATH/rtp.
{ pkgs, ... }:
let
  tasksLua = pkgs.fetchurl {
    url = "https://codeberg.org/www-gem/Scripts/raw/commit/b595892d99d432a7f4b6185743c839e4a0039903/tasks.lua";
    hash = "sha256-kt6OvS/fX5BRWFU1Os7JDT5S5ydNi2U1gpDSGdHz4I0=";
  };

  # Remap undo away from <leader>tu (used by m_taskwarrior_d TWUpdateCurrent)
  patchedTasksLua = pkgs.runCommand "cli-task-nvim-tasks.lua" { } ''
    substitute ${tasksLua} $out \
      --replace-fail 'vim.keymap.set("n", "<leader>tu"' 'vim.keymap.set("n", "<leader>tU"'
  '';
in
{
  extraFiles."lua/user_functions/tasks.lua".source = patchedTasksLua;

  extraConfigLua = ''
    require("user_functions.tasks")
  '';
}
