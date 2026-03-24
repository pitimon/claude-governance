# Governance Fitness Functions

Automated governance checks — "unit tests for architecture". Self-check before, during, and after implementation.

## Pre-Implementation Checks (before writing code)

- Spec exists for non-trivial features (> 3 files changed)
- Domain invariants from DOMAIN.md are identified and preserved
- Decision autonomy level is appropriate (Three Loops)
- Breaking changes are identified and flagged to human

## Pre-Commit Fitness Functions

- No hardcoded secrets (patterns: API*KEY=, password=, sk-, sk-ant-, ghp*, AKIA, token=, private keys, JWT, Google API key, Azure connection string, MongoDB URI)
- All new endpoints have input validation:
  - JS/TS: Zod, joi, yup, or express-validator
  - Python: pydantic, marshmallow, or cerberus
  - Go: go-validator or custom validation
  - Rust: serde with validation, or validator crate
- All new database queries use parameterized queries (no string interpolation)
- File size < 800 lines
- Functions < 50 lines
- Immutable patterns used (no mutation of shared state)
- No debug prints in production code:
  - JS/TS: console.log
  - Python: print()
  - Go: fmt.Println
  - Rust: println!
- No hardcoded agent credentials (OAuth tokens, bearer tokens, refresh tokens, client secrets) [DSGAI02]
- PII patterns flagged as warnings (email, SSN, credit card numbers) [DSGAI01]

## Pre-PR Fitness Functions

- Conventional commit messages (feat, fix, refactor, docs, test, chore, perf, ci)
- DOMAIN.md updated if entity schema changed
- API contract backwards-compatible (or breaking change documented in ADR)
- Test coverage >= 80% for changed files
- All TODO comments have associated context

## Architecture Fitness Functions (periodic review)

- Service boundaries respected (no cross-service direct DB access)
- Cache invalidation consistent with TTL policy
- Rate limiting on all public endpoints
- Error messages do not leak internal details or stack traces
- Authentication required on all non-health endpoints
- Plugin/MCP permissions follow least-privilege (no wildcard tool access) [DSGAI06]
- Context minimization — prompts, rules, and CLAUDE.md contain no embedded secrets or PII [DSGAI15]
- Agent/skill configurations contain no embedded credentials [DSGAI02]
