-- Work around Neovim 0.12.1 Tree-sitter crashes on markdown fenced code blocks.
-- We keep markdown/MDX injections that don't rely on fenced blocks, but disable
-- fenced-code injections until the core bug is fixed upstream.
vim.treesitter.query.set('markdown', 'injections', [[
((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))

((inline) @injection.content
  (#lua-match? @injection.content "^%s*import")
  (#set! injection.language "typescript"))

((inline) @injection.content
  (#lua-match? @injection.content "^%s*export")
  (#set! injection.language "typescriptreact"))

((inline) @injection.content
  (#lua-match? @injection.content "^<")
  (#set! injection.language "typescriptreact"))

((indented_code_block) @injection.content
  (#lua-match? @injection.content "^%s*<")
  (#set! injection.language "typescriptreact")
  (#set! injection.include-children))

((html_block) @injection.content
  (#set! injection.language "typescriptreact")
  (#set! injection.include-children))
]])
