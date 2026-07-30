{pkgs, ...}: {
  extraPackages = [pkgs.curl];

  extraPlugins = with pkgs.vimPlugins; [
    ai-nvim
    dante-nvim
  ];

  extraConfigLua = ''
    require("dante").setup({
      verbose = false,
      layout = "right",
      presets = {
        default = {
          client = {
            base_url = "http://nixctal:11343/v1",
            api_key = "ollama",
          },
          request = {
            model = "gemma4:e4b",
            temperature = 0.0001,
            stream = false,
          },
        },
      },
    })
  '';
}
