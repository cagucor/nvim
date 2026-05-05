vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
      vim.system({ 'make' }, { cwd = ev.data.path })
    end
  end,
})

vim.pack.add({
  -- editor
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
  --text
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/kylechui/nvim-surround',
  -- explorer
  'https://github.com/nvim-tree/nvim-tree.lua',
  -- search
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  -- completion
  {
    src = 'https://github.com/saghen/blink.cmp', 
    version = vim.version.range("1.x") 
  },
  'https://github.com/L3MON4D3/LuaSnip',
  -- formatting
  'https://github.com/stevearc/conform.nvim',
  -- git
  'https://github.com/lewis6991/gitsigns.nvim',
  -- ui
  'https://github.com/catppuccin/nvim',
  'https://github.com/folke/persistence.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  -- utils
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/folke/lazydev.nvim',
  -- lsp data
  'https://github.com/neovim/nvim-lspconfig',
})

-- config
require('plugins.ui')
require('plugins.editor')
require('plugins.text')
require('plugins.explorer')
require('plugins.utils')
require('plugins.search')
require('plugins.completion')
require('plugins.formatting')
