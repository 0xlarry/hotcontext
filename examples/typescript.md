---
name: typescript
description: TypeScript development conventions, patterns, and common pitfalls
version: 1.0.0
tags: [language, frontend, backend]
author: hotcontext
---

# TypeScript Development Context

## Documentation
- TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/
- TypeScript 5.x Release Notes: https://devblogs.microsoft.com/typescript/

## Current Conventions
- Use strict mode (`"strict": true` in tsconfig)
- Prefer `interface` over `type` for object shapes (extendable, better error messages)
- Use `satisfies` operator for type-safe object literals (TS 5.0+)
- Prefer `const` assertions for literal types
- Use template literal types for string pattern enforcement

## Type Patterns
- Use discriminated unions over optional fields for state variants
- Prefer `unknown` over `any` — force explicit narrowing
- Use `Record<string, T>` over `{ [key: string]: T }` for index signatures
- Use `Readonly<T>` and `ReadonlyArray<T>` for immutable data

## Anti-Patterns Claude Gets Wrong
- Do NOT use `enum` — use `as const` objects or union types instead
- Do NOT use `namespace` — use ES modules
- Do NOT use `/// <reference>` directives
- Do NOT suggest `@ts-ignore` — use `@ts-expect-error` with explanation
- Do NOT use `Function` type — use specific function signatures
- Do NOT use `Object` type — use `Record<string, unknown>` or specific interfaces

## Error Handling
- Use Result/Either pattern for expected errors, throw for unexpected
- Prefer `Error` subclasses with `cause` property (ES2022+)
- Use `satisfies` with error type maps for exhaustive error handling

## Testing
- Vitest or Jest with ts-jest for unit tests
- Use `expectTypeOf` from vitest for compile-time type assertions
- Mock with explicit type annotations to catch interface drift
