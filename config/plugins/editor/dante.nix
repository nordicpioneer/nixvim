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

    -- Non-default presets are not deep-merged with dante's built-in default
    -- request.messages; include them explicitly.
    local messages = {
      {
        role = "system",
        content = [[
You are an assistant responsible for correcting errors in text.
Refine the spelling and grammar while closely adhering to the original version.

- If the text is formatted in a specific syntax (e.g., LaTeX, Markdown, Vimdoc, ...), abide by that syntax.
- Use the same language and terminology appropriate for the context.
- Return only the enhanced text without commentary.
- Maintain the integrity of the original text's line breaks and spacing (i.e., follow the original text's `\n`)

Do NOT return the generated text enclosed in triple ticks (```).
]],
      },
      {
        role = "user",
        content = "{{SELECTED_LINES}}",
      },
    }

    local function preset(model)
      return {
        client = client,
        request = {
          model = model,
          temperature = 0.0001,
          stream = false,
          messages = messages,
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
