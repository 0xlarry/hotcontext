---
name: security
description: Security audit checklist, common vulnerabilities, and secure coding patterns
version: 1.0.0
tags: [security, audit, best-practices]
author: hotcontext
---

# Security Audit Context

## Documentation
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- OWASP Cheat Sheet Series: https://cheatsheetseries.owasp.org/
- CWE Top 25: https://cwe.mitre.org/top25/

## Input Validation
- Validate ALL user input at system boundaries (API endpoints, form handlers)
- Use allowlists over denylists for input validation
- Sanitize output based on context (HTML, URL, SQL, shell)
- Never trust client-side validation alone

## Authentication & Authorization
- Use bcrypt/scrypt/argon2 for password hashing (NOT MD5/SHA)
- Implement rate limiting on auth endpoints
- Use constant-time comparison for secrets/tokens
- Validate JWT signatures AND claims (exp, iss, aud)
- Check authorization on every request, not just at login

## Common Vulnerabilities to Check
- SQL Injection: Use parameterized queries, never string concatenation
- XSS: Escape output in HTML context, use CSP headers
- CSRF: Validate origin/referer, use anti-CSRF tokens
- SSRF: Validate and allowlist outbound URLs
- Path Traversal: Normalize paths, validate against base directory
- Command Injection: Avoid shell execution, use spawn with args array
- Prototype Pollution: Freeze prototypes, validate JSON keys
- Mass Assignment: Explicitly allowlist assignable fields

## Secrets Management
- Never hardcode secrets in source code
- Use environment variables or dedicated secret managers
- Rotate secrets regularly
- Audit secret access patterns

## Anti-Patterns Claude Gets Wrong
- Do NOT suggest storing passwords in plain text or reversible encryption
- Do NOT suggest disabling CORS for convenience
- Do NOT use `eval()` or `Function()` constructor with user input
- Do NOT suggest `dangerouslySetInnerHTML` without sanitization
- Do NOT recommend JWT in localStorage (use httpOnly cookies)
- Do NOT suggest wildcard CORS (`Access-Control-Allow-Origin: *`) for authenticated endpoints
