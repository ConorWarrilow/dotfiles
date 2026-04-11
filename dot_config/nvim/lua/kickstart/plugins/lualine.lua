return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Only needed if you want devicons
  config = function()
    local colors = require('tokyonight.colors').setup {}

    -- Custom component functions
    local function file_readonly()
      if vim.bo.readonly then
        return ' '
      else
        return ''
      end
    end

    local function modified()
      if vim.bo.modified then
        return ' '
      else
        return ''
      end
    end

    local function lsp_status()
      local clients = vim.lsp.get_clients { bufnr = 0 }
      if #clients == 0 then
        return 'No LSP'
      end

      local client_names = {}
      for _, client in ipairs(clients) do
        table.insert(client_names, client.name)
      end

      return table.concat(client_names, ', ')
    end

    local function diagnostics_count()
      local diagnostics = vim.diagnostic.count()
      local errors = diagnostics[1] or 0
      local warnings = diagnostics[2] or 0
      local info = diagnostics[3] or 0
      local hints = diagnostics[4] or 0

      local result = {}
      if errors > 0 then
        table.insert(result, ' ' .. errors)
      end
      if warnings > 0 then
        table.insert(result, ' ' .. warnings)
      end
      if info > 0 then
        table.insert(result, ' ' .. info)
      end
      if hints > 0 then
        table.insert(result, ' ' .. hints)
      end

      if #result > 0 then
        return table.concat(result, ' ')
      else
        return ''
      end
    end

    require('lualine').setup {
      options = {
        icons_enabled = vim.g.have_nerd_font,
        theme = 'auto', -- Use 'auto' instead of 'tokyonight'
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        -- disabled_filetypes = {
        --   statusline = { 'NvimTree', 'neo-tree', 'dashboard', 'Outline' },
        --   winbar = {},
        -- },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
        -- Enable transparency
        transparent = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          { 'branch', icon = '' },
          { 'diff', symbols = { added = ' ', modified = ' ', removed = ' ' } },
        },
        lualine_c = {
          {
            'filename',
            path = 1, -- 0: filename, 1: relative path, 2: absolute path
            shorting_target = 40,
            symbols = {
              modified = '[+]',
              readonly = '[RO]',
              unnamed = '[No Name]',
              newfile = '[New]',
            },
          },
          { modified, color = { fg = colors.orange } },
          { file_readonly, color = { fg = colors.red } },
        },
        lualine_x = {
          { diagnostics_count },
          { lsp_status, icon = ' ', color = { fg = colors.blue } },
          { 'encoding' },
          { 'fileformat', icons_enabled = vim.g.have_nerd_font },
          { 'filetype', icon_only = vim.g.have_nerd_font },
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            path = 1,
            color = { fg = colors.comment },
          },
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {
        'fugitive',
        'nvim-tree',
        'toggleterm',
        'quickfix',
        'symbols-outline',
      },
    }
  end,
}
