return {
  'mg979/vim-visual-multi',
  init = function()
    vim.g.VM_maps = {
      ['Add Cursor Down'] = '<leader><down>',
      ['Add Cursor Up'] = '<leader><up>',
    }
  end,
}
