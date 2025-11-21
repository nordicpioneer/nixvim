{
  plugins.iron = {
    settings = {
      highlight = {italic = true;};
      keymaps = {
        toggle_repl = "<space>rr";
        restart_repl = "<space>rR";
        send_line = "<space>sl";
        send_motion = "<space>sc";
        send_file = "<space>sf";
        send_paragraph = "<space>sp";
        visual_send = "<space>sc";
      };
      repl_definition = {
        r = {
          command = ["R" "--no-save" "--quiet"];
          format = {
            __raw = "require('iron.fts.common').bracketed_paste_r";
          };
        };
        python = {
          command = ["python3"];
          format = {
            __raw = "require('iron.fts.common').bracketed_paste_python";
          };
          block_dividers = ["# %%" "#%%"];
        };
        sh = {command = ["bash" "zsh"];};
      };
      repl_open_cmd = {
        __raw = "require(\"iron.view\").bottom(40)";
      };
      scratch_repl = true;
    };
  };
}
