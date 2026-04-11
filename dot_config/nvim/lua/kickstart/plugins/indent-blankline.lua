return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = {},
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        highlight = 'IndentBlanklineContextChar', -- 🔥 this is required
        include = {
          node_type = {
            lua = {
              'chunk',
              'block',
              'function_declaration',
              'if_statement',
              'table_constructor',
              'return_statement',
            },
            python = {
              'module',
              'function_definition',
              'if_statement',
              'for_statement',
              'while_statement',
              'with_statement',
              'block',
            },
          },
        },
      },
    },
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },
}
