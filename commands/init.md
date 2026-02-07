Initialize hotcontext in the current project.

**Step 1 — Check for existing setup:**
If `.claude/hotcontext/` already exists and contains `.md` files, tell the user hotcontext is already set up and stop.

**Step 2 — Create the directory:**
Create `.claude/hotcontext/` if it doesn't exist.

**Step 3 — Create a starter bundle:**
Create `.claude/hotcontext/example.md` with this skeleton:

```markdown
---
name: example
description: Example bundle — rename this file to match your domain
version: 1.0.0
---

# Example Context

## Documentation
-

## Conventions
-

## Anti-Patterns Claude Gets Wrong
-
```

**Step 4 — Report:**
Tell the user:
- `.claude/hotcontext/` is ready
- Edit `example.md` or run `/hotcontext:new <tagname>` to create bundles
- Aim for 300–800 words per bundle — focus on what Claude gets wrong
- Use `+tagname` in prompts to inject context
