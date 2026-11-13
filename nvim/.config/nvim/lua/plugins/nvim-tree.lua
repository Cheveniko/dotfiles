local function my_on_attach(bufnr)
  local api = require 'nvim-tree.api'

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)
  vim.keymap.set('n', 'J', api.node.navigate.sibling.next, opts 'Next Sibling')
  vim.keymap.set('n', 'K', api.node.navigate.sibling.prev, opts 'Previous Sibling')
  vim.keymap.del('n', '>', opts 'Increase Width')
  vim.keymap.del('n', '<', opts 'Decrease Width')

  local swap_then_open_tab = function()
    local node = api.tree.get_node_under_cursor()
    vim.cmd 'wincmd l'
    api.node.open.tab(node)
    vim.cmd 'NvimTreeOpen'
    vim.cmd 'wincmd l'
  end

  vim.keymap.set('n', '<C-t>', swap_then_open_tab, opts 'Open in new tab')
end

return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  cmd = {
    'NvimTreeToggle',
    'NvimTreeOpen',
    'NvimTreeClose',
    'NvimTreeFocus',
    'NvimTreeFindFile',
    'NvimTreeFindFileToggle',
    'NvimTreeRefresh',
    'NvimTreeCollapse',
    'NvimTreeResize',
  },
  keys = { { '<C-f>', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle file tree' } },
  init = function()
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('config-nvim-tree-directory', { clear = true }),
      callback = function(event)
        if vim.fn.isdirectory(event.file) == 1 then
          -- Match nvim-tree's own directory hijack, which also changes the cwd.
          vim.cmd.cd(vim.fn.fnameescape(event.file))
          require('nvim-tree.api').tree.open { path = event.file }
        end
      end,
    })
  end,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('nvim-tree').setup {
      on_attach = my_on_attach,
      update_focused_file = {
        enable = true,
      },
      live_filter = {
        prefix = '[FILTER]: ',
        always_show_folders = false,
      },
    }
  end,
}
