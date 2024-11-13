return {
  'praem90/nvim-phpcsf',
  config = function()
    vim.g.nvim_phpcs_config_phpcs_path = 'phpcs'
    vim.g.nvim_phpcs_config_phpcbf_path = 'phpcbf'
    --
    -- Function to check if file is in vendor directory
    local function is_vendor_file()
      local file_path = vim.fn.expand('%:p')
      return string.match(file_path, '/vendor/') ~= nil
    end

    -- Setup auto formatting for php files using phpcs
    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('PHPCSGroup', { clear = true }),
      pattern = '*.php',
      -- command = 'lua require\'phpcs\'.cs()',
      callback = function()
        if not is_vendor_file() then
          require('phpcs').cs()
        end
      end,
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = vim.api.nvim_create_augroup('PHPCSGroup', { clear = true }),
      pattern = '*.php',
      -- command = 'lua require\'phpcs\'.cbf()',
      callback = function()
        if not is_vendor_file() then
          require('phpcs').cbf()
        end
      end,
    })

    vim.keymap.set('n', '<leader>lp', function()
      -- require('phpcs').cbf()
      if not is_vendor_file() then
        require('phpcs').cbf()
      end
    end, {
      silent = true,
      noremap = true,
      desc = 'PHP Fix',
    })
    -- Use local phpcs.xml standard instead of WordPress
    vim.g.nvim_phpcs_config_phpcs_standard = './phpcs.xml'
    -- Additional configuration to ignore vendor
    vim.g.nvim_phpcs_config_phpcs_args = '--ignore=*/vendor/*,vendor/* --basepath=.'
    vim.g.nvim_phpcs_config_ignore_patterns = {
      'vendor/*',
      '*/vendor/*',
    }
  end,
}
