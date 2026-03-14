return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  build = ':TSUpdate',
  dependencies = {
    'windwp/nvim-ts-autotag',
  },
  config = function()
    require('nvim-treesitter').setup({
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
        'rust',
      },
      auto_install = false,
    })
  end,
}
