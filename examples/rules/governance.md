# Governance Fitness Functions

Automated governance checks — "unit tests for architecture". Self-check before, during, and after implementation.

## Pre-Implementation Checks (before writing code)
- Spec exists for non-trivial features (> 3 files changed)
- Domain invariants from DOMAIN.md are identified and preserved
- Decision autonomy level is appropriate (Three Loops)
- Breaking changes are identified and flagged to human

## Pre-Commit Fitness Functions
- No hardcoded secrets (patterns: API_KEY=, password=, sk-, token=)
- All new endpoints have input validation (Zod or equivalent schema)
- All new database queries use parameterized queries (no string interpolation)
- File size < 800 lines
- Functions < 50 lines
- Immutable patterns used (no mutation of shared state)
- No console.log in production code

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
