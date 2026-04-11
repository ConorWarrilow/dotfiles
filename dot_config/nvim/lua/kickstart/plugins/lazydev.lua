return {
  -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = 'luvit-meta/library', words = { 'vim%.uv' } },

      -- Add Lazy.nvim types - this gives you autocomplete for lazy plugin specs
      { path = 'lazy.nvim', words = { 'lazy' } },

      -- Add other common plugin libraries you might want types for
      -- Only loads when these words/patterns are found in your code
      { path = 'nvim-treesitter', words = { 'treesitter' } },
      { path = 'telescope.nvim', words = { 'telescope' } },
      { path = 'nvim-lspconfig', words = { 'lspconfig' } },
    },
  },
}
