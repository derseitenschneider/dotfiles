return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  ft = { 'markdown' },
  config = function()
    require('render-markdown').setup({
      heading = {
        enabled = true,
        sign = false,
        icons = {},
        backgrounds = {},
        foregrounds = {},
      },
      code = {
        enabled = true,
        sign = true,
        style = 'full',
        position = 'left',
        language_pad = 0,
        disable_background = { 'diff' },
      },
      dash = {
        enabled = true,
        icon = '─',
        width = 'full',
      },
      bullet = {
        enabled = true,
        icons = { '●', '○', '◆', '◇' },
      },
      checkbox = {
        enabled = true,
        unchecked = {
          icon = '󰄱 ',
          highlight = 'RenderMarkdownUnchecked',
        },
        checked = {
          icon = '󰱒 ',
          highlight = 'RenderMarkdownChecked',
        },
      },
      quote = {
        enabled = true,
        icon = '▎',
        highlight = 'RenderMarkdownQuote',
      },
      pipe_table = {
        enabled = true,
        style = 'full',
        cell = 'padded',
        border = {
          '┌', '┬', '┐',
          '├', '┼', '┤',
          '└', '┴', '┘',
          '│', '─',
        },
      },
      callout = {
        note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
        tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
        important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
        warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
        caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
      },
      link = {
        enabled = true,
        image = '󰥶 ',
        hyperlink = '󰌹 ',
        highlight = 'RenderMarkdownLink',
      },
    })
  end,
}