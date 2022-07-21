local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

local use = packer.use

use {
  "j-hui/fidget.nvim",
}

use {
  "folke/todo-comments.nvim",
}

use {
  "folke/twilight.nvim",
}

use {
  "goolord/alpha-nvim",
}

use {
  "feline-nvim/feline.nvim",
}

use {
  "lewis6991/gitsigns.nvim",
}

use {
  "rmehri01/onenord.nvim",
}

use {
  "kyazdani42/nvim-tree.lua",
  requires = "kyazdani42/nvim-web-devicons",
}

use {
  "folke/which-key.nvim",
}

use {
  "stevearc/dressing.nvim",
}

use {
  "ghillb/cybu.nvim",
}

use {
  "nvim-telescope/telescope.nvim",
  requires = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
  },
}
