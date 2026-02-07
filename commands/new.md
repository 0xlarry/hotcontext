Scaffold a new hotcontext bundle.

Usage: /hotcontext:new <tagname>

The argument is the tag name. If the user includes a `+` prefix (e.g., `+mylib`), strip it.

**Step 1 — Choose scope:**
Ask the user which scope to create the bundle in:
- **PROJECT** (`.claude/hotcontext/`) — for project-specific context, committed to git
- **PERSONAL** (`~/.claude/hotcontext/`) — for personal cross-project context, local only

**Step 2 — Check for existing bundle:**
Check if `<tagname>.md` already exists in the chosen directory. If it does, warn the user and ask if they want to overwrite it. If they decline, stop.

**Step 3 — Create directory if needed:**
If the chosen directory doesn't exist, create it.

**Step 4 — Create the bundle file:**
Create `<tagname>.md` in the chosen directory with this template content:

```markdown
---
name: <tagname>
description:
version: 1.0.0
---

# <tagname> Context

## Documentation
-

## Conventions
-

## Anti-Patterns Claude Gets Wrong
-
```

Use the actual tag name in place of `<tagname>` (lowercase, as provided by the user).

**Step 5 — Report:**
Show the created file path and remind the user to:
1. Fill in the `description` frontmatter field
2. Add documentation links, conventions, and anti-patterns
3. Use `+<tagname>` in prompts to inject this context
