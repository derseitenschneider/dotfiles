return {
  'pwntester/octo.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  cmd = 'Octo',
  keys = {
    {
      '<leader>gh',
      '<cmd>Octo<cr>',
      desc = 'Octo',
    },
  },
  config = function()
    require('octo').setup({
      default_to_projects_v2 = true,
      enable_builtin = true,
    })
  end,
}
