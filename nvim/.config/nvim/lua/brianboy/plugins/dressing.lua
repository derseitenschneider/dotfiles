return {
  'stevearc/dressing.nvim',
  event = 'VeryLazy',
  config = function()
    require('dressing').setup({
      enabled = true,
      start_mode = 'normal',
    })
  end,
}
