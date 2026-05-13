{ pkgs, ... }:

{

extraPackages = [
  pkgs.opencode-with-auth
];

extraPlugins = with pkgs.vimPlugins; [
  opencode-nvim
];

extraConfigLua = ''
  vim.g.opencode_opts = {
    server = {
      port = 4096,
    },
  }

  vim.o.autoread = true

  local opencode = require("opencode")

  vim.keymap.set({ "n", "x" }, "<leader>ya", function()
    opencode.ask("@this: ", { submit = true })
  end, { desc = "Ask opencode" })

  vim.keymap.set({ "n", "x" }, "<leader>yx", function()
    opencode.select()
  end, { desc = "Execute opencode action" })

  vim.keymap.set({ "n", "t" }, "<leader>yt", function()
    opencode.toggle()
  end, { desc = "Toggle opencode" })

  vim.keymap.set({ "n", "x" }, "<leader>yo", function()
    return opencode.operator("@this ")
  end, {
    desc = "Add range to opencode",
    expr = true,
  })

  vim.keymap.set("n", "<leader>yoo", function()
    return opencode.operator("@this ") .. "_"
  end, {
    desc = "Add line to opencode",
    expr = true,
  })

  vim.keymap.set("n", "<leader>yu", function()
    opencode.command("session.half.page.up")
  end, { desc = "Scroll opencode up" })

  vim.keymap.set("n", "<leader>yd", function()
    opencode.command("session.half.page.down")
  end, { desc = "Scroll opencode down" })
'';

}
