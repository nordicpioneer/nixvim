{
  plugins.mini-hipatterns = {
    enable = true;
    settings = {
      highlighters = {
        hex_color = {
          __raw = ''
            require("mini.hipatterns").gen_highlighter.hex_color()
          '';
        };
      };
    };
  };
}
