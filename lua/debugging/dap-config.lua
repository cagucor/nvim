local dap = require "dap"
local mason_pacakge = require "mason-core.package"

dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = mason_pacakge:get_install_path() .. '/codelldb/extension/adapter/codelldb',
    args = {"--port", "${port}"},
  }
}

dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}
