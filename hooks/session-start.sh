#!/usr/bin/env bash

# Inject governance context at session start
# Pattern: explanatory-output-style plugin

cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "## Governance Framework Active\n\nYou have the **claude-governance** plugin installed. Follow these governance principles:\n\n### Three Loops Decision Model\n- **Out-of-Loop** (AI autonomous): Formatting, lint fixes, import cleanup, simple bug fixes\n- **On-the-Loop** (AI proposes, human approves): New features, API changes, refactoring >3 files\n- **In-the-Loop** (Human decides): Architecture, security model, breaking changes, data migration\n\n### Pre-Commit Fitness Functions\nBefore committing, self-check:\n- No hardcoded secrets (API_KEY=, password=, sk-, ghp_, AKIA, token=)\n- Input validation on all new endpoints (Zod or equivalent)\n- Parameterized database queries (no string interpolation)\n- File size < 800 lines, functions < 50 lines\n- Immutable patterns (no mutation of shared state)\n- No console.log in production code\n\n### Quality Standards\n- Conventional commits: feat, fix, refactor, docs, test, chore, perf, ci\n- Test coverage >= 80% for changed files\n- Error messages must not leak internal details\n- DOMAIN.md updated if entity schema changed\n\n### Available Commands\n- `/governance-check [pre-commit|pre-pr|architecture|all]` — Run fitness function checks\n- `/create-adr <title>` — Create Architecture Decision Record\n- `/spec-driven-dev` — Spec-first development workflow\n- `/governance-setup` — Initialize governance in a project"
  }
}
EOF

exit 0
