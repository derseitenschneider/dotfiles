return {
  'zaldih/themery.nvim',
  lazy = false,
  config = function()
    require('themery').setup({
      themes = { 'catppuccin-mocha', 'rose-pine' },
      livePreview = true,
      -- add the config here
      keymaps = {
        vim.keymap.set('n', '<C-t>', '<cmd>Themery<CR>', { desc = 'Clear search highlights' }),
      },
    })
  end,
}
