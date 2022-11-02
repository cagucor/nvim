local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local components = require "statusline.components"

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = true,
    theme = "catppuccin",
    component_separators = "",
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree", "lir" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { components.Vimode, components.Branch },
    lualine_b = { components.Filetype },
    lualine_c = { components.Diff },
    lualine_x = { components.Diagnostics },
    lualine_y = { components.Lspservers, components.Treesitter },
    lualine_z = { components.Ruler, components.Scrollbar },
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { components.Navic },
    lualine_x = { { "filetype", icon_only = true }, components.Filename },
    lualine_y = {},
    lualine_z = {},
  },
  inactive_winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { components.Navic },
    lualine_x = { { "filetype", icon_only = true }, components.Filename },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}
