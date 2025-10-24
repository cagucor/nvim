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
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          -- Conform will run multiple formatters sequentially
          python = { 'ruff' },
          -- You can customize some of the format options for the filetype (:help conform.format)
          rust = { 'rustfmt', lsp_format = 'fallback' },
          -- Conform will run the first available formatter
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
        },
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'saghen/blink.cmp',
      },
      {
        'folke/trouble.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {},
      },
      {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {},
      },
    },
    opts = {
      servers = {
        -- lua_ls = {},
        rust_analyzer = {},
        cssls = {},
        pylsp = {},
        ruff = {},
        clangd = {},
      },
      inlay_hints = { enabled = true },
    },
    config = function(_, opts)
      local lspconfig = require('lspconfig')

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      require('lspconfig').cssls.setup({
        capabilities = capabilities,
      })

      -- ensure this order.
      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, bufnr)
        end
      end
      local options = {
        on_attach = on_attach,
      }
      for name, config in pairs(opts.servers) do
        config = vim.tbl_deep_extend('force', config, {
          capabilities = require('blink.cmp').get_lsp_capabilities(
            capabilities
          ),
        })

        lspconfig[name].setup(config)
      end
      -- omitted.
    end,
  },
}
