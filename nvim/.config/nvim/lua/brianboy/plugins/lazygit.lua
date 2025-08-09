return {
  "kdheepak/lazygit.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
  },
  config = function()
    -- Try to fix the terminal issue by setting shell explicitly
    local shell = vim.o.shell
    if shell == "" then
      vim.o.shell = "/bin/zsh"
    end
    
    -- Disable features that might conflict
    vim.g.lazygit_floating_window_use_plenary = 0
    vim.g.lazygit_use_neovim_remote = 0
    
    -- Create a working alternative command
    vim.api.nvim_create_user_command('LazyGitDebug', function()
      -- Create floating window dimensions
      local width = math.floor(vim.o.columns * 0.9)
      local height = math.floor(vim.o.lines * 0.9)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)
      
      -- Create buffer
      local buf = vim.api.nvim_create_buf(false, true)
      
      -- Create floating window
      local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
      })
      
      -- Use termopen which is more reliable
      local term_id = vim.fn.termopen('lazygit', {
        on_exit = function()
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(win) then
              vim.api.nvim_win_close(win, true)
            end
            if vim.api.nvim_buf_is_valid(buf) then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end)
        end,
      })
      
      if term_id > 0 then
        -- Enter insert mode to interact with lazygit
        vim.cmd('startinsert')
        
        -- Set up keymap to close (double Esc to exit)
        vim.api.nvim_buf_set_keymap(buf, 't', '<Esc><Esc>', '<C-\\><C-n>:q<CR>', { noremap = true, silent = true })
      else
        vim.api.nvim_err_writeln('Failed to start lazygit. Error code: ' .. term_id)
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end, { desc = 'Open LazyGit with debug mode' })
    
    -- Add debug keymap
    vim.keymap.set('n', '<leader>ld', '<cmd>LazyGitDebug<cr>', { desc = 'Open LazyGit (Debug)' })
    
    -- Let's also try to fix the original LazyGit command by overriding it
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Override the original LazyGit command after everything loads
        vim.schedule(function()
          if vim.fn.exists(':LazyGit') == 2 then
            vim.api.nvim_del_user_command('LazyGit')
            vim.api.nvim_create_user_command('LazyGit', function()
              vim.cmd('LazyGitDebug')
            end, { desc = 'Open LazyGit (Fixed)' })
          end
        end)
      end,
    })
  end,
}