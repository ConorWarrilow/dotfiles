return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional but nice for icons
  opts = function()
    local colors = {
      blue = '#7aa3f7',
      cyan = '#7dcffe',
      black = '#080808',
      white = '#c6c6c6',
      red = '#f7758e',
      violet = '#bb9af7',
      grey = '#414767',
      red_bright = '#ff0000',
      red_dark = '#401F25',
      light_green = '#9ece69',
      green = '#73d9ca',
      yellow = '#e0af67',
    }

    -- red_transparent = #f7758e
    -- green_transparent =  #73d9ca
    -- yellow_transparent = #e0af67
    -- blue_transparent =  #7aa3f7
    -- purple_transparent = #bb9bf7
    -- cyan_transparent =  #7dcffe
    -- white_transparent = #c0c9f5
    -- light_green_transparent = #9ece69

    local bubbles_theme = {
      normal = {
        a = { fg = colors.black, bg = colors.blue },
        b = { fg = colors.white, bg = colors.grey },
        c = {},
      },
      insert = { a = { fg = colors.black, bg = colors.green } },
      visual = { a = { fg = colors.black, bg = colors.magenta } },
      replace = { a = { fg = colors.black, bg = colors.red } },
      command = { a = { fg = colors.black, bg = colors.yellow } },
      other = { a = { fg = colors.black, bg = colors.cyan } },

      inactive = {
        a = { fg = colors.white, bg = colors.red_bright },
        b = { fg = colors.white, bg = colors.red_bright },
        c = { fg = colors.white },
      },
    }

    return {
      options = {
        theme = bubbles_theme,
        component_separators = '',
        -- section_separators = { left = '█', right = '█' },
        section_separators = {},
      },
      sections = {
        lualine_a = { { 'mode', separator = {}, right_padding = 2 } },
        --
        -- lualine_a = {
        --   {
        --     function()
        --       local mode = require('lualine.utils.mode').get_mode()
        --       return mode .. ''
        --     end,
        --     right_padding = 2, -- Adjust padding as needed
        --     separator = { right = '' },
        --   },
        -- },
        --
        lualine_b = { 'filename', 'branch' },
        lualine_c = {
          '%=', -- center components placeholder
        },
        lualine_x = {},
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
          { 'location', separator = {}, left_padding = 2 },
        },
      },
      -- inactive_sections = {
      --   lualine_a = { 'filename' },
      --   lualine_b = {},
      --   lualine_c = {
      --     '%=', -- center components placeholder
      --   },
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = { 'location' },
      -- },
      tabline = {},
      extensions = {
        {
          filetypes = { 'neo-tree' },

          sections = {
            lualine_a = {
              { 'filetype', separator = { right = '' } },
            },

            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
          },
        },
        {

          filetypes = { 'toggleterm', 'terminal' },
          sections = {
            lualine_a = { 'mode' },
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = {},
            lualine_y = {},
            lualine_z = { 'location' },
          },
        },
      },
    }
  end,
}
