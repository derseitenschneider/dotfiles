return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'V13Axel/neotest-pest',
    'marilari88/neotest-vitest',
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-pest'),
        require('neotest-vitest'),
      },
    })
  end,
  keymaps = {
    vim.keymap.set('n', '<leader>tn', function()
      require('neotest').run.run()
    end),
    vim.keymap.set('n', '<leader>tf', function()
      require('neotest').run.run(vim.fn.expand('%'))
    end),
  },
}
