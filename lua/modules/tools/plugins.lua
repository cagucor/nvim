local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

local use = packer.use

use { "numToStr/Comment.nvim" }

use { "lewis6991/impatient.nvim" }

use { "ahmedkhalf/project.nvim" }

use { "famiu/bufdelete.nvim" }

use { "akinsho/toggleterm.nvim" }

