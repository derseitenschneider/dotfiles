return {
  'L3MON4D3/LuaSnip',
  -- follow latest release.
  version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- install jsregexp (optional!).
  build = 'make install_jsregexp',
  config = function()
    local ls = require('luasnip')

    require('luasnip.loaders.from_vscode').lazy_load()
    require('luasnip.loaders.from_lua').load({ paths = { '~/.dotfiles/nvim/.config/nvim/lua/brianboy/snippets' } })

    -- load extensible snippets from friendly snippets
    require('luasnip').filetype_extend('php', { 'phpdoc' })
    require('luasnip').filetype_extend('typescript', { 'tsdoc' })

    vim.keymap.set({ 'i' }, '<C-K>', function()
      ls.expand()
    end, { silent = true })
    vim.keymap.set({ 'i', 's' }, '<C-L>', function()
      ls.jump(1)
    end, { silent = true })
    vim.keymap.set({ 'i', 's' }, '<C-J>', function()
      ls.jump(-1)
    end, { silent = true })

    -- if we are on a choice node, we can switch between choices with this.
    vim.keymap.set({ 'i', 's' }, '<C-I>', function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true })
  end,
}
