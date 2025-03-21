return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require('lualine')
    local lazy_status = require('lazy.status') -- to configure lazy pending updates count

    -- configure lualine with modified theme
    lualine.setup({
      enabled = false,
      options = {
        theme = 'catppuccin',
        component_separators = { left = '|', right = '|' },
        section_separators = { left = ' ', right = '' },
      },
      tabline = {},
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_d = { 'message' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    })
    vim.opt.showtabline = 0
  end,
}
