return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require('lualine')
    local lazy_status = require('lazy.status') -- to configure lazy pending updates count

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = 'catppuccin',
        component_separators = { left = '|', right = '|' },
        section_separators = { left = ' ', right = '' },
      },
      -- hide = {
      --   place = { 'tabline' },
      -- },
      --
      tabline = {},
      -- sections = {
      --   lualine_x = {
      --     {
      --       lazy_status.updates,
      --       cond = lazy_status.has_updates,
      --       color = { fg = '#ff9e64' },
      --     },
      --     { 'encoding' },
      --     { 'fileformat' },
      --     { 'filetype' },
      --     { 'location' },
      --   },
      -- },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_d = { 'hostname' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    })
    vim.opt.showtabline = 0
  end,
}
