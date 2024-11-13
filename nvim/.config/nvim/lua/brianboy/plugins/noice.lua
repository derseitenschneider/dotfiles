return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {},
  dependencies = {
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   If not available, we use `mini` as the fallback
    'rcarriga/nvim-notify',
  },
  config = function()
    require('notify').setup({
      timeout = 500,
      render = 'default',
      stages = 'fade',
      level = vim.log.levels.INFO,
      max_width = 50,
      max_height = 10,
      background_colour = 'Transparent',
      icons = {
        ERROR = '',
        WARN = '',
        INFO = '',
        DEBUG = '',
        TRACE = '✎',
      },
      time_formats = {
        notification = '%H:%M',
        notification_history = '%FT%T',
      },
      on_open = function() end,
      on_close = function() end,
      minimum_width = 50,
      fps = 30,
      top_down = true,
    })

    vim.notify = require('notify')

    require('noice').setup({
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      vim.keymap.set('n', '<leader>nd', '<cmd>NoiceDismiss<CR>', { desc = 'Dismiss Noice Message' }),
      -- you can enable a preset for easier configuration
      presets = {
        -- command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      notify = {
        enabled = true,
        view = 'notify',
      },
      views = {
        notify = {
          timeout = 500,
          replace = true,
          render = 'minimal',
        },
      },
    })
  end,
}
