-- local colorscheme = "darkplus"
local colorscheme = "catppuccin"
local palette = "frappe"

local cp = require("catppuccin.palettes").get_palette (palette)

require("catppuccin").setup {
  flavour = palette, -- mocha, macchiato, frappe, latte
  integrations = {
    navic = {
      enabled = true,
      custom_bg = cp.mantle
    },
  },
}

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  -- vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end
