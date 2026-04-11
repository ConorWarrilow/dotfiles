-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
        { "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
    },
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {
        window = {
            position = "left",
        },
        default_component_configs = {
            git_status = {
                symbols = {
                    -- modified = '',
                    modified = "",
                    -- added = '✚',
                    -- there's a reason we set modified and added to empty strings
                    -- but I cant remember what it was
                    added = "",
                    unstaged = "",
                    staged = "",
                    ignored = "",
                    deleted = "",
                    conflict = "",
                },
            },
            file_size = {
                enabled = false,
                required_width = 40, -- 🔥 shrink the default width needed (default was 9!)
            },
            last_modified = {
                enabled = false,
                required_width = 60, -- 🔥 you can make this even smaller if you want
                format = "relative",
            },
        },
        filesystem = {
            hijack_netrw = true,
            hijack_netrw_behavior = "open_default",
            window = {
                mappings = {
                    ["\\"] = "close_window",
                },
            },
            filtered_items = {
                visible = true,
                never_show = {
                    ".git",
                    ".github",
                },
                --hide_dotfiles = false,
                --hide_gitignored = false,
            },
        },
    },
}

-- symbols = {
--   -- Change type
--   added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
--   modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
--   deleted = "✖", -- this can only be used in the git_status source
--   renamed = "󰁕", -- this can only be used in the git_status source
--   -- Status type
--   untracked = "",
--   ignored = "",
--   unstaged = "󰄱",
--   staged = "",
--   conflict = "",
-- },
--
--
--

-- lvim.builtin.nvimtree.setup.renderer.icons.glyphs.git = {
--           unstaged = "✗",
--           staged = "✓",
--           unmerged = "",
--           renamed = "➜",
--           untracked = "★",
--           deleted = "",
--           ignored = "◌",
-- }

--  (nf-dev-git_merge icon) → meaning "merge"
--
--  (nf-oct-git_merge icon) → another merge branch symbol
--
--  (a plug/disconnect icon — means "needs to be connected")
--
-- ⚡ (lightning bolt — something urgent / conflict)
--
--  (an X icon — indicates conflict or blocking)
--
--  (exclamation inside a circle — warning)
--
-- 
--
--	trash can (perfect for "deleted")
-- 	archive/trash symbol
-- 	big trash bin icon (classic delete)
-- 󰍵	broken document (file removed)
-- 
--     trash can (simple and bold)
--
-- 
-- 	warning / attention (changes exist but not staged)
-- 	half-filled circle (half-done work)
-- 	pencil / edit symbol (file edited, not saved in commit yet)
-- 	info / notice (soft warning)
-- 	clock / time (still pending)
-- 	heavy exclamation mark (loud warning)
--
--
-- 
-- 	heavier checkmark (affirmative, confirmed)
-- 	stacked files (prepared documents)
-- 
-- 	up arrow box (uploaded/prepared to send)
-- 	tick inside circle (completed)
--
--
-- 	pencil (needs editing)
-- 	document with edit mark (modified)
-- 	warning triangle (needs action)
-- 	empty circle (not yet completed / empty)
-- 󰆼	dot (small marker - changed but subtle)
-- 	a circle with a slash (incomplete, pending)
-- 
-- 󰃤	Search (not yet known, needs indexing)
