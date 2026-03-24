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

**Consequence classification**: If the task involves irreversible operations (production deploy, data migration, credential rotation), classify as In-the-Loop regardless of task type. [DSGAI19]

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
9. **Agent credentials** — Check for hardcoded OAuth tokens, bearer tokens, refresh tokens, client secrets in code and config files. Patterns: `Bearer `, `oauth_token=`, `refresh_token=`, `client_secret=`, `Authorization: Bearer`. Reference: [DSGAI02].
10. **AI model artifacts** — Flag committed model files (`.onnx`, `.safetensors`, `.gguf`, `.pt`, `.pkl`, `.bin` >10MB). These should be tracked via Git LFS or external artifact registry, not committed directly. [DSGAI04]
11. **Unsafe deserialization** — Flag `torch.load()`, `pickle.load()`, `pickle.loads()`, `yaml.unsafe_load()`, `joblib.load()` without safe alternatives (`weights_only=True`, `safetensors`). [DSGAI04]
12. **AI dependency pinning** — In requirements.txt/pyproject.toml, flag unpinned AI packages (torch, transformers, openai, anthropic, langchain) using `>=` or no version pin. [DSGAI04]
13. **Telemetry hygiene** — Flag patterns logging full prompts/contexts in production: `log.*prompt`, `log.*context`, `logger.*user_input`, `console.log.*messages`, `logging.*completion`. Allow in test/debug files. [DSGAI14]
14. **Telemetry redaction** — If observability configs exist (OpenTelemetry, Datadog, Sentry), verify PII/prompt scrubbing is configured. [DSGAI14]

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
6. **Plugin/MCP security** — If the project uses Claude Code plugins or MCP servers: (a) plugins are from trusted sources, (b) MCP tool permissions follow least-privilege (no `"allowed-tools": ["*"]`), (c) `.mcp.json` contains no hardcoded credentials. Check `.claude/settings.json` and MCP configs. Reference: [DSGAI06].
7. **Context minimization** — Verify that session-start hooks stay under ~500 tokens, CLAUDE.md does not contain secrets or PII, and rules files do not embed real credentials as examples. Reference: [DSGAI15].
8. **Agent credential hygiene** — Verify agent `.md` files and skill frontmatter contain no embedded credentials or API keys. Reference: [DSGAI02].
9. **Shadow AI policy** — If project has `shadow-ai-policy.md`, verify approved AI tooling is documented. Flag references to unsanctioned AI tool endpoints in source code or configs. [DSGAI03]
10. **Irreversible operation safeguards** — Scripts/code performing destructive operations (DROP TABLE, `rm -rf`, force push, production deploy) must have confirmation gates or dry-run modes. [DSGAI19]
11. **Session isolation** — Agent memory/state must be scoped per-project and per-user. Cache keys must include user/project/session scope. Flag global state stores without scope qualifiers. [DSGAI11]
12. **Multi-tenant data separation** — In multi-tenant code, verify tenant ID is included in all database queries, cache keys, and file paths. Flag shared state without tenant scoping. [DSGAI11]

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

When a check maps to a DSGAI control, include the reference in the output line (e.g., `[DSGAI02]`).

If all checks pass, congratulate the user. If any fail, provide specific file paths, line numbers, and remediation guidance.
