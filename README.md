<p align="center">
  <h1 align="center">claude-governance</h1>
  <p align="center">
    Governance framework for Claude Code — fitness functions, secret scanning, spec-driven development, and architectural decision records.
  </p>
  <p align="center">
    <a href="https://github.com/pitimon/claude-governance/actions/workflows/validate.yml"><img src="https://github.com/pitimon/claude-governance/actions/workflows/validate.yml/badge.svg" alt="Validate Plugin"></a>
    <a href="https://github.com/pitimon/claude-governance/releases/latest"><img src="https://img.shields.io/github/v/release/pitimon/claude-governance?label=version" alt="Version"></a>
    <a href="LICENSE"><img src="https://img.shields.io/github/license/pitimon/claude-governance" alt="License"></a>
    <img src="https://img.shields.io/badge/dependencies-zero-brightgreen" alt="Zero Dependencies">
    <img src="https://img.shields.io/badge/languages-JS%2FTS%20%7C%20Python%20%7C%20Go%20%7C%20Rust-blue" alt="Language Support">
  </p>
</p>

> Stop writing code. Start governing AI that writes code for you.

---

## Why claude-governance?

AI code generation is fast but ungoverned. Without guardrails:

- **Secrets leak** — API keys hardcoded in source files slip into git history
- **Quality drifts** — No consistent standards across sessions or developers
- **Decisions vanish** — Architecture choices are lost between conversations
- **Oversight gaps** — No framework for when AI should act vs. when humans should decide

**claude-governance** solves this with a zero-dependency plugin that runs inside Claude Code — no build steps, no runtime overhead, just Markdown skills and shell scripts.

---

## Quick Start

```bash
# 1. Add marketplace
claude plugin marketplace add pitimon/claude-governance

# 2. Install plugin
claude plugin install claude-governance@claude-governance

# 3. (Optional) Install rules to ~/.claude/rules/
bash ~/.claude/plugins/marketplaces/claude-governance/scripts/install-rules.sh
```

Start a new session — governance context loads automatically (~300 tokens).

---

## Features

### Always-On Hooks

| Hook                   | Event          | What It Does                                                   |
| ---------------------- | -------------- | -------------------------------------------------------------- |
| **Governance context** | `SessionStart` | Injects Three Loops model + fitness functions (~300 tokens)    |
| **Secret scanner**     | `PreToolUse`   | Blocks `Edit`/`Write`/`MultiEdit` containing hardcoded secrets |

### Secret Scanner — 20 Patterns

The scanner detects secrets in real-time before they reach the filesystem:

| Category        | Patterns                                                                     |
| --------------- | ---------------------------------------------------------------------------- |
| AI/ML keys      | `sk-*` (OpenAI/Stripe), `sk-ant-*` (Anthropic), `sk-proj-*` (OpenAI project) |
| Cloud providers | `AKIA*` (AWS), `AIza*` (Google), Azure connection strings                    |
| Git platforms   | `ghp_*`, `gho_*`, `ghs_*` (GitHub), `GITHUB_TOKEN=`, `GH_TOKEN=`             |
| Communication   | `xox[bpsar]-*` (Slack)                                                       |
| Credentials     | `API_KEY=`, `password=`, `token=`                                            |
| Crypto/Auth     | `-----BEGIN PRIVATE KEY-----`, JWT (`eyJ...`)                                |
| Databases       | MongoDB connection strings                                                   |

