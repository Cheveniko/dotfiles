-- typescript-svelte-plugin (bundled with Mason's svelte-language-server) lets
-- ts_ls see .svelte files, so references, renames and definitions work across
-- .ts and .svelte. It only acts on .svelte files, so other projects are unaffected.
local svelte_ls = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'svelte-language-server')

return {
  -- `ts_ls` and `denols` already ship with complementary root resolution in
  -- nvim-lspconfig, so both can coexist in mixed Node/Deno repos.
  workspace_required = false,
  init_options = {
    plugins = vim.fn.isdirectory(svelte_ls) == 1 and {
      { name = 'typescript-svelte-plugin', location = svelte_ls },
    } or {},
  },
}
