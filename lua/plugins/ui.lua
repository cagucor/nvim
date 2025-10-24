return {
  -- status line
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = function()
      local navic = require('nvim-navic')
      return {
        options = {
          theme = 'auto',
          globalstatus = true,
          disabled_filetypes = {
            statusline = { 'dashboard', 'alpha' },
            winbar = { 'alpha', 'neo-tree' },
          },
          refresh = {
            winbar = 1000,
          },
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'diagnostics',
            },
          },
          lualine_x = {
            {
              'lsp_status',
              icon = ' ',
              symbols = {
                -- Standard unicode symbols to cycle through for LSP progress:
                spinner = {
                  '⠋',
                  '⠙',
                  '⠹',
                  '⠸',
                  '⠼',
                  '⠴',
                  '⠦',
                  '⠧',
                  '⠇',
                  '⠏',
                },
                -- Delimiter inserted between LSP names:
                separator = ' ',
              },
            },
						-- stylua: ignore
						{
							function() return "  " .. require("dap").status() end,
							cond = function()
								return package.loaded["dap"] and
										require("dap").status() ~= ""
							end,
						},
            {
              'diff',
            },
          },
          lualine_y = {
            {
              'progress',
              separator = ' ',
              padding = {
                left = 1,
                right = 0,
              },
            },
            { 'location', padding = { left = 0, right = 1 } },
          },
        },
        winbar = {
          lualine_c = {
            {
              'filetype',
              icon_only = true,
              separator = '',
              padding = { left = 1, right = 0 },
            },
            {
              'filename',
              -- separator = '>',
            },
            {
              'navic',
              color_correction = 'static',
              padding = { left = 1, right = 0 },
            },
          },
          lualine_x = {
            function()
              return ' '
            end,
          },
        },
        extensions = { 'neo-tree', 'lazy' },
      }
    end,
  },
  -- notifications
  -- {
  --   'rcarriga/nvim-notify',
  --   opts = {
  --     render = "minimal"
  --   },
  -- },
  -- lazy.nvim
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
  -- dashboard
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    opts = function()
      local dashboard = require('alpha.themes.dashboard')
      local logo = [[
           ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
           ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
           ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
           ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
           ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
           ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

      dashboard.section.header.val = vim.split(logo, '\n')
      dashboard.section.buttons.val = {
        dashboard.button(
          'f',
          ' ' .. ' Find file',
          ':Telescope find_files <CR>'
        ),
        dashboard.button(
          'n',
          ' ' .. ' New file',
          ':ene <BAR> startinsert <CR>'
        ),
        dashboard.button(
          'r',
          ' ' .. ' Recent files',
          ':Telescope oldfiles <CR>'
        ),
        dashboard.button(
          'g',
          ' ' .. ' Find text',
          ':Telescope live_grep <CR>'
        ),
        dashboard.button('c', ' ' .. ' Config', ':e $MYVIMRC <CR>'),
        dashboard.button(
          's',
          ' ' .. ' Restore Session',
          [[:lua require("persistence").load() <cr>]]
        ),
        dashboard.button('l', '󰒲 ' .. ' Lazy', ':Lazy<CR>'),
        dashboard.button('q', ' ' .. ' Quit', ':qa<CR>'),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = 'AlphaButtons'
        button.opts.hl_shortcut = 'AlphaShortcut'
      end
      dashboard.section.header.opts.hl = 'AlphaHeader'
      dashboard.section.buttons.opts.hl = 'AlphaButtons'
      dashboard.section.footer.opts.hl = 'AlphaFooter'
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'AlphaReady',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      require('alpha').setup(dashboard.opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = '⚡ Neovim loaded '
            .. stats.count
            .. ' plugins in '
            .. ms
            .. 'ms'
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
  { 'MunifTanjim/nui.nvim', lazy = true },
}
