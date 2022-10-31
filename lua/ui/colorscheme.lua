-- local colorscheme = "darkplus"
local colorscheme = "catppuccin"

require("catppuccin").setup {
  flavour = "frappe", -- mocha, macchiato, frappe, latte
  integrations = {
    navic = {
      enabled = true,
    }
  }
}

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  -- vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end
