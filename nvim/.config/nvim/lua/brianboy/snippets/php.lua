local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

-- Get current date in YYYY-MM-DD format
local function get_date()
  return os.date('%Y-%m-%d')
end

-- PHP Method Snippet
return {
  s(
    { trig = 'clfn', descr = 'PHP Method with Documentation' },
    fmt(
      [[
/**
 * {}
 *
 * @param {} ${}
 * @return {}
 *
 * @author Brian Boy <brian@morntag.com>
 * @since {}
 */
{} function {}({} ${}): {} {{
    {}
}}
    ]],
      {
        i(1, 'This is a comment for the method'),
        rep(4),
        rep(5),
        rep(6),
        f(get_date),
        c(2, {
          t('public'),
          t('protected'),
          t('private'),
        }),
        i(3, 'methodName'),
        i(4, 'ParamType'),
        i(5, 'paramName'),
        i(6, 'void'),
        i(7, '// Function body'),
      }
    )
  ),
  s(
    { trig = 'pvar', descr = 'PHP @var annotation' },
    fmt(
      [[
/** @var {} ${} {} */
    ]],
      {
        i(1, 'Type'),
        i(2, 'var'),
        i(3, 'description'),
      }
    )
  ),
}
