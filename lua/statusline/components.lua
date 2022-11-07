local status_ok, icons = pcall(require, "ui.icons")
if not status_ok then
  return
end

local colors = require("catppuccin.palettes").get_palette "frappe"

local M = {}

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

M.Lspservers = {
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
    return icons.ui.Gear .. " " .. table.concat(buf_client_names, ", ")
  end,
}

M.Treesitter = {
  function()
    local ts = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
    return (ts and next(ts)) and "綠TS " or ""
  end,
  color = { fg = colors.green },
}

M.Navic = {
  cond = require("nvim-navic").is_available,
  function()
    local location = require("nvim-navic").get_location()
    if location == nil or location == "" then
      return ""
    else
      return location
    end
  end,
  padding = { left = 1 },
}

M.Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  "%3l:%2c ",
  hl = { fg = colors.base },
}

M.PythonEnv = {
  provider = function()
    if vim.bo.filetype == "python" then
      local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
      if venv then
        local icon = require "nvim-web-devicons"
        local py_icon, _ = icon.get_icon ".py"
        return string.format(" " .. py_icon .. " (%s)", env_cleanup(venv))
      end
    end
    return ""
  end,
  hl = { fg = colors.green },
}

M.Vimode = {
  function()
    return " "
  end,
  separator = { left = " " },
}

local hide_in_width_60 = function()
  return vim.o.columns > 60
end

local hide_in_width = function()
  return vim.o.columns > 80
end

local hide_in_width_100 = function()
  return vim.o.columns > 100
end

M.Diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  sections = { "error", "warn", "info", "hint" },
  symbols = {
    error = icons.diagnostics.Error,
    warn = icons.diagnostics.Warning,
    info = icons.diagnostics.Information,
    hint = icons.diagnostics.Hint,
  },
  update_in_insert = false,
  padding = 1,
}

M.Diff = {
  "diff",
  symbols = { added = icons.git.Add .. " ", modified = icons.git.Mod .. " ", removed = icons.git.Remove .. " " }, -- changes diff symbols
  cond = hide_in_width_60,
  separator = "%#SLSeparator#" .. "│ " .. "%*",
  padding = 1,
}

M.Filetype = {
  "filetype",
  padding = { left = 1 },
}

M.Filename = {
  "filename",
  symbols = {
    modified = icons.ui.Circle, -- Text to show when the file is modified.
    readonly = icons.ui.Lock, -- Text to show when the file is non-modifiable or readonly.
    unnamed = icons.ui.Pencil, -- Text to show for unnamed buffers.
    newfile = icons.ui.NewFile, -- Text to show for new created file before first writting
  },
  padding = { right = 1, left = 1 },
}

M.Branch = {
  "branch",
  icons_enabled = true,
  icon = " ",
  -- color = "Constant",
  colored = false,
  padding = 0,
  -- cond = hide_in_width_100,
  fmt = function(str)
    if str == "" or str == nil then
      return "!=vcs"
    end

    return str
  end,
}

M.Scrollbar = {
  function()
    local current_line = vim.fn.line "."
    local total_lines = vim.fn.line "$"
    local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
    local line_ratio = current_line / total_lines
    local index = math.ceil(line_ratio * #chars)
    return "%P " .. chars[index]
  end,
  separator = { right = " " },
}

return M
