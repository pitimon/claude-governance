<div align="center">

# claude-governance

**Keep AI-written code legible, safe, and accountable — from the first keystroke to the pull request.**

A governance layer for Claude Code and Codex. Zero dependencies, zero build steps.

</div>

---

## The problem it targets

AI writes code fast. The failures rarely come from bad code — they come from *ungoverned* code:

- A secret gets written straight into a file, then into git.
- An agent runs an irreversible action — a production deploy, a data delete — that no human approved.
- An architecture decision gets made, and six weeks later nobody remembers who chose it or why.
- A team runs five different AI tools with no shared policy on what's allowed.

None of these is a model problem. They are *structure* problems — missing guardrails, missing approval gates, missing records. `claude-governance` adds that structure, and it does so without a runtime, a build step, or a single dependency: everything is Markdown skills, shell/PowerShell hooks, and declarative config.

---

## Two ways in

**You just want the guardrails.** Install in Claude Code. From the next session on, every `Edit`/`Write` is scanned for secrets before it touches disk, and each task is framed by the Three Loops model.

```bash
claude plugin marketplace add pitimon/claude-governance
claude plugin install claude-governance@claude-governance
```

**You're setting up a project or a team.** Run `/governance-setup` to lay down a domain model, an ADR log, a data-classification template, a shadow-AI policy, and (optionally) the shared rule set.

```bash
# Optional: install the rule set into ~/.claude/rules/
bash ~/.claude/plugins/marketplaces/claude-governance/scripts/install-rules.sh
```

**On Codex** the skills and docs install the same way; hooks do not run there, so you invoke the checks explicitly.

```bash
codex plugin marketplace add pitimon/claude-governance
codex plugin add claude-governance@pitimon-claude-governance
```

---

## The whole thing on one page

```
                      Claude Code / Codex session
                                 │
        ┌────────────────────────┼────────────────────────┐
        ▼                        ▼                         ▼
   Always-On hooks          On-demand skills           Config
   (Claude Code only)       (both runtimes)            (if installed)
        │                        │                         │
  SessionStart:            /governance-check          ~/.claude/rules/
   Three Loops +           /create-adr                 5 rule files
   Consequence             /spec-driven-dev
   (~360 tokens)           /governance-setup           examples/
                           /eu-ai-act-check             templates
  PreToolUse:              /iso-42001-check
   Secret scanner          governance-reviewer agent
   25 BLOCK + 3 WARN
   blocks file writes
```

---

## How it works — Three Loops + Consequence

Every task is classified on two axes: **who drives** (Three Loops) and **how bad it is if it goes wrong** (consequence).

- **Out-of-Loop** — AI acts autonomously: formatting, lint, simple fixes.
- **On-the-Loop** — AI proposes, human approves: features, API changes.
- **In-the-Loop** — human drives, AI assists: architecture, security, breaking changes.

**The override that matters:** any *irreversible* operation — production deploy, data deletion, credential rotation — is **always In-the-Loop**, even when the task itself is trivial. "Format the config and push to prod" is a formatting task with an irreversible tail, so the human decides. See [ADR-002](docs/adr/ADR-002-consequence-based-authorization.md).

---

## Design principles

1. **Zero dependencies.** Markdown, shell, and config. Nothing to install, build, or keep patched.
2. **Deny-by-default on secrets.** The scanner blocks a write before it reaches disk — it doesn't warn after the fact.
3. **Consequence over capability.** Autonomy is granted by blast radius, not by how simple the task looks. Irreversible always stops for a human.
4. **Friction-first.** The plugin expands only when a real case — an issue, a lesson, a post-mortem — demands it. Attractiveness is not a shipping criterion.
5. **A standard, not a lock-in.** The same plain-Markdown governance runs in Claude Code and Codex. Pair it with sibling plugins or run it entirely on its own.
6. **Governance is the whole job.** This plugin does one layer — `G` for Governance — deeply, and points elsewhere for the rest (see coverage below).

---

## What it ships

- **2 hooks** — governance-context injection + secret scanner (25 BLOCK / 3 WARN patterns).
- **6 skills** — `/governance-check`, `/create-adr`, `/spec-driven-dev`, `/governance-setup`, `/eu-ai-act-check`, `/iso-42001-check`.
- **1 agent** — `governance-reviewer`, a deep multi-file review with severity grading.
- **31 governance checks** across pre-commit, pre-PR, and architecture stages, language-aware for JS/TS, Python, Go, and Rust.
- **4 compliance mappings** — OWASP DSGAI (11 controls), EU AI Act (Arts 9-15), ISO/IEC 42001:2023, NIST AI RMF 1.0.
- **Ready-to-use templates** — data classification, shadow-AI policy, MCP-security checklist, AI supply-chain checklist, DOMAIN and ADR templates.

**Go deeper:**

- **[docs/reference.md](docs/reference.md)** — worked usage examples plus the full feature reference: every hook, skill, check, template, rule, platform note, and the token budget.
- **Compliance** — [DSGAI](docs/compliance/DSGAI-MAPPING.md) · [EU AI Act](docs/compliance/EU-AI-ACT-MAPPING.md) · [ISO 42001](docs/compliance/ISO-42001-MAPPING.md) · [NIST AI RMF](docs/compliance/NIST-AI-RMF-MAPPING.md).
- **[Agent-harness coverage (ETCLOVG)](docs/architecture/etclovg-coverage.md)** — where this plugin is strong (`G`), partial (`C/L/V`), and deliberately out of scope (`E/T`). Adopter shorthand: use `claude-governance` for governance; pair with [`pitimon/devsecops-ai-team`](https://github.com/pitimon/devsecops-ai-team) for sandboxing (`E`) or MCP tooling (`T`).

---

## Standards vs. examples

What the plugin *enforces* — the hooks and the 31 checks — is fixed and versioned. What it *offers* — the templates and rules — is a starting point you copy and edit for your project. Don't confuse the two: the guardrails are the product; the templates are scaffolding.

---

## Companion plugins

`claude-governance` works **fully standalone**. For teams that also use `8-habit-ai-dev` (workflow method) and/or `devsecops-ai-team` (operational tooling), the canonical integration guide lives in `8-habit-ai-dev` to avoid drift — see the local stub at **[docs/INTEGRATION.md](docs/INTEGRATION.md)**. Tested against `8-habit-ai-dev` 2.21.42 and `devsecops-ai-team` 10.15.0.

---

## Contributing

Help is welcome on: fitness-function examples for other stacks (Ruby, PHP, Java, C#), language-specific secret/PII patterns, session-context translations, real-world governance templates, and OWASP DSGAI Tier-3 controls (DSGAI05, DSGAI12, DSGAI13). See [CHANGELOG.md](CHANGELOG.md) for version history and [docs/reference.md](docs/reference.md#development) for the local test commands.

---

## License

[MIT](LICENSE) — Copyright (c) 2026 pitimon.

> กติกาที่ดีไม่ได้ทำให้คนเก่งขึ้น — แต่ทำให้ระบบไม่พังลง แม้ในวันที่คนพลาด.
>
> *Good rules don't make people smarter — they keep the system from breaking on the day someone slips.*
