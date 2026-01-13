return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      transparent_background = true,
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
      vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
    end,
  },
  -- {
  --   'Dru89/vim-adventurous',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme('adventurous')
  --     vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
  --     vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
  --     vim.api.nvim_set_hl(0, 'LineNr', { fg = '#686B56', bg = 'NONE' })
  --     vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#EDBB6E', bg = 'NONE', bold = true })
  --     vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
  --     vim.api.nvim_set_hl(0, 'Type', { fg = '#F0C674', bg = 'NONE', underline = false })
  --   end,
  -- },
  -- {
  --   'tanvirtin/monokai.nvim',
  --   priority = 1000,
  --   config = function()
  --     local monokai = require('monokai')
  --     monokai.setup({
  --       palette = monokai.classic,
  --     })
  --     vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
  --     vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
  --     vim.api.nvim_set_hl(0, 'LineNr', { fg = '#75715E', bg = 'NONE' })
  --     vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#F8F8F2', bg = 'NONE', bold = true })
  --   end,
  -- },
}
