-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Shorten function name
local keymap = vim.keymap.set
-- Silent keymap option
local opts = { silent = true }

--Remap space as leader key
keymap('', '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '

-- Toggle spell check
keymap(
  'n',
  '<leader>r',
  ':SpellReplace<CR>',
  { desc = 'Replace misspelled word' }
)

-- File system
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-- Fuzzy Search
keymap('n', '<leader>ft', '<cmd>Telescope live_grep<CR>')
keymap('n', '<leader>ff', '<cmd>Telescope fd<CR>')
keymap(
  'n',
  '<leader>fb',
  '<cmd>Telescope buffers initial_mode=normal sort_mru=true theme=ivy<CR>'
)

-- Spell check
-- Keymap to toggle spell check with en_NZ and custom highlight
keymap('n', '<leader>s', function()
  -- Toggle spell checking
  vim.opt_local.spell = not vim.opt_local.spell:get()

  if vim.opt_local.spell:get() then
    -- Set language to New Zealand English
    vim.opt_local.spelllang = 'en_nz'

    -- Highlight misspelled words with a red background
    vim.cmd([[
      highlight clear SpellBad
      highlight SpellBad guibg=#FFCCCC guifg=#550000 ctermbg=red ctermfg=white
    ]])

    print('Spell check enabled (en_NZ)')
  else
    print('Spell check disabled')
  end
end, { desc = 'Toggle spell check (en_NZ)' })

-- Completion

-- Terminals
local terminal = require('core.terminal')
keymap({ 'n', 't', 'i' }, '<m-1>', function()
  terminal.toggle('horizontal')
end, { noremap = true, silent = true })
keymap({ 'n', 't', 'i' }, '<m-2>', function()
  terminal.toggle('vertical')
end, { noremap = true, silent = true })
keymap({ 'n', 't', 'i' }, '<m-3>', function()
  terminal.toggle('float')
end, { noremap = true, silent = true })
keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
keymap({ 'n', 't', 'i' }, '<m-4>', function()
  terminal.new()
end, { noremap = true, silent = true })

-- Diagnostics
keymap('n', 'gl', vim.diagnostic.open_float)
keymap('n', '<space>q', vim.diagnostic.setloclist)
keymap('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end)
keymap('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end)
keymap('n', '[e', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end)
keymap('n', ']e', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end)
keymap('n', '[w', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARNING }) end)
keymap('n', ']w', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARNING }) end)
keymap('n', '[h', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.HINT }) end)
keymap('n', ']h', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.HINT }) end)

-- Formatting
keymap('n', '<leader>lf', '<cmd>lua require("conform").format()<CR>')

-- lsp
keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>')
keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>')
keymap('n', 'gI', '<cmd>Telescope lsp_implementations<CR>')

-- Buffer navigation
keymap('n', '<leader>bs', ':ls<CR>')
keymap('n', '<leader>bn', ':bn<CR>')
keymap('n', '<leader>bp', ':bp<CR>')
keymap('n', '<leader>bd', ':bd<CR>')
