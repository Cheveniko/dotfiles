return {
  'kawre/leetcode.nvim',
  cmd = 'Leet',
  lazy = vim.fn.argv(0, -1) ~= 'leetcode.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {},
}
