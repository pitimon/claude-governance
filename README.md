<p align="center">
  <h1 align="center">claude-governance</h1>
  <p align="center">
    Governance framework for Claude Code and Codex — fitness functions, spec-driven development, ADRs, and OWASP DSGAI compliance.
  </p>
  <p align="center">
    <a href="https://github.com/pitimon/claude-governance/actions/workflows/validate.yml"><img src="https://github.com/pitimon/claude-governance/actions/workflows/validate.yml/badge.svg" alt="Validate Plugin"></a>
    <a href="https://github.com/pitimon/claude-governance/releases/latest"><img src="https://img.shields.io/github/v/release/pitimon/claude-governance?label=version" alt="Version"></a>
    <a href="LICENSE"><img src="https://img.shields.io/github/license/pitimon/claude-governance" alt="License"></a>
    <img src="https://img.shields.io/badge/dependencies-zero-brightgreen" alt="Zero Dependencies">
    <img src="https://img.shields.io/badge/OWASP_DSGAI-11_controls-orange" alt="DSGAI Controls">
    <img src="https://img.shields.io/badge/languages-JS%2FTS%20%7C%20Python%20%7C%20Go%20%7C%20Rust-blue" alt="Language Support">
  </p>
</p>

> Stop writing code. Start governing AI that writes code for you.

---

## Contents

