require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    markdown = { 'mdformat' },
    cpp = { 'clang-format' },
    python = { 'ruff_fix', 'ruff_format' },
  },
  formatters = {
    mdformat = {
      append_args = { '--wrap', '80' },
    },
  },
})
