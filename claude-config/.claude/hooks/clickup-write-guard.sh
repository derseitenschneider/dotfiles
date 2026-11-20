#!/usr/bin/env bash
# PreToolUse guard for ClickUp writes (comments, tasks, chat messages).
# Forces a permission prompt that shows the text about to be sent, so nothing
# reaches ClickUp without Brian approving the exact wording.
input=$(cat)

python3 -c '
import json, sys

data = json.loads(sys.argv[1])
tool = data.get("tool_name", "?").split("__")[-1]
args = data.get("tool_input", {}) or {}

text_keys = ("comment_text", "text", "content", "message", "markdown_description", "description", "name", "status")
parts = []
for key in text_keys:
    value = args.get(key)
    if value not in (None, ""):
        parts.append(f"{key}:\n{value}")

target = args.get("task_id") or args.get("entity_id") or args.get("comment_id") or args.get("list_id") or args.get("channel_id") or ""
reason = f"ClickUp write ({tool}) to {target}. Check the exact text before allowing:\n\n" + ("\n\n".join(parts) or json.dumps(args, ensure_ascii=False, indent=1))

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "ask",
        "permissionDecisionReason": reason,
    }
}, ensure_ascii=False))
' "$input"
