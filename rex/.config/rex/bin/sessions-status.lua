-- Prints one line per session: label, session_id, then counts of agent
-- states across its terminals (blocked, done, working, agents).
local terminal = "com.superlogical.terminal"
local out = {}
local list = rex.call("session.list") or { sessions = {} }
for _, s in ipairs(list.sessions or {}) do
  local c = { blocked = 0, done = 0, working = 0, agents = 0 }
  local blocks = rex.call("session.list_blocks", { session_id = s.session_id })
  for _, b in ipairs((blocks and blocks.blocks) or {}) do
    if b.creator_name == terminal then
      local st = rex.block.call(terminal, "program_status",
        { session_id = s.session_id, block_id = b.block_id })
      local agent = false
      for _, r in ipairs((st and st.records) or {}) do
        agent = true
        if c[r.state] then c[r.state] = c[r.state] + 1 end
      end
      if agent then c.agents = c.agents + 1 end
    end
  end
  out[#out + 1] = table.concat({ s.label or "", s.session_id,
    c.blocked, c.done, c.working, c.agents }, "\t")
end
print(table.concat(out, "\n"))
