return {
  -- breadcrumbs
  {
    'SmiteshP/nvim-navic',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    opts = function()
      return {
        separator = ' > ',
        highlight = true,
        depth_limit = 5,
      }
    end,
  },
  -- neodev
  {
    'folke/neodev.nvim',
    opts = {},
  },
  -- Diagnositcs
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'nvimdev/guard.nvim',
    config = function()
      local ft = require('guard.filetype')
      ft('lua'):fmt('stylua')
      ft('python'):fmt('black')
      ft('toml'):fmt('lsp')
      ft('markdown'):fmt({
        cmd = 'prettierd',
        args = { '--stdin-filepath', '--prose-wrap=always' },
        fname = true,
        stdin = true,
      })
    end,
  },
  -- cmdline tools and lsp servers
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {},
    config = function() end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { -- change this key to `requires` if you're using packer.
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    opts = {
      inlay_hints = { enabled = true },
    },
    config = function()
      -- ensure this order.
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = {
          -- omitted.
        },
        -- omitted.
      })
      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, bufnr)
        end
      end
      local options = {
        on_attach = on_attach,
      }

      require('mason-lspconfig').setup_handlers({
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup(options)
        end,
        -- Next, you can provide a dedicated handler for specific servers.
        -- For example, a handler override for the `rust_analyzer`:
      })

      -- omitted.
    end,
  },
}
