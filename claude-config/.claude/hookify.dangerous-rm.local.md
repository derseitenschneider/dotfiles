---
name: warn-dangerous-rm
enabled: true
event: bash
pattern: rm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+|.*-rf|.*-fr)
action: warn
---

**Dangerous rm command detected**

You're about to run a recursive delete command (`rm -rf` or similar).

**Before proceeding:**

- Verify the target path is correct
- Ensure no important data will be lost
- Consider if this was explicitly requested by the user

If you're unsure, ask the user to confirm the path before executing.
