local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

-- Return a list of snippets for TypeScript
return {
  s(
    { trig = 'ptest', descr = 'Playwright test snippet' },
    fmt(
      [[
test('{}', async ({{ {} }}) => {{
  {}
}});
    ]],
      {
        i(1, 'describe test here'),
        i(2, 'page'),
        i(3, '// Test implementation'),
      }
    )
  ),
}
