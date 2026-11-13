local save_folds_group = vim.api.nvim_create_augroup('save-folds', { clear = true })

local function is_normal_file(buf)
  return vim.bo[buf].buftype == ''
    and vim.api.nvim_buf_get_name(buf) ~= ''
    and vim.fn.filereadable(vim.api.nvim_buf_get_name(buf)) == 1
end

vim.api.nvim_create_autocmd('BufWinLeave', {
  desc = 'Save existing buffer folds',
  group = save_folds_group,
  callback = function(event)
    if is_normal_file(event.buf) then
      vim.cmd.mkview()
    end
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Load existing buffer folds',
  group = save_folds_group,
  callback = function(event)
    if is_normal_file(event.buf) then
      vim.cmd 'silent! loadview'
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('config-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
