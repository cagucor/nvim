local M = {}

local function setup_colors()
  -- Pull the palette from the catppuccin plugin
  local has_catppuccin, catppuccin_palettes = pcall(require, "catppuccin.palettes")
  if has_catppuccin then
    local cp = catppuccin_palettes.get_palette()
    vim.api.nvim_set_hl(0, 'StatusLineNormal',  { fg = cp.base, bg = cp.blue, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineInsert',  { fg = cp.base, bg = cp.green, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineVisual',  { fg = cp.base, bg = cp.mauve, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineCommand', { fg = cp.base, bg = cp.yellow, bold = true })
    vim.api.nvim_set_hl(0, 'StatusLineReplace', { fg = cp.base, bg = cp.red, bold = true })
  else
    -- Fallback colors if catppuccin isn't loaded yet
    vim.api.nvim_set_hl(0, 'StatusLineNormal',  { fg = '#000000', bg = '#82a1f1', bold = true })
    -- ... add other fallbacks if you want
  end
end

local modes = {
  ['n'] = 'NORMAL',
  ['i'] = 'INSERT',
  ['v'] = 'VISUAL',
  ['V'] = 'V-LINE',
  [''] = 'V-BLOCK',
  ['c'] = 'COMMAND',
  ['r'] = 'REPLACE',
  ['t'] = 'TERMINAL',
}

local mode_colors = {
  ['n']  = '%#StatusLineNormal#',
  ['i']  = '%#StatusLineInsert#',
  ['v']  = '%#StatusLineVisual#',
  ['V']  = '%#StatusLineVisual#',
  [' ']  = '%#StatusLineVisual#', -- V-BLOCK
  ['c']  = '%#StatusLineCommand#',
  ['r']  = '%#StatusLineReplace#',
  ['R']  = '%#StatusLineReplace#',
  ['t']  = '%#StatusLineInsert#',
}

function M.mode()
  local mode = vim.api.nvim_get_mode().mode
  local color = mode_colors[mode] or '%#StatusLine#'
  local label = modes[mode] or mode
  return color .. ' ' .. label .. ' %#StatusLine#'
end

function M.git_branch()
  local branch = vim.b.gitsigns_head
  if not branch then
    return ''
  end
  return '  ' .. branch .. ' '
end

function M.git_diff()
  local status = vim.b.gitsigns_status_dict
  if not status then
    return ''
  end
  local added = status.added
      and status.added > 0
      and ('%#DiffAdd# +' .. status.added .. ' ')
    or ''
  local changed = status.changed
      and status.changed > 0
      and ('%#DiffChange# ~' .. status.changed .. ' ')
    or ''
  local removed = status.removed
      and status.removed > 0
      and ('%#DiffDelete# -' .. status.removed .. ' ')
    or ''
  return added .. changed .. removed .. '%#StatusLine#'
end

function M.filepath()
  if vim.bo.buftype == 'terminal' then
    return ''
  end
  local path = vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.')
  if path == '' then
    return ' [No Name] '
  end
  return ' ' .. path .. ' '
end

function M.filestate()
  if vim.bo.readonly then
    return ' RO '
  end
  if vim.bo.modified then
    return ' ● '
  end
  return ''
end

function M.diagnostics()
  local errors =
    #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings =
    #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local hints =
    #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
  local result = ''
  if errors > 0 then
    result = result .. '%#DiagnosticError#  ' .. errors .. ' '
  end
  if warnings > 0 then
    result = result .. '%#DiagnosticWarn#  ' .. warnings .. ' '
  end
  if hints > 0 then
    result = result .. '%#DiagnosticHint#  ' .. hints .. ' '
  end
  if result ~= '' then
    result = result .. '%#StatusLine#'
  end
  return result
end

function M.lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ''
  end
  local names = {}
  for _, client in ipairs(clients) do
    table.insert(names, client.name)
  end
  return '  ' .. table.concat(names, ', ') .. ' '
end

function M.macro()
  local reg = vim.fn.reg_recording()
  if reg == '' then
    return ''
  end
  return '%#DiagnosticWarn#  @' .. reg .. ' %#StatusLine#'
end

function M.searchcount()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local ok, result = pcall(vim.fn.searchcount, { maxcount = 999 })
  if not ok then
    return ''
  end
  if not result or not result.total or not result.current then
    return ''
  end
  if result.total == 0 then
    return ''
  end
  return '  ' .. result.current .. '/' .. result.total .. ' '
end

function M.terminal_session()
  if vim.bo.buftype ~= 'terminal' then
    return ''
  end
  local name = vim.api.nvim_buf_get_name(0)
  name = name:match('term://(.+)$')
  if not name then
    return ''
  end
  return '  ' .. name .. ' '
end

local function setup()
  vim.o.statusline = table.concat({
    '%{%v:lua.require("core.statusline").mode()%}',
    '%{%v:lua.require("core.statusline").terminal_session()%}',
    '%{%v:lua.require("core.statusline").git_branch()%}',
    '%{%v:lua.require("core.statusline").git_diff()%}',
    '%<',
    '%{%v:lua.require("core.statusline").filepath()%}',
    '%{%v:lua.require("core.statusline").filestate()%}',
    '%=',
    '%{%v:lua.require("core.statusline").macro()%}',
    '%{%v:lua.require("core.statusline").searchcount()%}',
    '%{%v:lua.require("core.statusline").diagnostics()%}',
    '%{%v:lua.require("core.statusline").lsp_status()%}',
    ' %l:%c ',
  }, '')

  vim.api.nvim_create_autocmd('User', {
    pattern = 'GitSignsUpdate',
    callback = function()
      vim.cmd.redrawstatus()
    end,
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function()
      vim.cmd.redrawstatus()
    end,
  })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = setup_colors,
})

setup_colors()

setup()

return M
