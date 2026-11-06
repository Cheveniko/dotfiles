local save_folds_group = vim.api.nvim_create_augroup('save-folds', { clear = true })

vim.api.nvim_create_autocmd('BufWinLeave', {
  desc = 'Save existing buffer folds',
  group = save_folds_group,
  pattern = '*.*',
  command = 'mkview',
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Load existing buffer folds',
  group = save_folds_group,
  pattern = '*.*',
  command = 'silent! loadview',
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('config-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
