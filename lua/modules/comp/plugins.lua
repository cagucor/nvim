local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

local use = packer.use

use {
  "hrsh7th/nvim-cmp",
  requires = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-path", after = "nvim-cmp" },
    { "hrsh7th/cmp-buffer", after = "nvim-cmp" },
    { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" },
    { "hrsh7th/cmp-cmdline", after = "nvim-cmp" },
    { "hrsh7th/cmp-emoji", after = "nvim-cmp" },
    { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp" },
  },
}

use {
  "windwp/nvim-autopairs",
}

use {
  "nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",
}

use {
  "L3MON4D3/LuaSnip",
}
use {
  "saadparwaiz1/cmp_luasnip",
}
