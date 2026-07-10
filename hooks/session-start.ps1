#Requires -Version 5.1
# session-start.ps1 - PowerShell port of session-start.sh (SessionStart hook).
# Emits the identical governance-context JSON to stdout. File is UTF-8 WITH BOM
# so Windows PowerShell 5.1 reads the unicode arrows/em-dashes correctly (it
# otherwise decodes .ps1 source as ANSI); output encoding is set to UTF-8 too.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$json = @'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "## Governance Framework Active\n\nYou have the **claude-governance** plugin installed. Follow these governance principles:\n\n### Three Loops Decision Model\n- **Out-of-Loop** (AI autonomous): Formatting, lint fixes, import cleanup, simple bug fixes\n- **On-the-Loop** (AI proposes, human approves): New features, API changes, refactoring >3 files\n- **In-the-Loop** (Human decides): Architecture, security model, breaking changes, data migration\n\n**Consequence Override**: Irreversible operations (production deploy, data deletion, credential rotation) → always In-the-Loop regardless of task type. See ADR-002.\n\n### Pre-Commit Fitness Functions\nBefore committing, self-check:\n- No hardcoded secrets (API_KEY=, password=, sk-, sk-ant-, ghp_, AKIA, token=, private keys, JWT)\n- No hardcoded agent credentials (OAuth, bearer, refresh tokens, client secrets) [DSGAI02]\n- Input validation on all new endpoints (language-appropriate: Zod/joi for JS, pydantic for Python, go-validator for Go, serde for Rust)\n- Parameterized database queries (no string interpolation)\n- File size < 800 lines, functions < 50 lines\n- Immutable patterns (no mutation of shared state)\n- No debug prints in production code (console.log, print(), fmt.Println, println!)\n- Context minimization: no unnecessary sensitive data in prompts, rules, or CLAUDE.md [DSGAI15]\n\n### Quality Standards\n- Conventional commits: feat, fix, refactor, docs, test, chore, perf, ci\n- Test coverage >= 80% for changed files\n- Error messages must not leak internal details\n- DOMAIN.md updated if entity schema changed\n\n### Available Commands\n- `/governance-check [pre-commit|pre-pr|architecture|all]` — Quick fitness function checklist (fast, single-category, pass/fail)\n- `/create-adr <title>` — Create Architecture Decision Record\n- `/spec-driven-dev` — Spec-first development workflow\n- `/governance-setup` — Initialize governance in a project\n- `/eu-ai-act-check` — EU AI Act Arts 9-15 readiness checklist (high-risk AI systems)\n- `/iso-42001-check` — ISO/IEC 42001:2023 AIMS readiness checklist (38 controls)\n- `governance-reviewer` agent — Deep multi-file compliance review (severity-graded, domain invariants, architecture)\n- `docs/compliance/DSGAI-MAPPING.md` — OWASP DSGAI control mapping (11 controls)"
  }
}
'@
[Console]::Out.Write($json)
[Console]::Out.Write("`n")
exit 0
