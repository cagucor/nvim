local servers = {
  'lua_ls',
  'rust_analyzer',
  'cssls',
  'pyright',
  'ruff',
  'clangd',
}

for _, server in ipairs(servers) do
  local ok, config = pcall(require, 'servers.' .. server)
  if ok then
    vim.lsp.config(server, config)
  end
end

vim.lsp.enable(servers)
