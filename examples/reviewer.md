---
name: reviewer
description: Code review standards, checklist, and common review patterns
version: 1.0.0
tags: [review, quality, process]
author: hotcontext
---

# Code Review Context

## Review Priorities (in order)
1. **Correctness** — Does the code do what it's supposed to?
2. **Security** — Are there vulnerabilities or unsafe patterns?
3. **Performance** — Are there obvious bottlenecks or N+1 queries?
4. **Maintainability** — Is the code readable and well-structured?
5. **Style** — Does it follow project conventions?

## What to Check
- Edge cases: null/undefined, empty arrays, boundary values
- Error handling: Are errors caught, logged, and surfaced appropriately?
- Race conditions: Async operations, shared state, concurrent access
- Resource cleanup: Are connections, streams, and handles closed?
- Backwards compatibility: Does this break existing callers/consumers?
- Test coverage: Are the new/changed paths tested?

## Review Communication
- Prefix comments with severity: `nit:`, `suggestion:`, `issue:`, `blocker:`
- Explain the "why" not just the "what" when requesting changes
- Offer alternatives, not just criticism
- Distinguish between personal preference and genuine issues

## Anti-Patterns in Reviews
- Do NOT nitpick formatting if there's a formatter/linter
- Do NOT request changes that are unrelated to the PR's scope
- Do NOT block on stylistic preferences unless they impact readability
- Do NOT approve without actually reading the changes
