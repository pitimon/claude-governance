# Reference

Full feature reference for `claude-governance`. The [README](../README.md) is the
narrative overview; this is the lookup table.

- [Hooks (always-on)](#hooks-always-on)
- [Skills & agent (on-demand)](#skills--agent-on-demand)
- [Governance checks (31)](#governance-checks-31)
- [Fitness function stages](#fitness-function-stages)
- [Language support](#language-support)
- [Templates](#templates)
- [Rules for `~/.claude/rules/`](#rules-for-clauderules)
- [Platform support](#platform-support)
- [Token budget](#token-budget)
- [Project structure](#project-structure)
- [Development](#development)

Compliance mappings and the agent-harness coverage map live in their own docs:
[DSGAI](compliance/DSGAI-MAPPING.md) · [EU AI Act](compliance/EU-AI-ACT-MAPPING.md) ·
[ISO 42001](compliance/ISO-42001-MAPPING.md) · [NIST AI RMF](compliance/NIST-AI-RMF-MAPPING.md) ·
[ETCLOVG coverage](architecture/etclovg-coverage.md).

---

## Hooks (always-on)

Run automatically inside Claude Code. Codex does not run hooks.

| Hook                   | Trigger              | What it does                                             |
| ---------------------- | -------------------- | -------------------------------------------------------- |
| **Governance context** | Session start        | Injects Three Loops + Consequence Override (~360 tokens) |
| **Secret scanner**     | Every `Edit`/`Write` | 25 BLOCK patterns (secrets) + 3 WARN patterns (PII)      |

## Skills & agent (on-demand)

| Command               | When to use                   | Example                                       |
| --------------------- | ----------------------------- | --------------------------------------------- |
| `/governance-check`   | Before commit/push            | `/governance-check pre-commit`                |
| `/create-adr`         | After an architecture decision| `/create-adr "Adopt PostgreSQL over MongoDB"` |
| `/spec-driven-dev`    | Before feature implementation | `/spec-driven-dev` → writes `spec.md`         |
| `/governance-setup`   | New-project initialization    | Creates `DOMAIN.md`, ADRs, rules              |
| `/eu-ai-act-check`    | Before a high-risk AI release | EU AI Act Arts 9-15 readiness checklist       |
| `/iso-42001-check`    | Before an AIMS audit / attest | ISO/IEC 42001:2023 AIMS 9-clause checklist    |
| `governance-reviewer` | Before a PR (auto-triggered)  | Deep multi-file review with severity grading  |

## Governance checks (31)

| Category         | Count | Key checks                                                                                                        |
| ---------------- | ----- | ----------------------------------------------------------------------------------------------------------------- |
| **Pre-Commit**   | 14    | Secrets, input validation, file size, debug prints, AI model artifacts, unsafe deserialization, telemetry hygiene |
| **Pre-PR**       | 5     | Conventional commits, DOMAIN.md sync, test coverage >= 80%                                                        |
| **Architecture** | 12    | Service boundaries, auth coverage, plugin/MCP security, session isolation, consequence safeguards                 |

## Fitness function stages

Automated governance checks — "unit tests for architecture":

| Stage                  | What gets checked                                                                                                                     |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Pre-Implementation** | Spec exists, domain invariants identified, autonomy classified, irreversible ops flagged                                              |
| **Pre-Commit**         | 14 checks: secrets, PII, validation, file size, functions, immutability, debug prints, AI artifacts, deserialization, deps, telemetry |
| **Pre-PR**             | 5 checks: conventional commits, DOMAIN.md, breaking changes, test coverage, TODO context                                             |
| **Architecture**       | 12 checks: service boundaries, auth, rate limiting, plugin/MCP, context minimization, session isolation, consequence safeguards       |

## Language support

Governance checks detect the project's language and apply stack-specific rules:

| Check        | JS/TS                 | Python                               | Go               | Rust             |
| ------------ | --------------------- | ------------------------------------ | ---------------- | ---------------- |
| Debug prints | `console.log`         | `print()`                            | `fmt.Println`    | `println!`       |
| Validation   | Zod, joi, yup         | pydantic, marshmallow                | go-validator     | serde, validator |
| Dangerous    | `eval()`, `innerHTML` | `eval()`, `exec()`, `pickle.loads()` | `unsafe.Pointer` | `unsafe` blocks  |
| Detection    | `package.json`        | `pyproject.toml`                     | `go.mod`         | `Cargo.toml`     |

## Templates

Ready-to-use templates shipped in `examples/`:

| Template                         | Purpose                                              | Reference |
| -------------------------------- | ---------------------------------------------------- | --------- |
| `DATA-CLASSIFICATION.md.example` | 4-level data sensitivity with AI/LLM data flows      | DSGAI07   |
| `mcp-security-checklist.md`      | Plugin/MCP vetting before installation               | DSGAI06   |
| `shadow-ai-policy.md`            | Approved AI tools, data rules, exceptions            | DSGAI03   |
| `ai-supply-chain-checklist.md`   | Model vetting, dependency pinning, safe alternatives | DSGAI04   |
| `DOMAIN.md.example`              | Entity definitions, invariants, API contracts        | —         |
| `adr-template.md`                | Architecture Decision Record with governance loop    | —         |
| `project-claude-md.example`      | Example project `CLAUDE.md` with governance sections | —         |

## Rules for `~/.claude/rules/`

Optional — install with `bash ~/.claude/plugins/marketplaces/claude-governance/scripts/install-rules.sh`.

| Rule              | Focus                                                                       |
| ----------------- | --------------------------------------------------------------------------- |
| `governance.md`   | Fitness functions: pre-implementation, pre-commit, pre-PR, architecture     |
| `security.md`     | Secret management, agent/plugin security, PII, telemetry, session isolation |
| `coding-style.md` | Immutability, file size limits, error handling                              |
| `git-workflow.md` | Conventional commits, PR workflow, TDD                                      |
| `testing.md`      | 80% coverage minimum, unit/integration/E2E                                  |

## Platform support

Skills, ADRs, and compliance docs are plain Markdown and work identically everywhere.
The **hooks** (SessionStart context + PreToolUse secret scanner) are the only
platform-sensitive surface:

| Environment | Hook behaviour |
| --- | --- |
| macOS / Linux | `.sh` hooks run via bash (default) |
| Windows **with** Git for Windows | `.sh` hooks run via Git Bash (Claude Code's default shell there) |
| Windows **without** Git Bash | Claude Code falls back to the PowerShell shell tool; `.sh` hooks cannot run. PowerShell ports — `hooks/secret-scanner.ps1`, `hooks/session-start.ps1` — are provided and verified byte-for-byte equivalent to the bash hooks (parity gated on a `windows-latest` CI job). |
| **Codex** (any OS) | Does not run hooks at all — skills are used as explicit checklists. |

> **Native-Windows auto-dispatch is not yet wired into the default `hooks/hooks.json`.**
> Claude Code exposes a single hook `command` per event with no OS switch, and selecting the
> right script per-OS without breaking macOS/Linux users needs a mechanism that can only be
> confirmed on a real Windows + Claude Code install (tracked in
> [#58](https://github.com/pitimon/claude-governance/issues/58)). The `.ps1` hooks ship now
> (proven on Windows PowerShell 5.1); a technical user can wire them manually via a personal
> `settings.json` PreToolUse/SessionStart hook that runs
> `powershell -NoProfile -ExecutionPolicy Bypass -File <path>` (the default Restricted policy
> requires `-ExecutionPolicy Bypass`).

**Requirement for the PowerShell path:** Windows 10 1809+ with Windows PowerShell 5.1 (included by default).

## Token budget

| Component            | Tokens   | When                        |
| -------------------- | -------- | --------------------------- |
| SessionStart hook    | ~360     | Every session               |
| Secret scanner       | 0        | Shell script, no token cost |
| Rules (if installed) | ~500-800 | Every session               |
| Skills / agent       | 0        | Only when invoked           |

**Total always-on cost:** ~360 tokens (without rules) / ~1,160 tokens (with rules).

## Project structure

```
claude-governance/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata, skills path, keywords
│   └── marketplace.json         # Marketplace listing schema
├── .codex-plugin/
│   └── plugin.json              # Codex plugin metadata, shared skills path
├── .agents/plugins/
│   └── marketplace.json         # Codex marketplace listing
├── plugin/                      # Codex marketplace child package mirror
├── hooks/
│   ├── hooks.json               # Hook registrations (SessionStart, PreToolUse)
│   ├── session-start.sh         # Three Loops + Consequence Override injection
│   ├── secret-scanner.sh        # 25 BLOCK + 3 WARN patterns, dual-loop
│   ├── session-start.ps1        # PowerShell port (native Windows)
│   └── secret-scanner.ps1       # PowerShell port (native Windows)
├── skills/
│   ├── governance-check/SKILL.md   # 31 checks across 3 categories
│   ├── create-adr/SKILL.md         # ADR generator with governance loop
│   ├── spec-driven-dev/SKILL.md    # Spec-first development workflow
│   ├── governance-setup/SKILL.md   # 6-step project initialization
│   ├── eu-ai-act-check/SKILL.md     # EU AI Act readiness checklist
│   └── iso-42001-check/SKILL.md     # ISO/IEC 42001 AIMS readiness checklist
├── agents/
│   └── governance-reviewer.md   # Deep compliance review with severity grading
├── examples/
│   ├── rules/                   # 5 rules for ~/.claude/rules/
│   └── *.example, *.md          # Templates (see Templates above)
├── docs/
│   ├── INTEGRATION.md           # Companion-plugin integration stub
│   ├── notebooklm-workflow.md   # NotebookLM ↔ Claude Code grounded-corpus workflow
│   ├── reference.md             # This file
│   ├── adr/                     # 8 Architecture Decision Records
│   ├── architecture/            # ETCLOVG 7-layer coverage map
│   ├── compliance/              # DSGAI / EU AI Act / ISO 42001 / NIST AI RMF mappings
│   └── research/                # Compliance research briefs
├── scripts/
│   ├── install-rules.sh         # Rules installer with backup
│   └── bump-version.sh          # Version sync across Claude + Codex manifests
├── tests/
│   ├── validate-plugin.sh       # Structural integrity (100+ checks in CI)
│   ├── test-secret-scanner.sh   # Pattern-by-pattern scanner tests
│   └── test-release-qa.sh       # Release QA checks (runs in CI)
└── .github/workflows/
    └── validate.yml             # CI: structural + scanner + shellcheck + PowerShell parity
```

## Development

```bash
# Structural validation (100+ checks — CI signal)
bash tests/validate-plugin.sh --skip-install-check

# Scanner pattern tests
bash tests/test-secret-scanner.sh

# Release QA suite (8-Habit verified)
bash tests/test-release-qa.sh

# Bump version across all manifests
bash scripts/bump-version.sh X.Y.Z
```
