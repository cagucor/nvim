local function create_dashboard()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)

  local width = vim.o.columns
  local title = 'NEOVIM'

  local entries = {
    { key = 'f', desc = 'Find file' },
    { key = 'n', desc = 'New file' },
    { key = 'p', desc = 'Projects' },
    { key = 'c', desc = 'Config' },
    { key = 'q', desc = 'Quit' },
  }

  local max_key = math.max(unpack(vim.tbl_map(function(e)
    return #e.key
  end, entries)))

  local entry_lines = {}
  for _, entry in ipairs(entries) do
    local pad = string.rep(' ', max_key - #entry.key)
    table.insert(
      entry_lines,
      '[' .. entry.key .. ']' .. pad .. '  ' .. entry.desc
    )
  end

  -- find longest entry to center the block
  local max_len = math.max(unpack(vim.tbl_map(function(l)
    return #l
  end, entry_lines)))
  local block_pad = string.rep(' ', math.floor((width - max_len) / 2))
  local title_pad = string.rep(' ', math.floor((width - #title) / 2))

  local lines = {
    '',
    '',
    title_pad .. title,
    '',
  }

  for _, line in ipairs(entry_lines) do
    table.insert(lines, block_pad .. line)
  end

  table.insert(lines, '')

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].filetype = 'dashboard'

  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'

  local opts = { buffer = buf, noremap = true, silent = true, nowait = true }
  vim.keymap.set('n', 'f', '<cmd>Telescope find_files<CR>', opts)
  vim.keymap.set('n', 'n', '<cmd>enew<CR>', opts)
  vim.keymap.set('n', 'p', '<cmd>lua require("core.projects").pick()<CR>', opts)
  vim.keymap.set('n', 'c', '<cmd>e ~/.config/nvim/init.lua<CR>', opts)
  vim.keymap.set('n', 'q', '<cmd>qa<CR>', opts)
end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 then
      create_dashboard()
    end
  end,
})
