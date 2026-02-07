---
name: hotcontext
description: How the +tag system works
version: 1.0.0
author: hotcontext
---

# +Tags: How It Works

`+tagname` in any prompt injects the matching `.md` bundle as context. Multiple tags stack: `+react +security audit this`.

**Bundles live in:** `.claude/hotcontext/` (project) or `~/.claude/hotcontext/` (personal). Filename = tag name.

**Create one:** `/hotcontext:new <tag>` or write a `.md` file directly. Focus on what Claude gets wrong — anti-patterns, conventions, doc links. Keep it under 1,500 words.

**Commands:** `/hotcontext:init`, `/hotcontext:new <tag>`
