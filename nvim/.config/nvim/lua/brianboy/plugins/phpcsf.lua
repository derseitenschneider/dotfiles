return {
  'praem90/nvim-phpcsf',
  config = function()
    -- Basic paths
    vim.g.nvim_phpcs_config_phpcs_path = 'phpcs'
    vim.g.nvim_phpcs_config_phpcbf_path = 'phpcbf'

    -- Explicitly set the standard and make sure it's absolute
    local custom_standard = vim.fn.expand('~/.config/phpcs.xml')

    -- Force the standard in multiple places
    vim.g.nvim_phpcs_config_phpcs_standard = custom_standard
    vim.g.nvim_phpcs_config_phpcbf_standard = custom_standard
    vim.g.nvim_phpcs_config_phpcs_args = '--standard='
      .. custom_standard
      .. ' --report=json --ignore=*/vendor/*,vendor/* --basepath=.'
    vim.g.nvim_phpcs_config_phpcbf_args = '--standard='
      .. custom_standard
      .. ' --ignore=*/vendor/*,vendor/* --basepath=.'

    local function is_vendor_file()
      local file_path = vim.fn.expand('%:p')
      return string.match(file_path, '/vendor/') ~= nil
    end

    -- Create a more aggressive check function
    local function run_phpcs()
      if not is_vendor_file() then
        -- Force reload the standard before checking
        vim.fn.system('phpcs --config-set default_standard ' .. custom_standard)
        require('phpcs').cs()
      end
    end

    -- Run on multiple events to ensure it's always active
    local group = vim.api.nvim_create_augroup('PHPCSGroup', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave', 'TextChanged', 'TextChangedI' }, {
      group = group,
      pattern = '*.php',
      callback = run_phpcs,
    })

    vim.api.nvim_create_autocmd('BufWritePre', {
      group = group,
      pattern = '*.php',
      callback = function()
        if not is_vendor_file() then
          require('phpcs').cbf()
        end
      end,
    })

    vim.keymap.set('n', '<leader>lp', function()
      if not is_vendor_file() then
        require('phpcs').cbf()
      end
    end, {
      silent = true,
      noremap = true,
      desc = 'PHP Fix',
    })

    vim.g.nvim_phpcs_config_ignore_patterns = {
      'vendor/*',
      '*/vendor/*',
    }
  end,
}