> **Limitations:** The scanner is a first line of defense. It does not detect multi-line secrets, base64-encoded values, or variable indirection. For comprehensive scanning, use [GitLeaks](https://github.com/gitleaks/gitleaks), [TruffleHog](https://github.com/trufflesecurity/trufflehog), or the `/secret-scan` skill from [devsecops-ai-team](https://github.com/pitimon/devsecops-ai-team).

### Skills & Agent

| Component             | Usage                          | Purpose                                                 |
| --------------------- | ------------------------------ | ------------------------------------------------------- |
| `/governance-check`   | `/governance-check pre-commit` | Quick fitness function checklist — fast pass/fail       |
| `/create-adr`         | `/create-adr "Title"`          | Generate Architecture Decision Record                   |
| `/spec-driven-dev`    | `/spec-driven-dev`             | Spec-first development: define WHAT, AI implements HOW  |
| `/governance-setup`   | `/governance-setup`            | Initialize governance in any project                    |
| `governance-reviewer` | Auto-triggered                 | Deep multi-file compliance review with severity grading |

### Language Support

Governance checks are language-agnostic with specific rules per stack:

| Check        | JS/TS                 | Python                               | Go               | Rust             |
| ------------ | --------------------- | ------------------------------------ | ---------------- | ---------------- |
| Debug prints | `console.log`         | `print()`                            | `fmt.Println`    | `println!`       |
| Validation   | Zod, joi, yup         | pydantic, marshmallow                | go-validator     | serde, validator |
| Dangerous    | `eval()`, `innerHTML` | `eval()`, `exec()`, `pickle.loads()` | `unsafe.Pointer` | `unsafe` blocks  |
| Detection    | `package.json`        | `pyproject.toml`, `requirements.txt` | `go.mod`         | `Cargo.toml`     |

### Rules (Optional)

5 ready-to-use rules for `~/.claude/rules/`:

| Rule              | Focus                                   |
| ----------------- | --------------------------------------- |
| `governance.md`   | Fitness functions at every stage        |
| `coding-style.md` | Immutability, file size, error handling |
| `git-workflow.md` | Conventional commits, PR workflow       |
| `testing.md`      | TDD, 80% coverage minimum               |
| `security.md`     | No secrets, input validation, OWASP     |

```bash
# Install all rules (backs up existing files)
bash ~/.claude/plugins/marketplaces/claude-governance/scripts/install-rules.sh

# Governance rule only
bash ~/.claude/plugins/marketplaces/claude-governance/scripts/install-rules.sh --governance-only
```

---

## Core Concepts

### Three Loops Decision Model

Classify every task by AI autonomy level:

| Loop            | AI Role                          | Examples                                                 |
| --------------- | -------------------------------- | -------------------------------------------------------- |
| **Out-of-Loop** | AI executes, human reviews after | Formatting, lint, imports, simple bug fixes              |
| **On-the-Loop** | AI proposes, human approves      | Features, API changes, refactoring > 3 files             |
| **In-the-Loop** | Human decides, AI assists        | Architecture, security, breaking changes, data migration |

### Fitness Functions

Automated governance checks — "unit tests for architecture":

| Stage            | Checks                                                                                                                     |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------- |
| **Pre-Commit**   | No secrets, input validation, parameterized queries, file < 800 lines, functions < 50 lines, immutability, no debug prints |
| **Pre-PR**       | Conventional commits, DOMAIN.md updated, test coverage >= 80%, TODO context                                                |
| **Architecture** | Service boundaries, error message safety, auth coverage, rate limiting                                                     |

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

```mermaid
graph TB
    subgraph "Always-On"
        H1["SessionStart Hook<br/>Governance Context"]
        H2["PreToolUse Hook<br/>Secret Scanner"]
    end

    subgraph "On-Demand"
        C1["/governance-check<br/><i>quick checklist</i>"]
        C2["/create-adr"]
        S1["/spec-driven-dev"]
        S2["/governance-setup"]
        A1["governance-reviewer<br/><i>deep review</i>"]
    end

    subgraph "Configuration"
        R1["~/.claude/rules/"]
    end

    H1 -->|~300 tokens| SESSION["Every Session"]
    H2 -->|blocks secrets| WRITES["File Writes"]
    R1 -->|always loaded| SESSION
    C1 & A1 -->|on demand| CHECK["Compliance Report"]
```

---

## Token Budget

| Component            | Tokens   | When                        |
| -------------------- | -------- | --------------------------- |
| SessionStart hook    | ~300     | Every session               |
| Secret scanner       | 0        | Shell script, no token cost |
| Rules (if installed) | ~500-800 | Every session               |
| Skills / agent       | 0        | Only when invoked           |

**Total always-on cost:** ~300 tokens (without rules) / ~1,100 tokens (with rules)

---

## Project Structure

```
claude-governance/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata, skills path, keywords
│   └── marketplace.json         # Marketplace listing schema
├── hooks/
│   ├── hooks.json               # Hook registrations (SessionStart, PreToolUse)
│   ├── session-start.sh         # Governance context injection
│   └── secret-scanner.sh        # Secret pattern blocker (20 patterns)
├── skills/
│   ├── governance-check/SKILL.md  # Quick fitness function runner
│   ├── create-adr/SKILL.md       # ADR generator
│   ├── spec-driven-dev/SKILL.md   # Spec-first development workflow
│   └── governance-setup/SKILL.md  # Project initialization wizard
├── agents/
│   └── governance-reviewer.md   # Deep compliance review agent
├── examples/
│   ├── rules/                   # 5 rules for ~/.claude/rules/
│   ├── DOMAIN.md.example        # Domain model template
│   ├── adr-template.md          # ADR template with governance fields
│   └── project-claude-md.example
├── scripts/
│   ├── install-rules.sh         # Rules installer with backup
│   └── bump-version.sh          # Version sync across 3 files
├── docs/
│   └── adr/
│       └── ADR-001-adopt-governance-framework.md
├── tests/
│   └── validate-plugin.sh       # Structural integrity (48 checks)
├── .github/workflows/
│   └── validate.yml             # CI/CD pipeline
├── CHANGELOG.md
├── README.md
└── LICENSE
```

---

## Development

```bash
# Run structural validation (48 checks)
bash tests/validate-plugin.sh --skip-install-check

# Run with install verification
bash tests/validate-plugin.sh

# Bump version (updates plugin.json, marketplace.json, CHANGELOG.md)
bash scripts/bump-version.sh X.Y.Z
```

---

## Contributing

Areas where help is welcome:

- Fitness function examples for other tech stacks
- Language-specific secret patterns (Ruby, PHP, Java, C#)
- Translations (i18n for session-start context)
- Real-world case studies and governance templates

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## References

- **Fitness Functions** — _Building Evolutionary Architectures_ (Ford, Parsons, Kua — O'Reilly)
- **ADRs** — _Lightweight Architecture Decision Records_ (ThoughtWorks Technology Radar)
- **Spec-Driven Dev** — Derived from Design-by-Contract (Meyer, 1986)
- **Three Loops** — Human-AI interaction model for autonomous systems

---

## License

[MIT](LICENSE) — Copyright (c) 2026 pitimon
