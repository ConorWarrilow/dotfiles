return {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        -- "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --optional
        { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    lazy = false,
    branch = "regexp", -- This is the regexp branch, use this for the new version
    keys = {
        { ",v", "<cmd>VenvSelect<cr>" },
    },
    ---@module 'venv-selector'
    ---@type venv-selector.Config
    opts = {

        -- Your settings go here
    },
}
