vim.cmd('let g:netrw_liststyle = 3')

local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Mode agnostic cursor
vim.opt.guicursor = ''

-- tabs & indentation
opt.tabstop = 4 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.smartindent = true

-- Different indentation for js, ts, css and html
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'javascript,typescript,javascriptreact,typescriptreact,css,scss,less,html,htm',
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Enable mouse mode
opt.mouse = 'a'

-- Show mode
opt.showmode = false

opt.showtabline = 1

-- Save undo history
opt.undofile = true
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
opt.swapfile = false
opt.backup = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- Show which line your cursor is on
opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = 'dark' -- colorschemes that can be light or dark will be made dark
opt.signcolumn = 'yes' -- show sign column so that text doesn't shift

-- Color column
opt.colorcolumn = '80'
-- backspace
opt.backspace = 'indent,eol,start' -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append('unnamedplus') -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- Preview substitutions live, as you type!
opt.inccommand = 'split'

-- Minimal number of screen lines to keep above and below the cursor
opt.scrolloff = 9999

-- Unset highlight on search, but clear on pressing <Esc> in normal mode
opt.hlsearch = false
opt.incsearch = true

-- Highlight yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Tailwind: auto sort on save
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'html',
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'vue',
    'svelte',
    'php',
    'astro',
  },
  callback = function(event)
    -- Create a buffer-local autocmd for this specific buffer
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = event.buf,
      callback = function()
        -- Check if the command exists before trying to use it
        pcall(function()
          vim.cmd('TailwindSort')
        end)
      end,
      desc = 'Sort Tailwind CSS classes before saving',
    })
  end,
  desc = 'Set up TailwindSort for relevant filetypes',
})