**Start here:** [Why](#why-claude-governance) · [What you get on install](#what-happens-when-you-install-in-claude-code) · [Quick Start](#quick-start) · [Usage Examples](#real-world-usage-examples)

**Reference:** [Features at a Glance](#features-at-a-glance) · [Core Concepts](#core-concepts) · [Architecture](#architecture) · [Platform Support](#platform-support) · [Token Budget](#token-budget)

**Contribute:** [Project Structure](#project-structure) · [Development](#development) · [Contributing](#contributing) · [Companion Plugins](#companion-plugins) · [References](#references)

---

## Why claude-governance?

AI-assisted development is fast — but ungoverned AI is a liability.

| Without Governance                            | With claude-governance                                   |
| --------------------------------------------- | -------------------------------------------------------- |
| `sk-ant-api03-xxx` committed to git           | Blocked before it reaches the filesystem                 |
| Junior dev deploys to production via AI       | Three Loops classifies it as In-the-Loop — human decides |
| Prompt context leaks PII to observability     | Telemetry hygiene check flags `log(prompt)` patterns     |
| Team uses 5 different AI tools with no policy | Shadow AI policy template — approved tools, data rules   |
| "Who decided to use MongoDB?" — no one knows  | ADR system records every architecture decision           |

**Zero dependencies.** Zero build steps. Markdown skills run in Claude Code and Codex; shell hooks run inside Claude Code.

---

## What Happens When You Install In Claude Code

```
Session starts...

  Governance Framework Active

  Three Loops Decision Model:
  - Out-of-Loop (AI autonomous): formatting, lint, simple fixes
  - On-the-Loop (AI proposes): features, API changes
  - In-the-Loop (Human decides): architecture, security, breaking changes

  Consequence Override: Irreversible operations → always In-the-Loop
```

From this point, every Claude Code `Edit`/`Write` is scanned for secrets. In Codex, install exposes the governance skills and docs; run `governance-check` explicitly because Claude Code hooks do not run there.

---

## Quick Start

```bash
# Claude Code install (one-time)
claude plugin marketplace add pitimon/claude-governance
claude plugin install claude-governance@claude-governance

# (Optional) Install rules to ~/.claude/rules/
bash ~/.claude/plugins/marketplaces/claude-governance/scripts/install-rules.sh

# Codex install (skills + docs; Claude Code hooks do not run in Codex)
codex plugin marketplace add pitimon/claude-governance
codex plugin add claude-governance@pitimon-claude-governance

# If you added the Codex marketplace before v3.4.0, refresh it first:
codex plugin marketplace upgrade pitimon-claude-governance
```

---

## Real-World Usage Examples

### Catch a leaked API key before it enters git

```
You: Write the config file with the API key

Claude writes: api_key = "sk-ant-api03-xxxxx"

  Governance: Blocked — Anthropic API key detected.
  Use environment variables instead:
    JS/TS:  const value = process.env.YOUR_SECRET
    Python: value = os.environ['YOUR_SECRET']
    Go:     value := os.Getenv("YOUR_SECRET")
```

### Run pre-commit governance checks

```
You: /governance-check pre-commit

  ## Governance Check: pre-commit

  ### Passed
  - [x] No hardcoded secrets found
  - [x] Input validation present (Zod schema)
  - [x] File sizes within limits
  - [x] No debug prints in production

  ### Failed
  - [ ] FAIL: `src/ml/loader.py:12` — torch.load() without weights_only=True [DSGAI04]
  - [ ] FAIL: `src/api/handler.ts` — 847 lines (max 800)

  Passed: 8/10 | Failed: 2
```

### Classify a task with Three Loops + Consequence

```
You: Format the deployment config and push to production

Claude: This task is Out-of-Loop (formatting) BUT involves irreversible
        consequence (production deploy). Per ADR-002 Consequence Override:
        Irreversible → always In-the-Loop.

        I'll format the file, but you should review and deploy manually.
```

### Initialize governance in a new project

```
You: /governance-setup

  Step 1: Creating DOMAIN.md...
  Step 2: Setting up docs/adr/
  Step 3: Data Classification (Optional)
  Step 3.5: Shadow AI Policy (Optional)
  Step 4: Install Rules

  Governance initialized:
  - DOMAIN.md — edit to define your entities
  - docs/adr/ADR-001 — governance adoption record
  - DATA-CLASSIFICATION.md — data sensitivity levels
  - shadow-ai-policy.md — approved AI tools
```

---

## Features at a Glance

### Always-On (Hooks)

| Hook                   | Trigger              | What It Does                                             |
| ---------------------- | -------------------- | -------------------------------------------------------- |
| **Governance context** | Session start        | Injects Three Loops + Consequence Override (~360 tokens) |
| **Secret scanner**     | Every `Edit`/`Write` | 25 BLOCK patterns (secrets) + 3 WARN patterns (PII)      |

### On-Demand (Skills & Agent)

| Command               | When to Use                   | Example                                       |
| --------------------- | ----------------------------- | --------------------------------------------- |
| `/governance-check`   | Before commit/push            | `/governance-check pre-commit`                |
| `/create-adr`         | After architecture decision   | `/create-adr "Adopt PostgreSQL over MongoDB"` |
| `/spec-driven-dev`    | Before feature implementation | `/spec-driven-dev` → writes spec.md           |
| `/governance-setup`   | New project initialization    | Creates DOMAIN.md, ADRs, rules                |
| `/eu-ai-act-check`    | Before high-risk AI release   | EU AI Act Arts 9-15 readiness checklist       |
| `/iso-42001-check`    | Before AIMS audit / attest    | ISO/IEC 42001:2023 AIMS 9-clause checklist    |
| `governance-reviewer` | Before PR (auto-triggered)    | Deep multi-file review with severity grading  |

### 31 Governance Checks

| Category         | Count | Key Checks                                                                                                        |
| ---------------- | ----- | ----------------------------------------------------------------------------------------------------------------- |
| **Pre-Commit**   | 14    | Secrets, input validation, file size, debug prints, AI model artifacts, unsafe deserialization, telemetry hygiene |
| **Pre-PR**       | 5     | Conventional commits, DOMAIN.md sync, test coverage >= 80%                                                        |
| **Architecture** | 12    | Service boundaries, auth coverage, plugin/MCP security, session isolation, consequence safeguards                 |

### OWASP DSGAI Compliance — 11 Controls

Mapped to [OWASP GenAI Data Security](https://genai.owasp.org) v1.0 (March 2026):

| Control | Risk                      | What We Do                                                       |
| ------- | ------------------------- | ---------------------------------------------------------------- |
| DSGAI01 | Sensitive Data Leakage    | PII WARN patterns (email, SSN, credit card)                      |
| DSGAI02 | Agent Credential Exposure | BLOCK patterns for OAuth, Bearer, refresh tokens                 |
| DSGAI03 | Shadow AI                 | Policy template with approved alternatives                       |
| DSGAI04 | Data/Model Poisoning      | Model file detection, unsafe deserialization, dependency pinning |
| DSGAI06 | Plugin/Tool Data Exchange | MCP security checklist, least-privilege checks                   |
| DSGAI07 | Data Classification       | 4-level classification template with AI/LLM data flows           |
| DSGAI08 | Compliance Violations     | This compliance mapping + `[DSGAI##]` tags in all outputs        |
| DSGAI11 | Cross-Context Bleed       | Session isolation, multi-tenant separation checks                |
| DSGAI14 | Telemetry Leakage         | Flags `log(prompt)` patterns in production code                  |
| DSGAI15 | Over-Broad Context        | Context minimization checks, token budget enforcement            |
| DSGAI19 | Human-in-the-Loop Gaps    | Consequence-based auth — irreversible ops always In-the-Loop     |

See [docs/compliance/DSGAI-MAPPING.md](docs/compliance/DSGAI-MAPPING.md) for the full control-by-control mapping.

### Language Support

Governance checks detect the project's language and apply stack-specific rules:

| Check        | JS/TS                 | Python                               | Go               | Rust             |
| ------------ | --------------------- | ------------------------------------ | ---------------- | ---------------- |
| Debug prints | `console.log`         | `print()`                            | `fmt.Println`    | `println!`       |
| Validation   | Zod, joi, yup         | pydantic, marshmallow                | go-validator     | serde, validator |
| Dangerous    | `eval()`, `innerHTML` | `eval()`, `exec()`, `pickle.loads()` | `unsafe.Pointer` | `unsafe` blocks  |
| Detection    | `package.json`        | `pyproject.toml`                     | `go.mod`         | `Cargo.toml`     |

### Ready-to-Use Templates

| Template                         | Purpose                                              | Reference |
| -------------------------------- | ---------------------------------------------------- | --------- |
| `DATA-CLASSIFICATION.md.example` | 4-level data sensitivity with AI/LLM data flows      | DSGAI07   |
| `mcp-security-checklist.md`      | Plugin/MCP vetting before installation               | DSGAI06   |
| `shadow-ai-policy.md`            | Approved AI tools, data rules, exceptions            | DSGAI03   |
| `ai-supply-chain-checklist.md`   | Model vetting, dependency pinning, safe alternatives | DSGAI04   |
| `DOMAIN.md.example`              | Entity definitions, invariants, API contracts        | —         |
| `adr-template.md`                | Architecture Decision Record with governance loop    | —         |

### Rules for `~/.claude/rules/`

| Rule              | Focus                                                                       |
| ----------------- | --------------------------------------------------------------------------- |
| `governance.md`   | Fitness functions: pre-implementation, pre-commit, pre-PR, architecture     |
| `security.md`     | Secret management, agent/plugin security, PII, telemetry, session isolation |
| `coding-style.md` | Immutability, file size limits, error handling                              |
| `git-workflow.md` | Conventional commits, PR workflow, TDD                                      |
| `testing.md`      | 80% coverage minimum, unit/integration/E2E                                  |

---

## Core Concepts

### Three Loops + Consequence-Based Authorization

Every task is classified on two dimensions:

```
                      Task Type
                      Out-of-Loop    On-the-Loop    In-the-Loop
Consequence
  Reversible          autonomous      propose         human-driven
  Contained           autonomous      propose         human-driven
  Broad               propose         propose         human-driven
  Irreversible        HUMAN-DRIVEN    HUMAN-DRIVEN    human-driven
```

**Override rule:** Irreversible operations (production deploy, data deletion, credential rotation) are **always In-the-Loop** — even if the task itself is trivial. See [ADR-002](docs/adr/ADR-002-consequence-based-authorization.md).

### Fitness Functions

Automated governance checks — "unit tests for architecture":

| Stage                  | What Gets Checked                                                                                                                     |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **Pre-Implementation** | Spec exists, domain invariants identified, autonomy classified, irreversible ops flagged                                              |
| **Pre-Commit**         | 14 checks: secrets, PII, validation, file size, functions, immutability, debug prints, AI artifacts, deserialization, deps, telemetry |
| **Pre-PR**             | 5 checks: conventional commits, DOMAIN.md, breaking changes, test coverage, TODO context                                              |
| **Architecture**       | 12 checks: service boundaries, auth, rate limiting, plugin/MCP, context minimization, session isolation, consequence safeguards       |

### Spec-Driven Development

```
Understand ──> Specify ──> Plan ──> Implement ──> Verify
     │              │          │          │            │
  Explore       Write      Plan Mode  Code to     Check criteria
  codebase      spec.md    from spec  spec        Run tests
  Clarify       Acceptance            On-the-Loop Validate domain
  requirements  criteria              iterations  invariants
```

---

## Architecture

```
                       ┌────────────────────────────┐
                       │  Claude Code Session       │
                       └─────────────┬──────────────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              ▼                      ▼                      ▼
       ┌─────────────┐        ┌─────────────┐       ┌──────────────┐
       │  Always-On  │        │  On-Demand  │       │   Config     │
       └──────┬──────┘        └──────┬──────┘       └──────┬───────┘
              │                      │                      │
   ┌──────────┴──────────┐  ┌────────┴─────────┐  ┌────────┴─────────┐
   │ SessionStart Hook   │  │ /governance-check│  │ ~/.claude/rules/ │
   │  Three Loops +      │  │   31 checks /    │  │   5 rule files   │
   │  Consequence        │  │   3 categories   │  │                  │
   │  ~360 tokens        │  │                  │  │ Templates        │
   │                     │  │ /create-adr      │  │   7 examples     │
   │ PreToolUse Hook     │  │ /spec-driven-dev │  │                  │
   │  Secret Scanner     │  │ /governance-setup│  │ Always loaded if │
   │  25 BLOCK + 3 WARN  │  │                  │  │ installed.       │
   │  blocks file writes │  │ governance-      │  │                  │
   └─────────────────────┘  │ reviewer agent   │  └──────────────────┘
                            │   deep + severity│
                            │ /eu-ai-act-check │
                            │ /iso-42001-check │
                            └──────────────────┘

   ┌──────────────────────────────────────────────────────────────┐
   │  Compliance Anchors                                          │
   │  • DSGAI-MAPPING.md → 11 OWASP DSGAI controls                │
   │  • docs/adr/        → ADR set (see docs/adr/)                │
   └──────────────────────────────────────────────────────────────┘
```

→ **[docs/architecture/etclovg-coverage.md](docs/architecture/etclovg-coverage.md)** — ETCLOVG 7-layer taxonomy coverage map (Agent Harness Engineering). Anchor for future scope-expansion decisions: `G` strong, `V/L/C` partial, `O` none, `E/T` out-of-scope by charter / plugin boundary.

### Agent Harness Coverage (ETCLOVG)

<!-- Mirror of docs/architecture/etclovg-coverage.md § Per-layer coverage (single source of truth). Update both in the same PR to avoid drift. See issue #46. -->

`Agent = Model + Harness`. The **ETCLOVG taxonomy** (Agent Harness Engineering, 2026) defines 7 layers that wrap a model to make it a reliable autonomous agent: **E**xecution, **T**ooling, **C**ontext+Memory, **L**ifecycle, **O**bservability, **V**erification, **G**overnance. This plugin's per-layer coverage:

| Layer                             |        Status         | What ships today                                                                                                                                                                                                                                     | Gap / Why not                                                                     |
| --------------------------------- | :-------------------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| **E** — Execution Environment     |     `OOS-charter`     | —                                                                                                                                                                                                                                                    | "Skills are read-only guidance" — charter-amendment ADR required to re-evaluate   |
| **T** — Tooling (MCP / A2A)       | `OOS-plugin-boundary` | —                                                                                                                                                                                                                                                    | Routed to sibling plugin `pitimon/devsecops-ai-team` (plugin boundary)            |
| **C** — Context & Memory          |       `Partial`       | `hooks/session-start.sh` (~360 tokens/session — Progressive Disclosure); skills lazy-load on `/command`                                                                                                                                              | No Compaction or Context Resets                                                   |
| **L** — Lifecycle & Orchestration |       `Partial`       | Three Loops + Consequence Override (ADR-002) — autonomy classification with irreversible-op gating                                                                                                                                                   | No multi-agent orchestration or Planner-Generator-Evaluator structural separation |
| **O** — Observability             |        `None`         | —                                                                                                                                                                                                                                                    | No trace / telemetry / SLA metrics — awaiting first-person friction signal        |
| **V** — Verification              |       `Partial`       | 31 fitness functions (pre-commit / pre-PR / architecture), `governance-reviewer` agent, `validate-plugin.sh` (100+ structural checks)                                                                                                                | "Verify Before You Fix" sandbox gate not yet codified                             |
| **G** — Governance & Security     |     **`Strong`**      | (1) Three Loops + Consequence Override (ADR-002) · (2) `secret-scanner.sh` 25 BLOCK + 3 WARN · (3) `governance-reviewer` agent · (4) 31 governance checks · (5) Compliance mappings: EU AI Act / ISO 42001 / NIST AI RMF / OWASP DSGAI (11 controls) | — primary focus                                                                   |

**Coverage summary**:

| Status                | Count | Layers  |
| --------------------- | ----: | ------- |
| `Strong`              |     1 | G       |
| `Partial`             |     3 | C, L, V |
| `None`                |     1 | O       |
| `OOS-charter`         |     1 | E       |
| `OOS-plugin-boundary` |     1 | T       |

> **Friction-first**: `Partial` is not an invitation to expand. Per ADR-014 in `8-habit-ai-dev`, pattern attractiveness alone is not a shipping criterion — a first-person friction case (issue, lesson, post-mortem) must be cited before any `Partial` → `Strong` move.
>
> **Adopter shorthand**: use `claude-governance` for **G strong** + **V/L/C partial**. For **E (sandbox)** or **T (MCP)**, pair with [`pitimon/devsecops-ai-team`](https://github.com/pitimon/devsecops-ai-team).

---

## Platform Support

Skills, ADRs, and compliance docs are plain Markdown and work identically everywhere. The **hooks** (SessionStart context + PreToolUse secret scanner) are the only platform-sensitive surface:

| Environment | Hook behaviour |
| --- | --- |
| macOS / Linux | `.sh` hooks run via bash (default) |
| Windows **with** Git for Windows | `.sh` hooks run via Git Bash (Claude Code's default shell there) |
| Windows **without** Git Bash | Claude Code falls back to the PowerShell shell tool; `.sh` hooks cannot run. PowerShell ports — `hooks/secret-scanner.ps1`, `hooks/session-start.ps1` — are provided and verified byte-for-byte equivalent to the bash hooks (parity gated on a `windows-latest` CI job). |
| **Codex** (any OS) | Does not run hooks at all — skills are used as explicit checklists. |

> **Native-Windows auto-dispatch is not yet wired into the default `hooks/hooks.json`.** Claude Code exposes a single hook `command` per event with no OS switch, and selecting the right script per-OS without breaking macOS/Linux users (or spamming them with per-edit errors) needs a mechanism that can only be confirmed on a real Windows + Claude Code install. That validation is tracked in **[#58](https://github.com/pitimon/claude-governance/issues/58)**. The `.ps1` hooks ship now (proven on Windows PowerShell 5.1) so the port is ready the moment dispatch is confirmed; a technical user can also wire them manually via a personal `settings.json` PreToolUse/SessionStart hook that runs `powershell -NoProfile -ExecutionPolicy Bypass -File <path>` (Windows PowerShell requires `-ExecutionPolicy Bypass` under the default Restricted policy).

**Requirement for the PowerShell path:** Windows 10 1809+ with Windows PowerShell 5.1 (included by default).

---

## Token Budget

| Component            | Tokens   | When                        |
| -------------------- | -------- | --------------------------- |
| SessionStart hook    | ~360     | Every session               |
| Secret scanner       | 0        | Shell script, no token cost |
| Rules (if installed) | ~500-800 | Every session               |
| Skills / agent       | 0        | Only when invoked           |

**Total always-on cost:** ~360 tokens (without rules) / ~1,160 tokens (with rules)

---

## Project Structure

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
│   └── secret-scanner.sh        # 25 BLOCK + 3 WARN patterns, dual-loop
├── skills/
│   ├── governance-check/SKILL.md  # 31 checks across 3 categories
│   ├── create-adr/SKILL.md       # ADR generator with governance loop
│   ├── spec-driven-dev/SKILL.md   # Spec-first development workflow
│   ├── governance-setup/SKILL.md  # 6-step project initialization
│   ├── eu-ai-act-check/SKILL.md   # EU AI Act readiness checklist
│   └── iso-42001-check/SKILL.md   # ISO/IEC 42001 AIMS readiness checklist
├── agents/
│   └── governance-reviewer.md   # Deep compliance review with severity grading
├── examples/
│   ├── rules/                   # 5 rules for ~/.claude/rules/
│   ├── DATA-CLASSIFICATION.md.example  # Data sensitivity template [DSGAI07]
│   ├── mcp-security-checklist.md       # MCP/plugin security [DSGAI06]
│   ├── shadow-ai-policy.md            # Shadow AI policy [DSGAI03]
│   ├── ai-supply-chain-checklist.md   # AI artifact vetting [DSGAI04]
│   ├── DOMAIN.md.example              # Domain model template
│   ├── adr-template.md                # ADR template
│   └── project-claude-md.example
├── docs/
│   ├── INTEGRATION.md            # Companion-plugin integration stub (SSOT in 8-habit-ai-dev)
│   ├── notebooklm-workflow.md    # NotebookLM ↔ Claude Code grounded-corpus workflow
│   ├── adr/                      # 8 Architecture Decision Records
│   │   ├── ADR-001-adopt-governance-framework.md
│   │   ├── ADR-002-consequence-based-authorization.md
│   │   ├── ADR-003-eu-ai-act-compliance-toolkit.md
│   │   ├── ADR-004-iso-42001-framework-selection.md
│   │   ├── ADR-005-nist-ai-rmf-cross-reference-doc.md
│   │   ├── ADR-006-hook-design-principle-write-vs-edit.md
│   │   ├── ADR-007-codex-native-packaging.md
│   │   └── ADR-008-governance-reviewer-model-inherit.md
│   ├── architecture/
│   │   └── etclovg-coverage.md   # ETCLOVG 7-layer taxonomy map (Agent Harness Engineering)
│   ├── compliance/               # Framework mappings (4 files)
│   │   ├── DSGAI-MAPPING.md       # 11 OWASP DSGAI controls mapped
│   │   ├── EU-AI-ACT-MAPPING.md   # EU AI Act Arts 9-15 mapping
│   │   ├── ISO-42001-MAPPING.md   # ISO/IEC 42001:2023 AIMS controls
│   │   └── NIST-AI-RMF-MAPPING.md # NIST AI RMF 1.0 cross-reference
│   └── research/                 # Compliance research briefs (EU AI Act, NIST AI RMF)
├── scripts/
│   ├── install-rules.sh         # Rules installer with backup
│   └── bump-version.sh          # Version sync across Claude + Codex manifests
├── tests/
│   ├── validate-plugin.sh       # Structural integrity (100+ checks in CI)
│   ├── test-secret-scanner.sh   # 40 pattern-by-pattern tests
│   └── test-release-qa.sh       # 166 QA checks (8-Habit verified; runs in CI)
├── .github/workflows/
│   └── validate.yml             # CI: structural + scanner tests
├── CHANGELOG.md
├── README.md
└── LICENSE
```

---

## Development

```bash
# Structural validation (100+ checks — CI signal)
bash tests/validate-plugin.sh --skip-install-check

# Scanner pattern tests (40 tests)
bash tests/test-secret-scanner.sh

# Full QA suite (166 checks, 8-Habit verified; local-only)
bash tests/test-release-qa.sh

# Bump version
bash scripts/bump-version.sh X.Y.Z
```

---

## Contributing

Areas where help is welcome:

- Fitness function examples for other tech stacks (Ruby, PHP, Java, C#)
- Language-specific secret and PII patterns
- Translations (i18n for session-start context)
- Real-world case studies and governance templates
- OWASP DSGAI Tier 3 controls (DSGAI05, DSGAI12, DSGAI13)

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## Companion Plugins

`claude-governance` works **fully standalone**. For projects that combine it with `8-habit-ai-dev` (workflow method) and/or `devsecops-ai-team` (operational tooling), the canonical integration guide lives in `8-habit-ai-dev` to prevent SSOT drift across version bumps:

→ **[docs/INTEGRATION.md](docs/INTEGRATION.md)** (local stub) — links to the canonical guide and notes governance-specific points (Three Loops + ADR-002, EU AI Act canonical role per ADR-003).

Tested against `8-habit-ai-dev` 2.21.42 and `devsecops-ai-team` 10.15.0.

---

## References

- **Fitness Functions** — _Building Evolutionary Architectures_ (Ford, Parsons, Kua — O'Reilly)
- **ADRs** — _Lightweight Architecture Decision Records_ (ThoughtWorks Technology Radar)
- **Spec-Driven Dev** — Derived from Design-by-Contract (Meyer, 1986)
- **Three Loops** — Human-AI interaction model for autonomous systems
- **Consequence-Based Auth** — See [ADR-002](docs/adr/ADR-002-consequence-based-authorization.md) — extends Three Loops with blast radius
- **OWASP DSGAI** — _GenAI Data Security Risks and Mitigations_ v1.0 (March 2026) — [genai.owasp.org](https://genai.owasp.org)
- **Compliance Mapping** — See [docs/compliance/DSGAI-MAPPING.md](docs/compliance/DSGAI-MAPPING.md) for 11 controls

---

## License

[MIT](LICENSE) — Copyright (c) 2026 pitimon
