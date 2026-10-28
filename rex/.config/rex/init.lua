-- Rex config. Reload after changes with `rex config reload`.

local here = os.getenv("HOME") .. "/.config/rex"

-- Where the picker should appear, as fractions of the window.
local picker = { x = 0.2, y = 0.12, w = 0.6, h = 0.7 }

-- Fuzzy project picker: a floating fzf over projects.tsv and their worktrees,
-- sorted by agents waiting on you, then done, working, open, and recent.
-- Picking a project switches to its session, creating it if needed.
rex.action{
  name     = "open_project",
  title    = "Open Project…",
  category = "Projects",
  keywords = "project client worktree switch fuzzy picker",
  run      = function(ctx)
    -- Rex sizes a floating layer by bounds w/h but clips it as if w/h were
    -- the right and bottom edges (deferred bug). So pass the edges, which
    -- clips in the right place, and tell the picker which share of its
    -- oversized terminal is visible. Once fixed: picker's own bounds, 1, 1.
    local right, bottom = picker.x + picker.w, picker.y + picker.h
    local _, err = rex.session.new_layer{
      bounds = { picker.x, picker.y, right, bottom },
      focus  = true,
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        label   = "projects",
        options = {
          -- A floating layer has no backdrop of its own; without a solid
          -- background the panes behind it show through the list.
          theme   = { background = "#23262e", scheme = "dark" },
          shell   = "none",
          command = { here .. "/bin/rex-projects", ctx.client_id or "",
                      tostring(picker.w / right), tostring(picker.h / bottom) },
        },
      },
    }
    if err ~= nil then error(err, 0) end
  end,
}

rex.bind("cmd+p", "open_project")
