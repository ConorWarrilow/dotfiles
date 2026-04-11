-- Disable netrw
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false

vim.schedule(function()
    vim.opt.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

-- for git signs on the left
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live as you type
vim.opt.inccommand = "nosplit"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
vim.opt.termguicolors = true

vim.opt.fillchars = {
    vert = " ", -- vertical splits
    -- fold = ' ', -- fold marker
    eob = " ",
    -- add any other characters you want to customize
}

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- these keymaps set <C-h> to execute <C-w><C-h> etc
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<Up>", ":resize +2<CR>")
vim.keymap.set("n", "<Down>", ":resize -2<CR>")
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>")

vim.keymap.set("n", "<Tab>", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<S-Tab>", ":tabprevious<CR>", { desc = "Previous tab" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.lint',
    -- require 'kickstart.plugins.autopairs',
    require("kickstart.plugins.neo-tree"),
    require("kickstart.plugins.modicator"),
    require("kickstart.plugins.todo-comments"),
    require("kickstart.plugins.indent-blankline"),
    require("kickstart.plugins.treesitter"),
    require("kickstart.plugins.auto-save"),
    require("kickstart.plugins.which-key"),
    require("kickstart.plugins.which-key"),
    require("kickstart.plugins.telescope"),
    require("kickstart.plugins.lazydev"),
    require("kickstart.plugins.luvit-meta"),
    require("kickstart.plugins.nvim-lspconfig3"),
    require("kickstart.plugins.conform"),
    require("kickstart.plugins.nvim-cmp"),
    -- require 'kickstart.plugins.mini',
    require("kickstart.plugins.lualine-bubbles2"),
    --  require 'kickstart.plugins.snacks',
    require("kickstart.plugins.nvim-highlight-colors"),
    require("kickstart.plugins.tokyonight"),
    require("kickstart.plugins.gitsigns"),
    require("kickstart.plugins.render-markdown"),
    require("kickstart.plugins.venv-selector"),
    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.

    --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
    -- { import = 'custom.plugins' },
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = {},
    },
})
require("lspconfig").omnisharp.setup({})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--

--
-- My custom settings
function GetVenv()
    local conda_venv = os.getenv("CONDA_PROMPT_MODIFIER")
    if conda_venv then
        return "[" .. string.sub(conda_venv, 2, -3) .. "]"
    end
    local venv = os.getenv("VIRTUAL_ENV")
    if venv then
        return "[" .. vim.fn.fnamemodify(venv, ":t") .. "]"
    else
        return ""
    end
end

vim.o.statusline = vim.o.statusline .. "%{v:lua.GetVenv()}"

vim.defer_fn(function()
    vim.api.nvim_set_hl(0, "MiniStatuslineInactive", { bg = "none", fg = "NONE" })
end, 100)

vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { bg = "none", fg = "none" })

vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none", fg = "#27a1b9" })

vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none", fg = "#ff9e64" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none", fg = "#ff9e64" })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none", fg = "#ff9e64" })

--vim.api.nvim_set_hl(0, 'Cursor', { bg = '#c6c6c6' }) -- bright red background, white text
vim.api.nvim_set_hl(0, "Cursor", { bg = "#c6c6c6", fg = "#c6c6c6" })
vim.api.nvim_set_hl(0, "lCursor", { bg = "#c6c6c6", fg = "#c6c6c6" })
vim.api.nvim_set_hl(0, "CursorIM", { bg = "#c6c6c6", fg = "#c6c6c6" })
vim.api.nvim_set_hl(0, "TermCursor", { bg = "#c6c6c6", fg = "#c6c6c6" })

-- NOTE: Neither of these work
-- vim.api.nvim_set_hl(0, 'NeoTreeWinSeparator', { bg = 'ff0000', fg = 'ff0000' })
-- vim.api.nvim_set_hl(0, 'WinSeparator', { fg = 'ff0000:' })
-- NOTE: INACTIVE SHOULD BE RED TRANS

--
-- -- Disable netrw entirely
-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function(data)
--     if vim.fn.isdirectory(data.file) == 1 then
--       vim.cmd.cd(data.file)
--
--       -- Just open Neo-tree with your configured setup
--       require('neo-tree.command').execute {
--         source = 'filesystem',
--         position = 'float',
--         toggle = true,
--       }
--     end
--   end,
-- })
--
--
-- -- Disable netrw entirely
-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function(data)
--     if vim.fn.isdirectory(data.file) == 1 then
--       vim.cmd.cd(data.file)
--       -- Open Neo-tree in float mode initially
--       require('neo-tree.command').execute {
--         source = 'filesystem',
--         position = 'float',
--         toggle = true,
--       }
--
--       -- Set up a one-time autocmd to switch to sidebar when a file is selected
--       local group = vim.api.nvim_create_augroup('NeoTreeInitialFloat', { clear = true })
--       vim.api.nvim_create_autocmd('BufEnter', {
--         group = group,
--         callback = function(buf_data)
--           if vim.fn.filereadable(buf_data.file) == 1 then
--             -- Close floating window and open sidebar
--             require('neo-tree.command').execute { action = 'close' }
--             require('neo-tree.command').execute {
--               source = 'filesystem',
--               position = 'left',
--               toggle = true,
--             }
--             -- Clear this autocmd
--             vim.api.nvim_del_augroup_by_id(group)
--           end
--         end,
--       })
--     end
--   end,
-- })
--

-- Show errors and warnings in a floating window
--
--
--
--
--

--
--
--
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false, source = "if_many" })
    end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.help",
    callback = function()
        vim.bo.filetype = "man" -- or "markdown", "text", etc.
    end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufLeave", "FocusLost" }, {
    pattern = "*",
    callback = function()
        if vim.bo.modified and vim.bo.filetype ~= "" and vim.fn.expand("%") ~= "" then
            vim.cmd("silent write")
        end
    end,
})
