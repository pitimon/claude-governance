---
name: governance-check
description: Run governance fitness function checks against staged changes or the full project. Validates code quality, security, and architecture standards.
argument-hint: "[pre-commit|pre-pr|architecture|all]"
user-invocable: true
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# Governance Fitness Function Check

Run the requested governance check category. Default to `all` if no argument provided.

## Scope and When to Use

**This is a QUICK checklist tool** — single-category, fast pass/fail, actionable remediation. Use for:

- Pre-commit spot checks on staged changes
- Quick validation before pushing
- Verifying a specific category (secrets, file size, etc.)

For deep multi-file review with severity grading and domain invariant analysis, use the `governance-reviewer` agent instead.

## Project Type Detection

Before running checks, detect the project's primary language:

| Indicator                                        | Language |
| ------------------------------------------------ | -------- |
| `package.json`                                   | JS/TS    |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python   |
| `go.mod`                                         | Go       |
| `Cargo.toml`                                     | Rust     |

If multiple indicators exist, check all relevant languages. If none match, apply generic checks.

## Check Categories

### pre-commit

Scan staged/changed files for:

1. **Hardcoded secrets** — Search for patterns: `API_KEY=`, `password=`, `sk-`, `sk-ant-`, `ghp_`, `AKIA`, hardcoded token strings, `-----BEGIN PRIVATE KEY-----`, JWT tokens (`eyJ...`), Google API keys (`AIza...`), Azure connection strings, MongoDB URIs. Use `git diff --cached` or `git diff` to get changed content.
2. **Input validation** — New API endpoints/route handlers MUST have input validation. Check for language-appropriate validation:
   - JS/TS: Zod, joi, yup, express-validator
   - Python: pydantic, marshmallow, cerberus
   - Go: go-validator, custom validation functions
   - Rust: serde with validation, validator crate
3. **Parameterized queries** — Database queries must use parameterized queries, not string interpolation. Search for SQL string concatenation patterns.
4. **File size** — No file should exceed 800 lines. Use `wc -l` on changed files.
5. **Function length** — No function should exceed 50 lines. Use Grep to find function definitions and count lines.
6. **Immutability** — Check for direct mutation patterns (`.push(`, `obj.prop =` on shared state, `delete obj.prop`).
7. **Debug prints** — No debug prints in production code (allow in test files):
   - JS/TS: `console.log`
   - Python: `print(` (excluding logging)
   - Go: `fmt.Println` (excluding structured logging)
   - Rust: `println!`
8. **Dangerous functions** — Flag usage of:
   - JS/TS: `eval()`, `innerHTML`
   - Python: `eval()`, `exec()`, `pickle.loads()`
   - Go: `unsafe.Pointer`
   - Rust: `unsafe` blocks

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
