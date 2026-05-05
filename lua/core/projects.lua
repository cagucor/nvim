local M = {}
local projects_file = vim.fn.stdpath('data') .. '/projects.json'
local sessions_dir = vim.fn.stdpath('data') .. '/project_sessions/'

-- ensure sessions dir exists
vim.fn.mkdir(sessions_dir, 'p')

local root_markers = {
  '.git',
  '.luarc.json',
  '.venv/',
  'pyproject.toml',
  'Cargo.toml',
  'package.json',
  'Makefile',
}

local function is_project_root(dir)
  for _, marker in ipairs(root_markers) do
    if
      vim.fn.filereadable(dir .. '/' .. marker) == 1
      or vim.fn.isdirectory(dir .. '/' .. marker) == 1
    then
      return true
    end
  end
  return false
end

local function load_projects()
  if vim.fn.filereadable(projects_file) == 0 then
    return {}
  end
  local content = vim.fn.readfile(projects_file)
  if #content == 0 then
    return {}
  end
  local ok, data = pcall(vim.json.decode, table.concat(content, ''))
  if not ok then
    return {}
  end
  return data or {}
end

local function save_projects(projects)
  local ok, encoded = pcall(vim.json.encode, projects)
  if not ok then
    return
  end
  vim.fn.writefile({ encoded }, projects_file)
end

local function session_file(dir)
  return sessions_dir .. dir:gsub('/', '%%') .. '.vim'
end

local function save_session(dir)
  vim.cmd('mksession! ' .. vim.fn.fnameescape(session_file(dir)))
end

local function restore_session(dir)
  local sf = session_file(dir)
  if vim.fn.filereadable(sf) == 1 then
    vim.cmd('source ' .. vim.fn.fnameescape(sf))
  end
end

function M.record_project()
  local cwd = vim.fn.getcwd()
  if not is_project_root(cwd) then
    return
  end

  local projects = load_projects()
  -- check if already recorded, move to top if so
  for i, p in ipairs(projects) do
    if p == cwd then
      table.remove(projects, i)
      break
    end
  end
  table.insert(projects, 1, cwd)

  -- keep only last 20 projects
  if #projects > 20 then
    projects = vim.list_slice(projects, 1, 20)
  end

  save_projects(projects)
end

function M.save_current_session()
  local cwd = vim.fn.getcwd()
  if is_project_root(cwd) then
    save_session(cwd)
  end
end

function M.pick(callback)
  local projects = load_projects()
  if #projects == 0 then
    vim.notify('No projects found')
    return
  end

  -- show relative paths where possible
  local home = vim.fn.expand('~')
  local display = vim.tbl_map(function(p)
    return p:gsub('^' .. home, '~')
  end, projects)

  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers
    .new({}, {
      prompt_title = 'Projects',
      finder = finders.new_table({
        results = display,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            local dir = projects[selection.index]
            if callback then
              callback(dir)
            else
              vim.cmd('cd ' .. vim.fn.fnameescape(dir))
              restore_session(dir)
            end
          end
        end)
        return true
      end,
    })
    :find()
end

-- record project on enter
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    M.record_project()
  end,
})

-- save session on leave
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    M.save_current_session()
  end,
})

return M
