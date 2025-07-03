return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  build = ':TSUpdate',
  dependencies = {
    'windwp/nvim-ts-autotag',
  },
  config = function()
    local treesitter = require('nvim-treesitter.configs')

    treesitter.setup({
      modules = {},
      sync_install = false,
      ignore_install = {},
      auto_install = false,

      highlight = {
        enable = true,
      },
      indent = { enable = true },

      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = true,
      },
      ensure_installed = {
        'json',
        'php',
        'sql',
        'javascript',
        'typescript',
        'tsx',
        'yaml',
        'html',
        'css',
        'markdown',
        'markdown_inline',
        'bash',
        'lua',
        'vim',
        'dockerfile',
        'gitignore',
        'query',
        'vimdoc',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
    })
  end,
}
