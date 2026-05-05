local M = {}
local terminals = {}
local current = nil

local function get_or_create(name)
  if terminals[name] and vim.api.nvim_buf_is_valid(terminals[name]) then
    return terminals[name]
  end
  local buf = vim.api.nvim_create_buf(false, true)
  terminals[name] = buf
  return buf
end

local function open(name, direction)
  local buf = get_or_create(name)
  current = name

  if direction == 'float' then
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.6)
    vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      style = 'minimal',
      border = 'rounded',
    })
  elseif direction == 'horizontal' then
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_win_set_height(0, 15)
  elseif direction == 'vertical' then
    vim.cmd('vsplit')
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_win_set_width(0, 50)
  end

  if vim.bo[buf].buftype ~= 'terminal' then
    vim.fn.termopen(vim.o.shell)
    vim.api.nvim_buf_set_name(buf, 'term://' .. name)
  end

  vim.cmd('startinsert')
end

local function close_current()
  if not current then
    return false
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == terminals[current] then
      vim.api.nvim_win_close(win, false)
      return true
    end
  end
  return false
end

local function is_open()
  if not current or not terminals[current] then
    return false
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == terminals[current] then
      return true
    end
  end
  return false
end

local function valid_sessions()
  local names = {}
  for name, buf in pairs(terminals) do
    if vim.api.nvim_buf_is_valid(buf) then
      table.insert(names, name)
    end
  end
  return names
end

local function pick_session(direction)
  local names = valid_sessions()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local themes = require('telescope.themes')

  pickers
    .new(themes.get_cursor(), {
      prompt_title = 'Terminal Sessions',
      finder = finders.new_table({ results = names }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            open(selection[1], direction)
          end
        end)
        return true
      end,
    })
    :find()
end

function M.toggle(direction)
  -- if open, close it
  if is_open() then
    close_current()
    return
  end

  local names = valid_sessions()

  -- no sessions yet, create default
  if #names == 0 then
    open('default', direction)
    return
  end

  -- one session, just open it
  if #names == 1 then
    open(names[1], direction)
    return
  end

  -- multiple sessions, use telescope picker
  pick_session(direction)
end

function M.new()
  vim.ui.input({ prompt = 'Session name: ' }, function(name)
    if not name or name == '' then
      local count = 0
      for _, _ in pairs(terminals) do
        count = count + 1
      end
      name = 'session-' .. (count + 1)
    end
    open(name, 'float')
  end)
end

return M
