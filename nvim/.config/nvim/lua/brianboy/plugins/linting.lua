return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      php = { 'phpcs' },
      javascript = { 'biomejs' },
      typescript = { 'biomejs' },
      javascriptreact = { 'biomejs' },
      typescriptreact = { 'biomejs' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function(args)
        local filetype = vim.bo[args.buf].filetype

        if filetype == 'php' then
          local buffer_path = vim.api.nvim_buf_get_name(args.buf)
          if buffer_path == '' then
            return
          end
          local current_dir = vim.fn.fnamemodify(buffer_path, ':h')

          -- Find project root with phpcs config
          local config_files = vim.fs.find({ 'phpcs.xml', '.phpcs.xml' }, {
            path = current_dir,
            upward = true,
            limit = 1,
          })

          if #config_files > 0 then
            local project_root = vim.fn.fnamemodify(config_files[1], ':h')
            local vendor_phpcs = project_root .. '/vendor/bin/phpcs'
            
            -- Check if project has vendor/bin/phpcs
            if vim.fn.executable(vendor_phpcs) == 1 then
              -- Update phpcs command to use project's phpcs
              lint.linters.phpcs.cmd = vendor_phpcs
            else
              -- Use global phpcs
              lint.linters.phpcs.cmd = 'phpcs'
            end
            
            -- Set args with project config
            lint.linters.phpcs.args = {
              '-q',
              '--report=json',
              '--standard=' .. config_files[1],
              function()
                return '--stdin-path=' .. vim.fn.expand('%:p')
              end,
              '-'
            }
            lint.linters.phpcs.ignore_exitcode = true
            lint.linters.phpcs.stdin = true
          else
            -- Reset to default phpcs configuration
            lint.linters.phpcs.cmd = 'phpcs'
            lint.linters.phpcs.args = {
              '-q',
              '--report=json',
              function()
                return '--stdin-path=' .. vim.fn.expand('%:p')
              end,
              '-'
            }
            lint.linters.phpcs.ignore_exitcode = true
            lint.linters.phpcs.stdin = true
          end
          
          lint.try_lint()
        else
          -- CORRECTED: Call try_lint with no arguments
          lint.try_lint()
        end
      end,
    })

    vim.keymap.set('n', '<leader>li', function()
      lint.try_lint()
    end, { desc = 'Trigger linting for current file' })
  end,
}
