-- debug.lua
-- Shows how to use the DAP plugin to debug your code.

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/leoluz/nvim-dap-go',
}

-- Basic debugging keymaps
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>b', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>B', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
vim.keymap.set('n', '<F7>', function() require('dapui').toggle() end, { desc = 'Debug: See last session result.' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  automatic_installation = true,

  -- 1. TELL MASON TO LEAVE PHP TO US
  handlers = {
    -- This blank function prevents mason-nvim-dap from overriding our php configuration
    php = function(config) end,
  },

  ensure_installed = {
    'delve',
    'php-debug-adapter', -- Ensures PHP adapter stays installed via Mason
  },
}

-- 2. MANUALLY SET UP PHP ADAPTER WITH CORRECT PATHS
dap.adapters.php = {
  type = 'executable',
  command = 'node',
  args = { vim.fn.stdpath('data') .. '/mason/packages/php-debug-adapter/extension/out/phpDebug.js' }
}

-- 3. ADD YOUR DYNAMIC DOCKER PATH MAPPINGS
dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug (Dynamic Docker)',
    port = 9003,
    pathMappings = function()
      local cwd = vim.fn.getcwd()
      local current_folder = vim.fs.basename(cwd)
      local container_path = '/var/www/' .. current_folder

      return {
        [container_path] = cwd
      }
    end
  }
}

-- Dap UI setup
---@diagnostic disable-next-line: missing-fields
dapui.setup {
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸', play = '▶', step_into = '⏎', step_over = '⏭',
      step_out = '⏮', step_back = 'b', run_last = '▶▶', terminate = '⏹', disconnect = '⏏',
    },
  },
}

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Install golang specific config
require('dap-go').setup {
  delve = {
    detached = vim.fn.has 'win32' == 0,
  },
}

