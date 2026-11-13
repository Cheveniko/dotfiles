return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            winblend = 0,
          },
        },
      },
    },
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      opts = {
        library = {
          { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        },
      },
    },
    { 'Bilal2453/luvit-meta', lazy = true },
  },
  config = function()
    local brew_prefix = vim.env.HOMEBREW_PREFIX or (vim.fn.isdirectory '/opt/homebrew' == 1 and '/opt/homebrew' or '/usr/local')
    local java21_home = brew_prefix .. '/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home'
    local highlight_group = vim.api.nvim_create_augroup('config-lsp-highlight', { clear = true })

    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('config-lsp-detach', { clear = true }),
      callback = function(event)
        for _, client in ipairs(vim.lsp.get_clients { bufnr = event.buf }) do
          if
            client.id ~= event.data.client_id
            and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight)
          then
            return
          end
        end
        vim.lsp.util.buf_clear_references(event.buf)
        vim.api.nvim_clear_autocmds { group = highlight_group, buffer = event.buf }
      end,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        local telescope_map = function(keys, picker, desc)
          map(keys, function()
            require('telescope.builtin')[picker]()
          end, desc)
        end
        telescope_map('gd', 'lsp_definitions', '[G]oto [D]efinition')
        telescope_map('gr', 'lsp_references', '[G]oto [R]eferences')
        telescope_map('gI', 'lsp_implementations', '[G]oto [I]mplementation')
        telescope_map('<leader>D', 'lsp_type_definitions', 'Type [D]efinition')
        telescope_map('<leader>ds', 'lsp_document_symbols', '[D]ocument [S]ymbols')
        telescope_map('<leader>ws', 'lsp_dynamic_workspace_symbols', '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('gh', vim.lsp.buf.hover, '[H]over Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          vim.api.nvim_clear_autocmds { group = highlight_group, buffer = event.buf }
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = vim.lsp.buf.clear_references,
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local servers = {
      'angularls',
      'astro',
      'cssls',
      'docker_compose_language_service',
      'dockerls',
      'gopls',
      'html',
      'jsonls',
      'kotlin_language_server',
      'lua_ls',
      'mdx_analyzer',
      'pylsp',
      'svelte',
      'tailwindcss',
      'ts_ls',
      'denols',
      'intelephense',
    }

    local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('blink.cmp').get_lsp_capabilities(), {
      workspace = {
        fileOperations = {
          didCreate = true,
          willCreate = true,
          didRename = true,
          willRename = true,
          didDelete = true,
          willDelete = true,
        },
      },
    })

    vim.lsp.config('*', {
      capabilities = capabilities,
    })

    vim.lsp.document_color.enable(true, nil, { style = '■ ' })

    if vim.fn.isdirectory(java21_home) == 1 then
      vim.lsp.config('kotlin_language_server', {
        cmd_env = {
          JAVA_HOME = java21_home,
          PATH = java21_home .. '/bin:' .. vim.env.PATH,
        },
      })
    end

    for _, server_name in ipairs(servers) do
      vim.lsp.enable(server_name)
    end

    require('mason-lspconfig').setup {
      ensure_installed = servers,
      automatic_enable = false,
    }

    require('mason-tool-installer').setup {
      ensure_installed = {
        'stylua',
      },
    }
  end,
}
