local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

-- Return a table with file types as keys and snippet arrays as values
return {
  -- For JavaScript files
  javascript = {
    s(
      { trig = 'ptest', descr = 'Playwright test snippet' },
      fmt(
        [[
import test from "@playwright/test";

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
  },

  -- For TypeScript files - same snippet
  typescript = {
    s(
      { trig = 'ptest', descr = 'Playwright test snippet' },
      fmt(
        [[
import test from "@playwright/test";

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
  },

  -- Also for typescriptreact files
  typescriptreact = {
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
  },
}
