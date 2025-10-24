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
    opts = function()
      return {
        defaults = {
          mappings = {
            n = {
              ['q'] = require('telescope.actions').close,
            },
          },
        },
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
      }
    end,

    config = function()
      require('telescope').load_extension('fzf')
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },
}
