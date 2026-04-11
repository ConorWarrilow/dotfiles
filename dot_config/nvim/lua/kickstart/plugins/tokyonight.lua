return {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false, -- ensure it's not lazy-loaded so colorscheme applies at startup
    opts = {
        style = "night",
        transparent = true,
        styles = {
            functions = {}, -- disable italic for functions
            sidebars = "transparent",
            floats = "transparent",
        },
        on_colors = function(colors)
            -- Optional: also modify some highlight colors if you want
            -- colors.hint = colors.orange
            colors.error = "#f7768e"
            colors.bg_statusline = "NONE"
           colors.terminal = {
                black = "#414868",
                black_bright = "#414868",
                blue = "#7aa2f7",
                blue_bright = "#7aa2f7",
                cyan = "#7dcfff",
                cyan_bright = "#7dcfff",
                green = "#73daca",
                green_bright = "#73daca",
                magenta = "#bb9af7",
                magenta_bright = "#bb9af7",
                red = "#f7768e",
                red_bright = "#65EB3D",
                white = "#c0caf5",
                white_bright = "#c0caf5",
                yellow = "#e0af68",
                yellow_bright = "#e0af68",
            }
        end,

        on_highlights = function(highlights) --, colors)
            -- Markdown headings
            highlights["@markup.heading.1.markdown"] = {
                fg = "#73daca", -- H1 / # Title
                bold = true,
            }
            
            highlights["@markup.heading.2.markdown"] = {
                fg = "#7dcfff", -- H2 / ## Heading
                bold = true,
            }

            -- Optional: keep going if you want
            highlights["@markup.heading.3.markdown"] = {
                fg = "#bb9af7",
            }

            highlights["@markup.heading.4.markdown"] = {
                fg = "#7aa2f7",
            }

            highlights["@markup.heading.5.markdown"] = {
                fg = "#e0af68",
            }
            highlights["@markup.heading.6.markdown"] = {
                fg = "#c6c6c6",
            }

            -- Neotree
            highlights.NeoTreeNormal = { bg = "NONE" }
            highlights.NeoTreeNormalNC = { bg = "NONE" }
            highlights.NeoTreeEndOfBuffer = { bg = "NONE" }
            -- Optional: make the NeoTree float also transparent if you plan on using float config
            highlights.NeoTreeFloatBorder = { bg = "NONE" }
            highlights.NeoTreeFloatTitle = { bg = "NONE" }

            -- Transparent cursorline (must be set to the specific color specified in kitty.conf
            -- transparent_background_colors' variable. Only works While using kitty terminal,
            -- use a different color when not using kitty.
            highlights.String = { fg = "#c6c6c6" }
            highlights["@string.documentation"] = { fg = "#565f89" }
            highlights.character = { fg = "#c6c6c6" }
            -- highlights.@markup.heading.3.markdown = { fg = '#c6c6c6' }
            -- highlights.CursorLine = { bg = "#401F25" }
            highlights.IncSearch = { bg = "#ff9e63", fg = "#15161e" }
            highlights.Search = { bg = "#7aa3f7", fg = "#3d59a1" }
            highlights.FloatBorder = { bg = "NONE", fg = "#27a1b9" }
            highlights.LspInfoBorder = { bg = "NONE", fg = "#27a1b9" }
            highlights.CmpDocumentationBorder = { bg = "NONE", fg = "#27a1b9" }
            highlights.Pmenu = { bg = "NONE", fg = "#27a1b9" }
            highlights.PmenuExtra = { bg = "NONE", fg = "#ff0000" }
            highlights.PmenuMatch = { bg = "NONE", fg = "#ff0000" }
            highlights.PmenuSel = { bg = "#401F25" }
            highlights.NormalFloat = { bg = "NONE" }
            highlights.LspReferenceText = { bg = "NONE" }
            highlights.LspReferenceRead = { bg = "NONE" }
            highlights.LspReferenceWrite = { bg = "NONE" }
            highlights.LspInlayHint = { bg = "NONE" }

            --highlights.PmenuSbar = { bg = '#f7758e' }
            --highlights.PmenuThumb = { bg = '#73d9ca' }

            -- highlights. = { bg = 'NONE', fg = '#27a1b9' }
            -- highlights. = { bg = 'NONE', fg = '#27a1b9' }
            -- highlights. = { bg = 'NONE', fg = '#27a1b9' }
            -- highlights. = { bg = 'NONE', fg = '#27a1b9' }

            highlights.WinSeparator = {
                link = "Normal",
            }
            highlights.StatusLine = {
                bg = "NONE",
                fg = "#ff0000",
            }
            highlights.StatusLineNC = {
                bg = "NONE",
                fg = "#ffff00",
            }
            highlights.MiniStatuslineDevinfo = {
                bg = "#3b4261",
                fg = "#a9b1d6",
            }
            highlights.MiniStatuslineFileinfo = {
                bg = "#3b4261",
                fg = "#a9b1d6",
            }
            highlights.MiniStatuslineFilename = {
                bg = "#292e42",
                fg = "#a9b1d6",
            }
            highlights.MiniStatuslineInactive = {
                bg = "NONE",
                fg = "#7aa2f7",
                ctermbg = "NONE",
            }
            highlights.MiniStatuslineModeCommand = {
                bg = "#e0af68",
                bold = true,
                fg = "#15161e",
            }
            highlights.MiniStatuslineModeInsert = {
                bg = "#9ece6a",
                bold = true,
                fg = "#15161e",
            }
            highlights.MiniStatuslineModeNormal = {
                bg = "#7aa2f7",
                bold = true,
                fg = "#15161e",
            }
            highlights.MiniStatuslineModeOther = {
                bg = "#1abc9c",
                bold = true,
                fg = "#15161e",
            }
            highlights.MiniStatuslineModeReplace = {
                bg = "#f7768e",
                bold = true,
                fg = "#15161e",
            }
            highlights.MiniStatuslineModeVisual = {
                bg = "#bb9af7",
                bold = true,
                fg = "#15161e",
            }
        end,
    },
    config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme("tokyonight-night")
        vim.cmd.hi("Comment gui=none")
    end,
}
