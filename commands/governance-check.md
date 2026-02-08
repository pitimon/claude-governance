---
name: governance-check
description: Run governance fitness function checks against staged changes or the full project. Validates code quality, security, and architecture standards.
argument-hint: "[pre-commit|pre-pr|architecture|all]"
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# Governance Fitness Function Check

Run the requested governance check category. Default to `all` if no argument provided.

## Check Categories

### pre-commit
Scan staged/changed files for:

1. **Hardcoded secrets** — Search for patterns: `API_KEY=`, `password=`, `sk-`, `ghp_`, `AKIA`, hardcoded token strings. Use `git diff --cached` or `git diff` to get changed content.
2. **Input validation** — New API endpoints/route handlers MUST have input validation (Zod schema, joi, express-validator, or equivalent). Check new route files.
3. **Parameterized queries** — Database queries must use parameterized queries, not string interpolation. Search for SQL string concatenation patterns.
4. **File size** — No file should exceed 800 lines. Use `wc -l` on changed files.
5. **Function length** — No function should exceed 50 lines. Use Grep to find function definitions and count lines.
6. **Immutability** — Check for direct mutation patterns (`.push(`, `obj.prop =` on shared state, `delete obj.prop`).
7. **Console.log** — No `console.log` in production code (allow in test files).

### pre-pr
Check the full branch diff against base:

1. **Conventional commits** — All commits on this branch must follow format: `type: description` where type is one of: feat, fix, refactor, docs, test, chore, perf, ci. Use `git log --oneline`.
2. **DOMAIN.md** — If entity schemas changed (new fields, new entities, changed types), DOMAIN.md must be updated.
3. **Breaking changes** — API contract changes (removed fields, changed types, removed endpoints) must be documented in an ADR.
4. **Test coverage** — Changed files should have corresponding test files. Check for test file existence.
5. **TODO context** — All TODO comments must include context about what needs to be done and why.

### architecture
Periodic architecture review:

1. **Service boundaries** — No direct cross-service database access. Services communicate through APIs.
2. **Error message safety** — Error responses must not leak stack traces, internal paths, or sensitive data.
3. **Authentication** — All non-health-check endpoints require authentication.
4. **Rate limiting** — Public endpoints should have rate limiting configured.
5. **Cache consistency** — Cache TTL policies are documented and consistent.

## Output Format

Present results as a structured checklist:

```
## Governance Check: [category]

### Passed
- [x] No hardcoded secrets found
- [x] File sizes within limits

### Failed
- [ ] FAIL: `src/api/handler.ts` — 923 lines (max 800)
- [ ] FAIL: Missing input validation in `POST /api/users`

### Warnings
- [!] `src/utils/helper.ts:45` — TODO without context

### Summary
Passed: X/Y | Failed: Z | Warnings: W
```

If all checks pass, congratulate the user. If any fail, provide specific file paths, line numbers, and remediation guidance.
