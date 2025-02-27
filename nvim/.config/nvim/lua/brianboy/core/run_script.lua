local function run_project_script()
  local project_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if not project_root then
    vim.notify('Not a git repository.', vim.log.levels.WARN)
    return
  end

  local script_path = project_root .. '/run'
  if vim.fn.filereadable(script_path) == 1 then
    local command = 'bash ' .. script_path
    local result = vim.fn.system(command)
    if result ~= '' then
      print(result)
    end
  else
    vim.notify('run script not found in project root.', vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command('Run', run_project_script, {})

vim.api.nvim_create_autocmd('CmdlineEnter', {
  pattern = 'run',
  callback = function()
    run_project_script()
    vim.cmd('normal <esc>')
  end,
})
