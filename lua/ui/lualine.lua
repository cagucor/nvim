-- Bubbles config for lualine
-- Author: lokesh-krishna
-- MIT license, see LICENSE for more details.

local colors = require("catppuccin.palettes").get_palette "frappe"
local icons = require("config.ui.icons")

local vi_mode_colors = {
  NORMAL = colors.blue,
  INSERT = colors.green,
  VISUAL = colors.purple,
  OP = colors.green,
  BLOCK = colors.blue,
  REPLACE = colors.violet,
  ["V-REPLACE"] = colors.violet,
  ENTER = colors.cyan,
  MORE = colors.cyan,
  SELECT = colors.orange,
  COMMAND = colors.green,
  SHELL = colors.green,
  TERM = colors.green,
  NONE = colors.yellow,
}

local mode = {
  function()
    -- return "▊"
    return " "
    -- return "  "
  end,
  color = function()
    -- auto change color according to neovims mode
    return { fg = vi_mode_colors[vim.fn.mode()] }
  end,
  separator = { left = " " },
  right_padding = 2,
}

local treesitter_status = {
  function()
    local ts = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
    return (ts and next(ts)) and " 綠TS" or ""
  end,
  color = function()
    return { fg = colors.green }
  end,
}

local function null_ls_providers(filetype)
  local registered = {}
  local sources_avail, sources = pcall(require, "null-ls.sources")
  if sources_avail then
    for _, source in ipairs(sources.get_available(filetype)) do
      for method in pairs(source.methods) do
        registered[method] = registered[method] or {}
        table.insert(registered[method], source.name)
      end
    end
  end
  return registered
end

local function null_ls_sources(filetype, source)
  local methods_avail, methods = pcall(require, "null-ls.methods")
  return methods_avail and null_ls_providers(filetype)[methods.internal[source]] or {}
end

local lsp_client_names = {
  function()
    local buf_client_names = {}
    for _, client in pairs(vim.lsp.get_active_clients()) do
      if client.name == "null-ls" then
        vim.list_extend(buf_client_names, null_ls_sources(vim.bo.filetype, "FORMATTING"))
        vim.list_extend(buf_client_names, null_ls_sources(vim.bo.filetype, "DIAGNOSTICS"))
      else
        table.insert(buf_client_names, client.name)
      end
    end
    return "  " .. table.concat(buf_client_names, ", ")
  end,
}

require("lualine").setup {
  options = {
    theme = "catppuccin",
    component_separators = "",
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
  },
  sections = {
    lualine_a = { mode },
    lualine_b = { { "branch", icon = icons.git.Branch }, "filetype" },
    lualine_c = { { "diff", symbols = { added = icons.git.Add, modified = icons.git.Mod, removed = icons.git.Remove } } },
    lualine_x = { "diagnostics", lsp_client_names, treesitter_status },
    lualine_y = { "progress" },
    lualine_z = {
      { "location", separator = { right = " " }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { "filename" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}
