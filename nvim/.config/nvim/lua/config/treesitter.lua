local M = {}

function M.setup()
  local treesitter = require 'nvim-treesitter'
  local install_dir = vim.fs.joinpath(vim.fn.stdpath 'data', 'site')
  treesitter.setup { install_dir = install_dir }
  treesitter.install { 'diff', 'lua', 'luadoc', 'query', 'javascript', 'typescript', 'tsx', 'css', 'html', 'markdown', 'markdown_inline' }

  local disabled = {
    csv = true,
    tsv = true,
    csv_semicolon = true,
    csv_whitespace = true,
    csv_pipe = true,
    rfc_csv = true,
    rfc_semicolon = true,
  }

  local function attach(buf, lang)
    local ok, loaded = pcall(vim.treesitter.language.add, lang)
    if not ok or not loaded then
      return false
    end

    vim.treesitter.start(buf, lang)
    if lang == 'ruby' then
      vim.bo[buf].syntax = 'ruby'
    elseif vim.treesitter.query.get(lang, 'indents') then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
    return true
  end

  -- The main branch has no auto_install: install missing parsers on first use.
  local available
  local installing = {}

  local function is_installed(lang)
    return vim.tbl_contains(treesitter.get_installed(), lang)
  end

  local function auto_install(lang)
    if not available then
      available = {}
      for _, name in ipairs(treesitter.get_available()) do
        available[name] = true
      end
    end
    if not available[lang] or installing[lang] then
      return
    end

    installing[lang] = true
    vim.notify(('Tree-sitter: installing %s…'):format(lang), vim.log.levels.INFO)
    treesitter.install({ lang }):await(function(err)
      vim.schedule(function()
        installing[lang] = nil
        if err then
          vim.notify(('Tree-sitter: failed to install %s: %s'):format(lang, err), vim.log.levels.ERROR)
          return
        end
        vim.notify(('Tree-sitter: installed %s'):format(lang), vim.log.levels.INFO)
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(b) and vim.treesitter.language.get_lang(vim.bo[b].filetype) == lang then
            attach(b, lang)
          end
        end
      end)
    end)
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('dotfiles-treesitter', { clear = true }),
    callback = function(event)
      local lang = vim.treesitter.language.get_lang(event.match)
      if not lang or disabled[event.match] or disabled[lang] or vim.bo[event.buf].buftype ~= '' then
        return
      end

      if not is_installed(lang) then
        auto_install(lang)
      else
        attach(event.buf, lang)
      end
    end,
  })
end

return M
