#!/usr/bin/env bash

# Inject governance context at session start
# Pattern: explanatory-output-style plugin

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "## Governance Framework Active\n\nYou have the **claude-governance** plugin installed. Follow these governance principles:\n\n### Three Loops Decision Model\n- **Out-of-Loop** (AI autonomous): Formatting, lint fixes, import cleanup, simple bug fixes\n- **On-the-Loop** (AI proposes, human approves): New features, API changes, refactoring >3 files\n- **In-the-Loop** (Human decides): Architecture, security model, breaking changes, data migration\n\n### Pre-Commit Fitness Functions\nBefore committing, self-check:\n- No hardcoded secrets (API_KEY=, password=, sk-, sk-ant-, ghp_, AKIA, token=, private keys, JWT)\n- No hardcoded agent credentials (OAuth, bearer, refresh tokens, client secrets) [DSGAI02]\n- Input validation on all new endpoints (language-appropriate: Zod/joi for JS, pydantic for Python, go-validator for Go, serde for Rust)\n- Parameterized database queries (no string interpolation)\n- File size < 800 lines, functions < 50 lines\n- Immutable patterns (no mutation of shared state)\n- No debug prints in production code (console.log, print(), fmt.Println, println!)\n- Context minimization: no unnecessary sensitive data in prompts, rules, or CLAUDE.md [DSGAI15]\n\n### Quality Standards\n- Conventional commits: feat, fix, refactor, docs, test, chore, perf, ci\n- Test coverage >= 80% for changed files\n- Error messages must not leak internal details\n- DOMAIN.md updated if entity schema changed\n\n### Available Commands\n- `/governance-check [pre-commit|pre-pr|architecture|all]` — Quick fitness function checklist (fast, single-category, pass/fail)\n- `/create-adr <title>` — Create Architecture Decision Record\n- `/spec-driven-dev` — Spec-first development workflow\n- `/governance-setup` — Initialize governance in a project\n- `governance-reviewer` agent — Deep multi-file compliance review (severity-graded, domain invariants, architecture)\n- `docs/compliance/DSGAI-MAPPING.md` — OWASP DSGAI control mapping"
  }
}
EOF

exit 0
