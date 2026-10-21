# Packaged zotcite LSP completion uses a 1-char textEdit range, so confirming a
# cmp item after typing @abc leaves the query prefix in the buffer. Widen the
# range to the full word after @ and set filterText so cmp does not drop hits.
final: prev: {
  vimPlugins =
    prev.vimPlugins
    // {
      zotcite = prev.vimPlugins.zotcite.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace lua/zotcite/lsp.lua \
              --replace-fail \
              'character = char - 1,' \
              'character = char - vim.fn.strchars(word),'
            substituteInPlace lua/zotcite/lsp.lua \
              --replace-fail \
              'kind = vim.lsp.protocol.CompletionItemKind.Variable,' \
              'kind = vim.lsp.protocol.CompletionItemKind.Variable,
                filterText = word .. " " .. nt .. " " .. txt,'
          '';
      });
    };
}
