local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

local use = packer.use

use {
  "williamboman/nvim-lsp-installer",
}

use {
  "neovim/nvim-lspconfig",
}
use {
  "folke/trouble.nvim",
  requires = "kyazdani42/nvim-web-devicons",
}

use {
  "jose-elias-alvarez/null-ls.nvim",
  requires = "nvim-lua/plenary.nvim",
}

use {
  "ray-x/lsp_signature.nvim",
}

use {
  "SmiteshP/nvim-navic",
  requires = "neovim/nvim-lspconfig",
}

use {
  "RRethy/vim-illuminate",
}
