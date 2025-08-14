return {
  'praem90/nvim-phpcsf',
  config = function()
    -- Function to find project's phpcs binaries
    local function get_project_phpcs_paths()
      local current_file = vim.api.nvim_buf_get_name(0)
      if current_file == '' then
        return 'phpcs', 'phpcbf'
      end
      
      local current_dir = vim.fn.fnamemodify(current_file, ':h')
      local config_files = vim.fs.find({ 'phpcs.xml', '.phpcs.xml', 'composer.json' }, {
        path = current_dir,
        upward = true,
        limit = 1,
      })
      
      if #config_files > 0 then
        local project_root = vim.fn.fnamemodify(config_files[1], ':h')
        local vendor_phpcs = project_root .. '/vendor/bin/phpcs'
        local vendor_phpcbf = project_root .. '/vendor/bin/phpcbf'
        
        if vim.fn.executable(vendor_phpcs) == 1 then
          return vendor_phpcs, vendor_phpcbf
        end
      end
      
      return 'phpcs', 'phpcbf'
    end
    
    -- Set dynamic paths
    local phpcs_path, phpcbf_path = get_project_phpcs_paths()
    vim.g.nvim_phpcs_config_phpcs_path = phpcs_path
    vim.g.nvim_phpcs_config_phpcbf_path = phpcbf_path

    -- Remove these lines to avoid overriding the local phpcs.xml
    -- vim.g.nvim_phpcs_config_phpcs_standard = custom_standard
    -- vim.g.nvim_phpcs_config_phpcbf_standard = custom_standard
    -- vim.g.nvim_phpcs_config_phpcs_args = '--standard='
    -- .. custom_standard
    -- .. ' --report=json --ignore=*/vendor/*,vendor/* --basepath=.'
    -- vim.g.nvim_phpcs_config_phpcbf_args = '--standard='
    -- .. custom_standard
    -- .. ' --ignore=*/vendor/*,vendor/* --basepath=.'

    -- Remove the is_vendor_file() function and related autocmds
    -- local function is_vendor_file()
    --   local file_path = vim.fn.expand('%:p')
    --   return string.match(file_path, '/vendor/') ~= nil
    -- end

    -- -- Create a more aggressive check function
    -- local function run_phpcs()
    --   if not is_vendor_file() then
    --     -- Force reload the standard before checking
    --     -- vim.fn.system('phpcs --config-set default_standard '.. custom_standard)
    --     require('phpcs').cs()
    --   end
    -- end

    -- -- Run on multiple events to ensure it's always active
    -- local group = vim.api.nvim_create_augroup('PHPCSGroup', { clear = true })

    -- vim.api.nvim_create_autocmd({
    --   'BufWritePost',
    --   'BufReadPost',
    --   'InsertLeave',
    --   -- 'TextChanged',
    --   -- 'TextChangedI'
    -- }, {
    --   group = group,
    --   pattern = '*.php',
    --   callback = run_phpcs,
    -- })

    -- vim.api.nvim_create_autocmd('BufWritePre', {
    --   group = group,
    --   pattern = '*.php',
    --   callback = function()
    --     if not is_vendor_file() then
    --       require('phpcs').cbf()
    --     end
    --   end,
    -- })

    vim.keymap.set('n', '<leader>lp', function()
      require('phpcs').fix()
    end, {
      silent = true,
      noremap = true,
      desc = 'PHP Fix',
    })

    -- Remove these lines as they might conflict with your phpcs.xml
    -- vim.g.nvim_phpcs_config_ignore_patterns = {
    --   'vendor/*',
    --   '*/vendor/*',
    -- }
  end,
}
