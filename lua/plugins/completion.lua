require('blink.cmp').setup({
  keymap = { preset = 'enter' },

  snippets = { preset = 'luasnip' },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = { auto_show = false },
    keyword = {
      range = 'full',
    },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  fuzzy = { implementation = 'rust' },
})
