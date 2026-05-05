return {
  cmd = {
    'lua-language-server',
  },
  filetypes = {
    'lua',
  },
  root_markers = {
    '.git',
    '.luacheckrc',
    '.luarc.json',
    '.stylua.toml',
  },
  single_file_support = true,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
