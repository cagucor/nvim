return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = 'all',
      autopairs = {
        enable = true,
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  -- terminal
  {
    'akinsho/toggleterm.nvim',
    opts = {
      size = 20,
      open_mapping = [[<m-0>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = false,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    },
  },
  -- file explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    opts = {
      filesystem = {
        filtered_items = {
          always_show = {
            '.gitignore',
          },
        },
        hijack_netrw_behavior = 'open_current',
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      'nvim-telescope/telescope-media-files.nvim',
    },
    opts = {
      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
        },
        media_files = {
          -- filetypes whitelist
          -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
          filetypes = { 'png', 'webp', 'jpg', 'jpeg' },
          find_cmd = 'rg', -- find command (defaults to `fd`)
        },
      },
    },

    config = function()
      require('telescope').load_extension('fzf')
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)
      wk.register({
        f = {
          name = 'Find',
          b = { '<cmd>Telescope git_branches<cr>', 'Checkout branch' },
          c = { '<cmd>Telescope colorscheme<cr>', 'Colorscheme' },
          f = { '<cmd>Telescope find_files<cr>', 'Find files' },
          t = { '<cmd>Telescope live_grep<cr>', 'Find Text' },
          s = { '<cmd>Telescope grep_string<cr>', 'Find String' },
          h = { '<cmd>Telescope help_tags<cr>', 'Help' },
          H = { '<cmd>Telescope highlights<cr>', 'Highlights' },
          i = {
            '<cmd>lua require(\'telescope\').extensions.media_files.media_files()<cr>',
            'Media',
          },
          l = { '<cmd>Telescope resume<cr>', 'Last Search' },
          M = { '<cmd>Telescope man_pages<cr>', 'Man Pages' },
          r = { '<cmd>Telescope oldfiles<cr>', 'Recent File' },
          R = { '<cmd>Telescope registers<cr>', 'Registers' },
          k = { '<cmd>Telescope keymaps<cr>', 'Keymaps' },
          C = { '<cmd>Telescope commands<cr>', 'Commands' },
        },
        l = {
          name = 'LSP',
          a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Code Action' },
          c = {
            '<cmd>lua require(\'user.lsp\').server_capabilities()<cr>',
            'Get Capabilities',
          },
          d = { '<cmd>TroubleToggle<cr>', 'Diagnostics' },
          w = {
            '<cmd>Telescope lsp_workspace_diagnostics<cr>',
            'Workspace Diagnostics',
          },
          f = { '<cmd>GuardFmt<cr>', 'Format' },
          F = { '<cmd>LspToggleAutoFormat<cr>', 'Toggle Autoformat' },
          i = { '<cmd>LspInfo<cr>', 'Info' },
          h = {
            '<cmd>lua require(\'lsp-inlayhints\').toggle()<cr>',
            'Toggle Hints',
          },
          H = { '<cmd>IlluminationToggle<cr>', 'Toggle Doc HL' },
          I = { '<cmd>LspInstallInfo<cr>', 'Installer Info' },
          j = {
            '<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>',
            'Next Diagnostic',
          },
          k = {
            '<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>',
            'Prev Diagnostic',
          },
          v = { '<cmd>lua require(\'lsp_lines\').toggle()<cr>', 'Virtual Text' },
          l = { '<cmd>lua vim.lsp.codelens.run()<cr>', 'CodeLens Action' },
          o = { '<cmd>SymbolsOutline<cr>', 'Outline' },
          q = { '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', 'Quickfix' },
          r = { '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename' },
          R = { '<cmd>TroubleToggle lsp_references<cr>', 'References' },
          s = { '<cmd>Telescope lsp_document_symbols<cr>', 'Document Symbols' },
          S = {
            '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>',
            'Workspace Symbols',
          },
          t = {
            '<cmd>lua require("user.functions").toggle_diagnostics()<cr>',
            'Toggle Diagnostics',
          },
          u = { '<cmd>LuaSnipUnlinkCurrent<cr>', 'Unlink Snippet' },
        },
      }, { prefix = '<leader>' })
    end,
  },
  -- latex
  {
    'lervag/vimtex',
  },
  -- neorg
  {
    'nvim-neorg/neorg',
    build = ':Neorg sync-parsers',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('neorg').setup({
        load = {
          ['core.defaults'] = {}, -- Loads default behaviour
          ['core.concealer'] = {}, -- Adds pretty icons to your documents
          ['core.dirman'] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = '~/notes',
              },
            },
          },
        },
      })
    end,
  },
  {
    'folke/zen-mode.nvim',
    opts = {
      window = {
        width = 100,
      },
      plugins = {},
    },
  },
  { 'lukas-reineke/indent-blankline.nvim', opts = {} },
}
