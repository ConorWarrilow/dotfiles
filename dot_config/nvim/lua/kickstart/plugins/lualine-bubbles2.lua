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
      grey = '#414767',
      red_dark = '#401F25',
      light_green = '#9ece69',
      green = '#73d9ca',
      orange = '#ff9e63',
      magenta = '#bb9bf7',
    }

    local bubbles_theme = {
      normal = {
        a = { fg = colors.black, bg = colors.blue },
        b = { fg = colors.white, bg = colors.red_dark },
        c = {},
      },
      insert = { a = { fg = colors.black, bg = colors.green } },
      visual = { a = { fg = colors.black, bg = colors.magenta } },
      replace = { a = { fg = colors.black, bg = colors.red } },
      command = { a = { fg = colors.black, bg = colors.orange } },
      other = { a = { fg = colors.black, bg = colors.cyan } },
      terminal = { a = { fg = colors.black, bg = colors.cyan } },

      inactive = {
        a = { fg = colors.white, bg = colors.red_dark },
        b = { fg = colors.white, bg = colors.red_dark },
        c = { fg = colors.white, bg = colors.red_dark },
      },
    }

    -- Function to get the mode color
    local function get_mode_color()
      local mode_colors = {
        n = colors.blue, -- Normal
        i = colors.green, -- Insert
        v = colors.magenta, -- Visual
        V = colors.magenta, -- Visual Line
        ['\22'] = colors.magenta, -- Visual Block (^V)
        c = colors.orange, -- Command
        R = colors.red, -- Replace
        s = colors.magenta, -- Select
        S = colors.magenta, -- Select Line
        ['\19'] = colors.magenta, -- Select Block (^S)
        t = colors.cyan, -- Terminal
      }

      local current_mode = vim.fn.mode()
      return mode_colors[current_mode] or colors.blue
    end

    return {
      options = {
        theme = bubbles_theme,
        component_separators = '',
        section_separators = {},
      },
      sections = {
        lualine_a = { { 'mode', separator = {}, right_padding = 2, left_padding = 0 } },
        lualine_b = { 'filename', 'branch' },
        lualine_c = {
          {
            function()
              return ' '
            end,
            color = function()
              return { bg = get_mode_color() }
            end,
            padding = 0,
          },
          '%=', -- center components placeholder
        },
        lualine_x = {
          {
            function()
              return ' '
            end,
            color = function()
              return { bg = get_mode_color() }
            end,
            padding = 0,
          },
        },
        lualine_y = { 'filetype', 'progress' },
        lualine_z = {
          { 'location', separator = {}, left_padding = 2 },
        },
      },
      tabline = {},
      extensions = {
        {
          filetypes = { 'neo-tree' },
          --
          -- sections = {
          --   lualine_a = {
          --     { 'filetype', separator = { right = '' } },
          --   },
          --   lualine_b = {},
          --   lualine_c = {},
          --   lualine_x = {},
          --   lualine_y = {},
          --   lualine_z = {},
          -- },
          -- inactive_sections = {
          --
          --   lualine_a = {},
          --   lualine_b = {
          --     { 'filetype', separator = { right = '' } },
          --   },
          --
          --   lualine_c = {},
          --   lualine_x = {},
          --   lualine_y = {},
          --   lualine_z = {},
          -- },
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
