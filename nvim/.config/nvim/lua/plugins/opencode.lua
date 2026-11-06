return {
  'sudo-tee/opencode.nvim',
  config = function()
    local function insert_newline()
      local enter = vim.api.nvim_replace_termcodes('<cr>', true, false, true)
      vim.api.nvim_feedkeys(enter, 'n', false)
    end

    require('opencode').setup {
      keymap = {
        editor = {
          ['<leader>oc'] = { 'quick_chat', mode = { 'n', 'x' }, desc = 'Quick chat' },
        },
        input_window = {
          ['<esc>'] = { 'cancel', defer_to_completion = true, desc = 'Cancel running request' },
          ['<tab>'] = { 'switch_mode', desc = 'Switch agent mode' },
          ['<cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' }, desc = 'Submit prompt' },
          ['<S-cr>'] = { insert_newline, mode = { 'i' }, desc = 'Insert newline' },
        },
        output_window = {
          ['<esc>'] = { 'cancel', defer_to_completion = true, desc = 'Cancel running request' },
          ['<tab>'] = { 'switch_mode', desc = 'Switch agent mode' },
        },
      },
    }
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        anti_conceal = { enabled = false },
        file_types = { 'opencode_output' },
      },
      ft = { 'Avante', 'copilot-chat', 'opencode_output' },
    },
    'saghen/blink.cmp',
    'nvim-telescope/telescope.nvim',
  },
}
