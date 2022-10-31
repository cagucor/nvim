local status_ok, conditions = pcall(require, "heirline.conditions")
if not status_ok then
  return
end

local status_ok_1, utils = pcall(require, "heirline.utils")
if not status_ok_1 then
  return
end

local status_ok_2, icons = pcall(require, "ui.icons")
if not status_ok_2 then
  return
end

local colors = require("catppuccin.palettes").get_palette "frappe"

local M = {}

M.Space = {
  provider = " ",
}

M.Exclude = {
  condition = function()
    return conditions.buffer_matches {
      buftype = { "nofile", "prompt", "help", "quickfix", "term" },
      filetype = { "^git.*", "fugitive", "NvimTree*", "^alpha$" },
    }
  end,
  init = function()
    vim.opt_local.winbar = nil
  end,
}

M.FileType = {
  provider = function()
    return string.lower(vim.bo.filetype)
  end,
  hl = { fg = utils.get_highlight("Type").fg, bold = true },
  M.Space,
}

M.Fill = {
  provider = function()
    return "%="
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

M.LSPActive = {
  condition = conditions.lsp_attached,
  update = { "LspAttach", "LspDetach" },

  provider = function()
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
  hl = { bold = true },
  M.Space,
}

M.Treesitter = {
  provider = function()
    local ts = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
    return (ts and next(ts)) and "綠TS " or ""
  end,
  hl = { fg = "green" },
}

M.LSP = {
  condition = conditions.lsp_attached or vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()],
  utils.surround({ " ", "" }, colors.surface1, { M.LSPActive, M.Treesitter }),
}

M.FileName = {
  provider = function()
    -- first, trim the pattern relative to the current directory. For other
    -- options, see :h filename-modifers
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    if filename == "" then
      return "[No Name]"
    end
    -- now, if the filename would occupy more than 1/4th of the available
    -- space, we trim the file path to its initials
    -- See Flexible Components section below for dynamic truncation
    if not conditions.width_percent_below(#filename, 0.25) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
  -- hl = { fg = utils.get_highlight("Directory").fg },
  hl = "NavicText",
}

M.FileIcon = {
  init = function(self)
    local filename = vim.api.nvim_buf_get_name(0)
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ")
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}

M.FileInfo = {
  utils.surround({ "", "" }, colors.surface0, { M.FileIcon, M.FileType }),
}

M.FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = icons.ui.Circle,
    hl = { fg = "green" },
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = "",
    hl = { fg = "orange" },
  },
}

M.Navic = {
  condition = require("nvim-navic").is_available,
  provider = function()
    local location = require("nvim-navic").get_location()
    if location == nil or location == "" then
      return ""
    else
      return "%#NavicSeparator# " .. icons.ui.ChevronRight .. " %*" .. location
    end
  end,
  update = "CursorMoved",
}

local mode_colors_map = {
  ["n"] = { "NORMAL", colors.lavender },
  ["no"] = { "N-PENDING", colors.lavender },
  ["i"] = { "INSERT", colors.green },
  ["ic"] = { "INSERT", colors.green },
  ["t"] = { "TERMINAL", colors.green },
  ["v"] = { "VISUAL", colors.flamingo },
  ["V"] = { "V-LINE", colors.flamingo },
  [""] = { "V-BLOCK", colors.flamingo },
  ["R"] = { "REPLACE", colors.maroon },
  ["Rv"] = { "V-REPLACE", colors.maroon },
  ["s"] = { "SELECT", colors.maroon },
  ["S"] = { "S-LINE", colors.maroon },
  [""] = { "S-BLOCK", colors.maroon },
  ["c"] = { "COMMAND", colors.peach },
  ["cv"] = { "COMMAND", colors.peach },
  ["ce"] = { "COMMAND", colors.peach },
  ["r"] = { "PROMPT", colors.teal },
  ["rm"] = { "MORE", colors.teal },
  ["r?"] = { "CONFIRM", colors.mauve },
  ["!"] = { "SHELL", colors.green },
}

M.ViMode = {
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()
    if not self.once then
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:*o",
        command = "redrawstatus",
      })
      self.once = true
    end
  end,
  provider = " ",
  update = {
    "ModeChanged",
  },
}

M.ViMode = utils.surround({ " ", "" }, function()
  return mode_colors_map[vim.fn.mode()][2]
end, { M.ViMode, hl = { fg = colors.base } })

M.GitBranch = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    -- self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,

  hl = { fg = "orange" },

  { -- git branch name
    provider = function(self)
      return "  " .. self.status_dict.head
    end,
    hl = { bold = true },
  },
  -- You could handle delimiters, icons and counts similar to Diagnostics
  M.Space,
}

M.GitDiff = {
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    -- self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,
  M.Space,
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and (icons.git.Add .. count .. " ")
    end,
    hl = "GitSignsAdd",
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and (icons.git.Remove .. count .. " ")
    end,
    hl = "GitSignsDelete",
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and (icons.git.Mod .. count .. " ")
    end,
    hl = "GitSignsChange",
  },
}

M.Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = "%4l:%2c %P ",
  hl = { fg = colors.base },
}

M.ScrollBar = {
  init = function(self)
    self.mode = vim.fn.mode(1) -- :h mode()
    if not self.once then
      vim.api.nvim_create_autocmd("ModeChanged", {
        pattern = "*:*o",
        command = "redrawstatus",
      })
      self.once = true
    end
  end,
  static = {
    sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
    -- sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' }
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = function(self)
    return { fg = colors.overlay0, bold = true }
  end,
}

M.CursorPos = utils.surround({ " ", " " }, function()
  return mode_colors_map[vim.fn.mode()][2]
end, { M.Ruler, M.ScrollBar })

M.Diagnostics = {

  condition = conditions.has_diagnostics,

  static = {
    error_icon = icons.diagnostics.Error,
    warn_icon = icons.diagnostics.Warning,
    info_icon = icons.diagnostics.Information,
    hint_icon = icons.diagnostics.Hint,
  },

  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,

  update = { "DiagnosticChanged", "BufEnter" },

  {
    provider = function(self)
      -- 0 is just another output, we can decide to print it or not!
      return self.errors > 0 and (" " .. self.error_icon .. self.errors .. " ")
    end,
    hl = "DiagnosticError",
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
    end,
    hl = "DiagnosticWarn",
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. " ")
    end,
    hl = "DiagnosticInfo",
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = "DiagnosticHint",
  },
  M.Space,
}

M.Diffs = {
  condition = conditions.is_git_repo or conditions.has_diagnostics,
  utils.surround({ " ", "" }, colors.surface0, { M.GitDiff, M.Diagnostics }),
}

local function env_cleanup(venv)
  if string.find(venv, "/") then
    local final_venv = venv
    for w in venv:gmatch "([^/]+)" do
      final_venv = w
    end
    venv = final_venv
  end
  return venv
end

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
  condition = conditions.hide_in_width,
}

M.Env = {
  condition = conditions.is_git_repo,
  utils.surround({ " ", "" }, colors.surface1, { M.GitBranch }),
}

return M
