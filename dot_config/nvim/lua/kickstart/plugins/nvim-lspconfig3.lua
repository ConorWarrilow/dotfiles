return {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- Useful status updates for LSP.
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { "j-hui/fidget.nvim", opts = {} },
        -- Allows extra capabilities provided by nvim-cmp
        "hrsh7th/cmp-nvim-lsp",
    },
    ---@module "lspconfig"
    ---@type "lspconfig.config"
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                -- to define small helper and utility functions so you don't have to repeat yourself.
                --
                -- In this case, we create a function that lets us more easily define mappings specific
                -- for LSP related items. It sets the mode, buffer and description for us each time.
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end
                map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
                map("<leader>D", function()
                    require("telescope.builtin").lsp_definitions({
                        jump_type = "split", -- 'tab', 'edit', or 'vsplit' for vertical
                    })
                end, "[D]efinition in split")
                map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
                map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
                map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd("LspDetach", {
                        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end
                if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    map("<leader>th", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                    end, "[T]oggle Inlay [H]ints")
                end
            end,
        })
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
        local servers = {
            -- clangd = {},
            -- gopls = {},
            pyright = {},
            bashls = {},
            -- Add Ruff LSP server
            -- ruff = {
            --   -- Optional: Configure Ruff LSP settings
            --   init_options = {
            --     settings = {
            --       -- Any extra CLI arguments for ruff can go here
            --       args = {},
            --     },
            --   },
            -- },
            lua_ls = {
                settings = {
                    Lua = {
                        hint = { enable = true },
                        completion = {
                            callSnippet = "Replace",
                        },
                        expandAlias = false,
                        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                        -- diagnostics = { disable = { 'missing-fields' } },

                        -- Add workspace library paths for snacks.nvim types
                        workspace = {
                            library = {
                                -- Include the Neovim runtime files
                                vim.api.nvim_get_runtime_file("", true),
                                -- Add a types directory if you want to create custom type definitions
                                vim.fn.stdpath("config") .. "/types",
                                vim.fn.stdpath("data") .. "/lazy",
                            },
                            -- Optionally, you can also disable the specific diagnostic that's bothering you
                            diagnostics = {
                                -- Uncomment this line if you want to disable 'undefined-doc-name' warnings
                                -- disable = { "undefined-doc-name" }
                            },
                        },
                    },
                },
            },
        }
        --
        --     -- Create snacks.nvim type definition file
        --     local types_dir = vim.fn.stdpath 'config' .. '/types'
        --     local snacks_types_file = types_dir .. '/snacks.lua'
        --
        --     -- Create the types directory if it doesn't exist
        --     if vim.fn.isdirectory(types_dir) == 0 then
        --       vim.fn.mkdir(types_dir, 'p')
        --     end
        --
        --     -- Write the type definition file if it doesn't exist
        --     if vim.fn.filereadable(snacks_types_file) == 0 then
        --       local file = io.open(snacks_types_file, 'w')
        --       if file then
        --         file:write [[
        -- ---@class snacks.Config
        -- ---@field bigfile? { enabled?: boolean }
        -- ---@field dashboard? { enabled?: boolean }
        -- ---@field explorer? { enabled?: boolean }
        -- ---@field indent? { enabled?: boolean }
        -- ---@field input? { enabled?: boolean }
        -- ---@field notifier? { enabled?: boolean, timeout?: number }
        -- ---@field picker? { enabled?: boolean }
        -- ---@field quickfile? { enabled?: boolean }
        -- ---@field scope? { enabled?: boolean }
        -- ---@field scroll? { enabled?: boolean }
        -- ---@field statuscolumn? { enabled?: boolean }
        -- ---@field words? { enabled?: boolean }
        -- ---@field styles? { notification?: table }
        -- ]]
        --         file:close()
        --         print('Created snacks.nvim type definitions at ' .. snacks_types_file)
        --       end
        --     end

        require("mason").setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            "stylua", -- Used to format Lua code
            "ruff", -- Add ruff to ensure it's installed
        })
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
        require("mason-lspconfig").setup({
            ensure_installed = { "pyright", "ruff" }, -- Add ruff here
            automatic_installation = true,
        })
        require("mason-lspconfig").setup({
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed
                    -- by the server configuration above. Useful when disabling
                    -- certain features of an LSP (for example, turning off formatting for ts_ls)
                    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    require("lspconfig")[server_name].setup(server)
                end,
            },
        })
    end,
}
