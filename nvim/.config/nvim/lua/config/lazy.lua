local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-sleuth',
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      }
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = function()
      local picker = function(name, opts)
        return function()
          require('telescope.builtin')[name](opts)
        end
      end
      return {
        { '<leader>sh', picker 'help_tags', desc = '[S]earch [H]elp' },
        { '<leader>sk', picker 'keymaps', desc = '[S]earch [K]eymaps' },
        { '<leader>sf', picker 'find_files', desc = '[S]earch [F]iles' },
        { '<leader>ss', picker 'builtin', desc = '[S]earch [S]elect Telescope' },
        { '<leader>sw', picker 'grep_string', desc = '[S]earch current [W]ord' },
        { '<leader>sg', picker 'live_grep', desc = '[S]earch by [G]rep' },
        { '<leader>sd', picker 'diagnostics', desc = '[S]earch [D]iagnostics' },
        { '<leader>sr', picker 'resume', desc = '[S]earch [R]esume' },
        { '<leader>s.', picker 'oldfiles', desc = '[S]earch Recent Files ("." for repeat)' },
        { '<leader><leader>', picker 'buffers', desc = '[ ] Find existing buffers' },
        {
          '<leader>/',
          function()
            require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
              winblend = 10,
              previewer = false,
            })
          end,
          desc = '[/] Fuzzily search in current buffer',
        },
        {
          '<leader>s/',
          picker('live_grep', { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }),
          desc = '[S]earch [/] in Open Files',
        },
        {
          '<leader>sn',
          function()
            require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
          end,
          desc = '[S]earch [N]eovim files',
        },
      }
    end,
    init = function()
      -- The first selection loads Telescope; ui-select replaces this wrapper.
      vim.ui.select = function(...)
        require('telescope').load_extension 'ui-select'
        return vim.ui.select(...)
      end
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      {
        'nvim-tree/nvim-web-devicons',
        enabled = vim.g.have_nerd_font,
        dependencies = { 'DaikyXendo/nvim-material-icon' },
      },
      { 'DaikyXendo/nvim-material-icon' },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { '^%.git/' },
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--glob=!.git',
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      require('telescope').load_extension 'ui-select'
    end,
  },
  {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = { timeout_ms = 500, lsp_format = 'fallback' },
      formatters_by_ft = {
        lua = { 'stylua' },
        astro = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        graphql = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        jsonc = { 'prettierd', 'prettier', stop_after_first = true },
        kotlin = { 'ktfmt' },
        markdown = { 'prettierd', 'prettier', stop_after_first = true },
        sql = { 'sqlfmt' },
        mysql = { 'sqlfmt' },
        plsql = { 'sqlfmt' },
        svelte = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
      vim.cmd.hi 'Comment gui=none'
    end,
    config = function()
      require('catppuccin').setup {
        integrations = {
          fidget = true,
          which_key = true,
          mason = true,
          dadbod_ui = true,
        },
      }
    end,
  },
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.comment').setup {
        options = {
          custom_commentstring = function()
            return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
          end,
        },
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('config.treesitter').setup()
    end,
  },
  { import = 'plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
