local line_comps = {
  active = {},
  inactive = {},
}

local winbar_comps = {
  active = {},
  inactive = {},
}

local disable = {
  filetypes = {
    "^NvimTree$",
    "^packer$",
    "^alpha$",
    "^fugitive$",
    "^fugitiveblame$",
    "^qf$",
    "^help$",
  },
  buftypes = {},
  bufnames = {},
}

local onenord_status_ok, onenord = pcall(require, "onenord.colors")
if not onenord_status_ok then
  return
end

local vi_mode_utils = require "feline.providers.vi_mode"

local colors = onenord.load()

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

local conditional = {}
local provider = {}

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

function provider.lsp_client_names(expand_null_ls)
  return function()
    local buf_client_names = {}
    for _, client in pairs(vim.lsp.buf_get_clients(0)) do
      if client.name == "null-ls" and expand_null_ls then
        vim.list_extend(buf_client_names, null_ls_sources(vim.bo.filetype, "FORMATTING"))
        vim.list_extend(buf_client_names, null_ls_sources(vim.bo.filetype, "DIAGNOSTICS"))
      else
        table.insert(buf_client_names, client.name)
      end
    end
    return table.concat(buf_client_names, ", ")
  end
end

function provider.treesitter_status()
  local ts = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
  return (ts and next(ts)) and " 綠TS" or ""
end

function provider.spacer(n)
  return string.rep(" ", n or 1)
end

function conditional.git_available()
  return vim.b.gitsigns_head ~= nil
end

function conditional.git_changed()
  local git_status = vim.b.gitsigns_status_dict
  return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
end

function conditional.has_filetype()
  return vim.fn.empty(vim.fn.expand "%:t") ~= 1 and vim.bo.filetype and vim.bo.filetype ~= ""
end

function conditional.bar_width(n)
  return function()
    return (vim.opt.laststatus:get() == 3 and vim.opt.columns:get() or vim.fn.winwidth(0)) > (n or 80)
  end
end

provider.get_navic = function()
  local status_navic_ok, navic = pcall(require, "nvim-navic")
  if not status_navic_ok then
    return ""
  end

  local status_ok, navic_location = pcall(navic.get_location, {})
  if not status_ok then
    return ""
  end

  if not navic.is_available() or navic_location == "error" then
    return ""
  end

  if not require("utils.functions").is_empty(navic_location) then
    return "%#NavicSeparator#" .. require("modules.ui.icons").ui.ChevronRight .. " %*" .. navic_location
  else
    return ""
  end
end

local function vimode_hl()
  return {
    name = vi_mode_utils.get_mode_highlight_name(),
    bg = vi_mode_utils.get_mode_color(),
    fg = colors.bg,
  }
end

line_comps.active[1] = {
  {
    provider = provider.spacer(),
    hl = vimode_hl,
  },
  { provider = provider.spacer(2) },
  { provider = "git_branch", icon = " " },
  { provider = provider.spacer(3), enabled = conditional.git_available },
  {
    provider = {
      name = "file_type",
      opts = { filetype_icon = true, case = "lowercase" },
    },
    enabled = conditional.has_filetype,
  },
  {
    provider = provider.spacer(2),
    enabled = conditional.has_filetype,
  },
  { provider = "git_diff_added", hl = { fg = colors.diff_add } },
  { provider = "git_diff_changed", hl = { fg = colors.diff_change } },
  { provider = "git_diff_removed", hl = { fg = colors.diff_remove } },
  { provider = provider.spacer(2), enabled = conditional.git_changed },
  { provider = "diagnostic_errors", hl = { fg = colors.error } },
  { provider = "diagnostic_warnings", hl = { fg = colors.warn } },
  { provider = "diagnostic_info", hl = { fg = colors.info } },
  { provider = "diagnostic_hints", hl = { fg = colors.hint } },
}

line_comps.active[2] = {
  {
    provider = provider.lsp_client_names(true),
    short_provider = provider.lsp_client_names(),
    enabled = conditional.bar_width(),
    icon = "   ",
  },
  { provider = provider.spacer(2), enabled = conditional.bar_width() },
  {
    provider = provider.treesitter_status,
    enabled = conditional.bar_width(),
    hl = { fg = colors.green },
  },
  { provider = provider.spacer(2) },
  { provider = "line_percentage" },
  { provider = provider.spacer() },
  { provider = "scroll_bar" },
  { provider = provider.spacer(1) },
  { provider = provider.spacer(1), hl = vimode_hl },
  {
    provider = {
      name = "position",
      opts = {
        padding = true,
      },
    },
    hl = vimode_hl,
  },
  { provider = provider.spacer(1), hl = vimode_hl },
}

winbar_comps.active[1] = {
  { provider = "file_info" },
  { provider = provider.spacer(1) },
  { provider = provider.get_navic },
  {
    hl = {
      -- Replace 'oceanblue' with whatever color you want the gap to be.
      bg = colors.active,
    },
  },
}

colors.bg = colors.active

require("feline").setup {
  theme = colors,
  components = line_comps,
  vi_mode_colors = vi_mode_colors,
  disable = disable,
}

require("feline").winbar.setup {
  disable = disable,
  components = winbar_comps,
}
