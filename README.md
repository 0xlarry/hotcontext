<p align="center">
  <img src="hotcontext.jpg" alt="hotcontext" width="500" />
</p>

# hotcontext

**Deterministic context injection for Claude Code.** Use `+tags` to load domain knowledge, documentation, and conventions into any prompt — on demand.

```
> +react +nextjs Review the authentication flow for Server Component issues
```

Claude receives React 19 docs, Next.js App Router patterns, and known gotchas — instantly, without re-explaining anything.

## The Problem

Every Claude Code session starts cold. You re-explain your stack, paste documentation links, remind Claude about framework-specific anti-patterns. CLAUDE.md helps, but stuffing everything in there wastes the model's attention budget on context that's irrelevant to most prompts.

**hotcontext fixes this.** Write your domain knowledge once as markdown bundles. Tag them into prompts when you need them.

## How It Works

| | hotcontext Bundles | Skills | CLAUDE.md |
|---|---|---|---|
| **Purpose** | Reference material injected on demand | Workflows Claude executes | Always-on project conventions |
| **Invocation** | Explicit `+tag` (deterministic) | Model-invoked or `/skill-name` | Loaded every session |
| **Scope** | Per-prompt — only what you tag | Per-task | Per-session — always present |

hotcontext fills the gap: **what Claude knows *right now*, for *this prompt*, because you asked for it.**

## Install

```bash
# Add the hotcontext marketplace
/plugin marketplace add 0xlarry/hotcontext

# Install the plugin
/plugin install hotcontext@hotcontext
```

## Quick Start

```bash
# Initialize hotcontext in your project
/hotcontext:init

# This creates .claude/hotcontext/ with a starter bundle

# Create your first real bundle
/hotcontext:new react

# Edit .claude/hotcontext/react.md with your conventions, then:
> +react Fix the state management in this component
```

## Writing Bundles

A bundle is a markdown file. The filename is the tag name — `react.md` becomes `+react`.

```markdown
---
name: react
description: React development conventions and common gotchas
version: 1.0.0
---

# React Development Context

## Documentation
- React 19 docs: https://react.dev
- Server Components: https://react.dev/reference/rsc/server-components

## Conventions
- Use functional components with hooks exclusively
- Prefer Server Components by default (React 19+)

## Anti-Patterns Claude Gets Wrong
- Do NOT suggest class components
- Do NOT use useEffect for data fetching (use TanStack Query)
- Do NOT mix Pages Router and App Router in Next.js
```

Bundles live in two places:

| Scope | Location | Purpose |
|-------|----------|---------|
| Project | `.claude/hotcontext/` | Team-shared, committed to git |
| Personal | `~/.claude/hotcontext/` | Your cross-project defaults |

Project scope overrides personal when both have the same tag name.

**Tips for great bundles:**
- Focus on what Claude gets wrong — anti-patterns are the highest-value content
- Include an "Anti-Patterns Claude Gets Wrong" section with explicit "Do NOT" instructions
- Link to official docs (Claude can WebFetch them for deeper context)
- Be opinionated — "Use Zustand" beats "Options include Redux, Zustand, Jotai..."
- Include version numbers — "React 19+" prevents expensive mistakes from stale training data

## Commands

| Command | Description |
|---------|-------------|
| `/hotcontext:init` | Set up `.claude/hotcontext/` in your project |
| `/hotcontext:new <tag>` | Scaffold a new bundle with frontmatter template |

## Tag Syntax

Tags use the `+` prefix: `+tagname`

```
> +react +nextjs Review the authentication flow
> use +typescript to help me refactor this
> +security +reviewer Review this PR for vulnerabilities
```

The `+` prefix was chosen over `#` to avoid collisions with GitHub issue refs (`#1234`), markdown headers (`# Title`), and code comments (`# comment`). The regex `\+[a-zA-Z0-9_-]+` requires `+` immediately adjacent to alphanumeric characters, so math expressions like `x + y` don't trigger false matches.

## How It Works Under the Hood

1. You type a prompt with `+tags`
2. The plugin's `UserPromptSubmit` hook fires before Claude processes the prompt
3. The resolver parses tags, searches `.claude/hotcontext/` then `~/.claude/hotcontext/`
4. First file match wins per tag. Content is concatenated with section headers.
5. Plain text output goes to stdout, which Claude Code adds as context
6. Claude receives your prompt with the domain knowledge already loaded

The resolver is ~80 lines of Node.js with zero external dependencies. It completes in <50ms for typical usage (3-5 tags). If it crashes, Claude Code proceeds normally — the hook is non-blocking.

## Size Guidelines

- Individual bundles: aim for 300–800 words. Keep under 1,000 words.
- Combined context per prompt: stay under ~4,000 tokens total.
- If a bundle exceeds 800 words, consider splitting it into two focused tags.

Smaller bundles compose better. Three focused 400-word bundles outperform one 1,200-word bundle because every token competes for the model's attention budget (see [Anthropic's context engineering guide](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)).

## Example Bundles

The plugin ships with example bundles in `examples/` for reference:

- **typescript.md** — TypeScript conventions, type patterns, anti-patterns
- **security.md** — Security audit checklist, OWASP references, vulnerability patterns
- **reviewer.md** — Code review standards, communication patterns, checklist

## Development

```bash
# Run unit tests (19 tests)
node --test tests/resolver.test.js

# Run integration tests (15 tests)
bash tests/integration-test.sh

# Test locally as a plugin
claude --plugin-dir /path/to/hotcontext

# Test the resolver directly
echo '{"prompt": "+typescript help me"}' | node scripts/resolve.js
```

## License

MIT — see [LICENSE](LICENSE).
