return {
  'saghen/blink.cmp',
  version = '1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'default',
      ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
    },
    completion = {
      documentation = { auto_show = true },
      accept = { auto_brackets = { enabled = true } },
    },
    enabled = function()
      return not vim.tbl_contains({ 'gitcommit', 'DressingInput', 'AvanteInput' }, vim.bo.filetype)
    end,
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      per_filetype = {
        sql = { 'snippets', 'dadbod', 'buffer' },
        mysql = { 'snippets', 'dadbod', 'buffer' },
        plsql = { 'snippets', 'dadbod', 'buffer' },
      },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
        dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
      },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
  },
  opts_extend = { 'sources.default' },
}
