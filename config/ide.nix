{
  plugins = {
    image = {
      enable = true;
      settings = {
        backend = "kitty";
        max_height = 12;
        max_height_window_percentage = {
          __raw = "math.huge";
        };
        max_width = 100;
        max_width_window_percentage = {
          __raw = "math.huge";
        };
        window_overlap_clear_enabled = true;
        window_overlap_clear_ft_ignore = [
          "cmp_menu"
          "cmp_docs"
          ""
        ];
      };
    };
    molten = {
      enable = true;
      settings = {
        auto_open_output = true;
        copy_output = false;
        enter_output_behavior = "open_then_enter";
        image_provider = "none";
        output_crop_border = true;
        output_show_more = false;
        output_virt_lines = false;
        output_win_border = [
          ""
          "━"
          ""
          ""
        ];
        output_win_cover_gutter = true;
        output_win_hide_on_leave = true;
        output_win_style = false;
        save_path = {
          __raw = "vim.fn.stdpath('data')..'/molten'";
        };
        show_mimetype_debug = false;
        use_border_highlights = false;
        virt_lines_off_by1 = false;
        wrap_output = false;
      };
    };
    quarto = {
      enable = true;
      settings = {
        backend = "kitty";
        max_height = 12;
        max_height_window_percentage = {
          __raw = "math.huge";
        };
        max_width = 100;
        max_width_window_percentage = {
          __raw = "math.huge";
        };
        window_overlap_clear_enabled = true;
        window_overlap_clear_ft_ignore = [
          "cmp_menu"
          "cmp_docs"
          ""
        ];
      };
    };
  };
  extraConfigLua = ''
  '';
}
