# ADR-001: Adopt Governance Framework for AI-Assisted Development

## Status

Accepted

## Date

2026-02-22

## Context

AI-assisted development with Claude Code enables high-velocity code generation, but lacks built-in guardrails for quality, security, and architectural consistency. Without governance:

- Secrets can be written directly into source files
- Code quality standards (file size, function length, immutability) are not enforced
- Architectural decisions are undocumented and lost across sessions
- There is no systematic way to classify which decisions require human oversight

A lightweight, zero-dependency governance framework is needed that works within Claude Code's plugin system without adding runtime overhead or external tooling.

## Decision

Adopt a governance framework built on five pillars:

1. **Three Loops Decision Model** — Classify every task by AI autonomy level (Out-of-Loop, On-the-Loop, In-the-Loop) to ensure appropriate human oversight for high-impact decisions.

2. **Fitness Functions** — Automated governance checks ("unit tests for architecture") at four stages: pre-implementation, pre-commit, pre-PR, and architecture review. These enforce measurable standards (file < 800 lines, functions < 50 lines, no hardcoded secrets, 80%+ test coverage).

3. **Spec-Driven Development** — Require formal specifications before implementation for non-trivial features. Developer defines WHAT and constraints; AI generates HOW within guardrails.

4. **Architecture Decision Records (ADRs)** — Document significant technical decisions with context, consequences, and governance classification for audit trail and knowledge continuity.

5. **Secret Scanning** — Real-time hook that blocks file writes containing hardcoded secrets (API keys, tokens, private keys, credentials) before they reach the filesystem.

The framework is implemented as a Claude Code plugin using only Markdown skills, shell scripts, and JSON configuration — zero runtime dependencies.

## Consequences

### Positive

- Secrets are caught before they enter version control, preventing credential leaks
- Code quality standards are consistently enforced across sessions and developers
- Technical decisions are documented and discoverable through ADRs
- The Three Loops model provides a clear framework for AI autonomy classification
- Zero-dependency design means no version conflicts, no build steps, no maintenance burden

### Negative

- ~300 token cost per session for governance context injection
- Learning curve for developers unfamiliar with fitness functions or Three Loops model
- Shell-based secret scanner has known limitations (no multi-line detection, no base64 decoding)

### Risks

- Pattern-based secret scanning may produce false positives on legitimate code patterns
- Governance overhead could slow down trivial tasks if not properly classified via Three Loops

## Governance

- **Decision Loop**: In-the-Loop — This is a foundational architecture decision affecting all plugin users
- **Fitness Function**: `bash tests/validate-plugin.sh` — Validates structural integrity of the governance framework itself (46+ checks)
- **Review Trigger**: When adding new governance capabilities, changing the Three Loops classification criteria, or modifying the secret scanner's pattern set
