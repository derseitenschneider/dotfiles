vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local keymap = vim.keymap -- for conciseness

-- Set kj as escape substitute
-- keymap.set({ 'i', 'v', 'c' }, 'kj', '<ESC>', { desc = 'Exit insert mode with jk' })

-- Source file with space + enter
keymap.set('n', '<leader><CR>', ':source %<CR>', { desc = 'Source current file', noremap = false })

-- Move visually selected blocks up and down
keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')

-- greatest remap ever
keymap.set('x', '<leader>p', [["_dP]], { desc = 'Keeps the pasted word in register when pasted over a selected part' })

-- File & window management
keymap.set('n', '<leader>w', ':wa<enter>', { desc = 'Write all buffers', noremap = false })
keymap.set('n', '<leader>cc', ':wqa<enter>', { desc = 'Write and quit all buffers', noremap = false })

-- Center cursor on linewrap, halfpage jump and search next/prev
keymap.set('n', 'J', 'mzJ`z', { desc = 'Keeps cursor when line wrapping.' })
keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Keeps cursor centered when jumping down by half page.' })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Keeps cursor centered when jumping up by half page.' })
keymap.set('n', 'n', 'nzzzv', { desc = 'Centers cursor on jump to next search item.' })
keymap.set('n', 'N', 'Nzzzv', { desc = 'Centers cursor on jump to previous search item.' })

-- Search
keymap.set('n', '<leader>ns', '<cmd>nohls<CR>', { desc = 'Clear search highlights' })

-- Prevent wrapped lines from being jumped
vim.keymap.set('n', 'k', 'v:count == 0 ? \'gk\' : \'k\'', { expr = true, silent = true })
vim.keymap.set('n', 'j', 'v:count == 0 ? \'gj\' : \'j\'', { expr = true, silent = true })
vim.keymap.set('v', 'k', 'v:count == 0 ? \'gk\' : \'k\'', { expr = true, silent = true })
vim.keymap.set('v', 'j', 'v:count == 0 ? \'gj\' : \'j\'', { expr = true, silent = true })
vim.keymap.set('n', '0', 'v:count == 0 ? \'g0\' : \'0\'', { expr = true, silent = true })
vim.keymap.set('n', '^', 'v:count == 0 ? \'g^\' : \'^\'', { expr = true, silent = true })
vim.keymap.set('n', '$', 'v:count == 0 ? \'g$\' : \'$\'', { expr = true, silent = true })

-- Increment/decrement numbers
keymap.set('n', '<leader>+', '<C-x>', { desc = 'Increment number' })
keymap.set('n', '<leader>-', '<C-a>', { desc = 'Decrement number' })

keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Better search/replace
vim.keymap.set(
  'n',
  '<leader>s',
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = 'Puts the word under the cursor in a search/replace command.' }
)

-- Set Ctrl b to go to previous buffer.
keymap.set('n', '<C-b>', '<C-^>', { noremap = true })

-- Window management
keymap.set('n', '<leader>sv', '<C-w>v', { desc = 'Split window vertically' })
keymap.set('n', '<leader>sh', '<C-w>s', { desc = 'Split window horizontally' })
keymap.set('n', '<leader>se', '<C-w>=', { desc = 'Make splits equal size' })
keymap.set('n', '<leader>sx', '<cmd>close<CR>', { desc = 'Close current split' })

keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

keymap.set('n', '<leader>z', '<cmd>ZenMode<CR>', { desc = 'Toggle Zenmode' })

-- FZF Repo
keymap.set('n', '<C-f>', ':silent !tmux neww fzf-repo.sh <CR>', { desc = 'Toggle Zenmode' })

-- Quickfix list
vim.keymap.set('n', '<leader>qo', ':copen<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>qc', ':cclose<CR>', { noremap = true, silent = true })
