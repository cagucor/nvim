local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
---@diagnostic disable-next-line: missing-parameter
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  -- snapshot = "july-24",
  snapshot_path = fn.stdpath "config" .. "/snapshots",
  max_jobs = 50,
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
    prompt_border = "rounded", -- Border style of prompt popups.
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- Plugin Mangager
  use "wbthomason/packer.nvim" -- Have packer manage itself

  -- Completion
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-buffer" -- buffer completions
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- cmdline completions
  use "saadparwaiz1/cmp_luasnip" -- snippet completions
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-emoji"
  use "hrsh7th/cmp-nvim-lua"

  -- Debugging
  use "mfussenegger/nvim-dap"
  use "rcarriga/nvim-dap-ui"
  use "jayp0521/mason-nvim-dap.nvim"
  -- use "theHamsta/nvim-dap-virtual-text"

  -- File System
  -- use "kyazdani42/nvim-tree.lua"
  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
  }
  use { "nvim-telescope/telescope-file-browser.nvim" }

  -- Fuzzy Finder/Telescope
  use "nvim-telescope/telescope.nvim"
  use "nvim-telescope/telescope-media-files.nvim"
  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }

  -- Git
  use "lewis6991/gitsigns.nvim"
  use "f-person/git-blame.nvim"
  use "pwntester/octo.nvim"

  -- LSP
  use "neovim/nvim-lspconfig"
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters
  use {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup {}
    end,
  }
  use "ray-x/lsp_signature.nvim"
  use "simrat39/symbols-outline.nvim"
  use "b0o/SchemaStore.nvim"
  use "RRethy/vim-illuminate"
  use "j-hui/fidget.nvim"
  use "lvimuser/lsp-inlayhints.nvim"

  -- Statusline
  use "nvim-lualine/lualine.nvim"
  use "SmiteshP/nvim-navic"

  -- Syntax/Treesitter
  use "nvim-treesitter/nvim-treesitter"
  use "JoosepAlviste/nvim-ts-context-commentstring" -- embedded files
  use "p00f/nvim-ts-rainbow" -- parentheses
  use "windwp/nvim-ts-autotag"
  use "kylechui/nvim-surround"
  use {
    "abecodes/tabout.nvim",
    wants = { "nvim-treesitter" }, -- or require if not used so far
  }

  -- Terminal
  use "akinsho/toggleterm.nvim"

  -- Lua Development
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
  use "nvim-lua/popup.nvim"

  -- Snippet
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets"

  -- UI
  use "kyazdani42/nvim-web-devicons"
  use "NvChad/nvim-colorizer.lua"
  use "lunarvim/onedarker.nvim"
  use "catppuccin/nvim"

  -- Utility
  use "rcarriga/nvim-notify"
  use "stevearc/dressing.nvim"
  use "ghillb/cybu.nvim"
  use "moll/vim-bbye"
  use "lewis6991/impatient.nvim"

  -- Registers
  -- use "tversteeg/registers.nvim"

  -- Icon

  -- Startup
  use "goolord/alpha-nvim"

  -- Indent
  use "lukas-reineke/indent-blankline.nvim"

  -- Comment
  use "numToStr/Comment.nvim"
  use "folke/todo-comments.nvim"

  -- Project
  use "ahmedkhalf/project.nvim"

  -- Session
  use "rmagatti/auto-session"
  use "rmagatti/session-lens"

  -- Quickfix
  use "kevinhwang91/nvim-bqf"

  -- Code Runner
  use "is0n/jaq-nvim"
  use {
    "0x100101/lab.nvim",
    run = "cd js && npm ci",
  }

  -- Editing Support
  use "windwp/nvim-autopairs"
  use "monaqa/dial.nvim"
  use "karb94/neoscroll.nvim"
  use "junegunn/vim-slash"

  -- Motion
  use "phaazon/hop.nvim"

  -- Keybinding
  use "folke/which-key.nvim"

  -- Markdown
  use {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
  }

  --Nots
  use "jbyuki/nabla.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
