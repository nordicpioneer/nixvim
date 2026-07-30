{pkgs, ...}: {
  extraPackages = [pkgs.curl];

  extraPlugins = with pkgs.vimPlugins; [
    ai-nvim
    dante-nvim
  ];

  extraConfigLua = ''
    local client = {
      base_url = "http://nixctal:11343/v1",
      api_key = "ollama",
    }

    local function preset(model)
      return {
        client = client,
        request = {
          model = model,
          temperature = 0.0001,
          stream = false,
        },
      }
    end

    require("dante").setup({
      verbose = false,
      layout = "right",
      presets = {
        default = preset("gemma4:e2b"),
        e2b = preset("gemma4:e2b"),
        e4b = preset("gemma4:e4b"),
        g12 = preset("gemma4:12b"),
        tg4 = preset("translategemma:4b"),
        tg12 = preset("translategemma:12b"),
        q17 = preset("qwen3:1.7b"),
        q4i = preset("qwen3:4b-instruct"),
      },
    })
  '';
}
