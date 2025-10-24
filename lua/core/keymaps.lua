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
keymap('n', '<leader>st', '<cmd>setlocal spell! spelllang=en_nz<CR>')

-- File system
keymap('n', '<leader>e', ':Neotree toggle<CR>', opts)

-- Fuzzy Search
keymap('n', '<leader>ft', '<cmd>Telescope live_grep<CR>')
keymap('n', '<leader>ff', '<cmd>Telescope fd<CR>')
keymap('n', '<leader>fb', '<cmd>Telescope buffers initial_mode=normal sort_mru=true theme=ivy<CR>')

-- Completion

-- Terminals
keymap(
  { 'n', 't', 'i' },
  '<m-1>',
  '<cmd>ToggleTerm size=20 direction=horizontal<cr>',
  { noremap = true, silent = true }
)
keymap(
  { 'n', 't', 'i' },
  '<m-2>',
  '<cmd>ToggleTerm size=60 direction=vertical<cr>',
  { noremap = true, silent = true }
)
keymap(
  { 'n', 't', 'i' },
  '<m-3>',
  '<cmd>ToggleTerm direction=float<cr>',
  { noremap = true, silent = true }
)

-- Diagnostics
keymap('n', 'gl', vim.diagnostic.open_float)
keymap('n', '[d', vim.diagnostic.goto_prev)
keymap('n', ']d', vim.diagnostic.goto_next)
keymap('n', '<space>q', vim.diagnostic.setloclist)

-- Formatting
keymap('n', '<leader>lf', '<cmd>lua require("conform").format()<CR>')

-- Commenting
keymap(
  'n',
  '<space>/',
  '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>'
)
keymap(
  'x',
  '<leader>/',
  '<ESC><CMD>lua require(\'Comment.api\').toggle.linewise(vim.fn.visualmode())<CR>',
  opts
)

-- lsp 
keymap('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>')

-- Dismiss the notifications
keymap({ 'n', 'v' }, '<leader>d', '<cmd>lua require("notify").dismiss()<CR>')
