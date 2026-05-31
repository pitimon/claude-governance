# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**claude-governance** is a Claude Code and Codex plugin that provides governance skills for AI-assisted development. It has no build system — it consists of declarative config files, Markdown skills, Claude Code shell-based hooks, and example templates.

Install: `claude plugin marketplace add pitimon/claude-governance`
Codex install: `codex plugin marketplace add pitimon/claude-governance && codex plugin add claude-governance@pitimon-claude-governance`

## Repository Structure

```
.claude-plugin/
  plugin.json            # Plugin metadata (name, version, author, skills, keywords)
  marketplace.json       # Marketplace listing schema
.codex-plugin/
  plugin.json            # Codex plugin metadata (skills only; hooks are Claude Code-specific)
.agents/plugins/
  marketplace.json       # Codex marketplace listing schema
plugin -> .              # Codex marketplace child source path
hooks/
  hooks.json             # Hook registrations (SessionStart, PreToolUse)
  session-start.sh       # Governance context injection (~300 tokens per session)
  secret-scanner.sh      # Blocks file writes containing hardcoded secrets
skills/
  spec-driven-dev/SKILL.md    # /spec-driven-dev — spec-first development workflow
  governance-check/SKILL.md   # /governance-check — fitness function runner
  create-adr/SKILL.md         # /create-adr — ADR generator
  governance-setup/SKILL.md   # /governance-setup — project initialization wizard
agents/
  governance-reviewer.md # Compliance review agent (auto-triggered)
examples/
  rules/                 # 5 rules for ~/.claude/rules/ (governance, coding-style, git-workflow, testing, security)
  DOMAIN.md.example      # Template for project domain models
  adr-template.md        # ADR template with governance loop field
  project-claude-md.example  # Example CLAUDE.md with governance sections
scripts/
  install-rules.sh       # Installs rules to ~/.claude/rules/ with backup
tests/
  validate-plugin.sh     # Structural integrity validation (99 PASS + 1 SKIP)
.github/workflows/
  validate.yml           # CI/CD — runs validate-plugin.sh on push/PR
```

## Key Concepts

### Three Loops Decision Model

Every task is classified by AI autonomy level:

- **Out-of-Loop**: AI executes autonomously (formatting, lint fixes)
- **On-the-Loop**: AI proposes, human approves (features, API changes)
- **In-the-Loop**: Human drives, AI assists (architecture, security, breaking changes)

### Governance Fitness Functions

Four-stage automated checks (defined in `examples/rules/governance.md`):

1. **Pre-implementation**: Spec exists, domain impact assessed, autonomy classified
2. **Pre-commit**: No secrets, input validated, files <800 lines, functions <50 lines
3. **Pre-PR**: Conventional commits, 80%+ test coverage, DOMAIN.md current
4. **Architecture**: Service boundaries, rate limiting, auth on endpoints

### Spec-Driven Development (`/spec-driven-dev`)

Five-phase workflow defined in `skills/spec-driven-dev/SKILL.md`:
Understand → Specify (write `spec.md`) → Plan → Implement → Verify

## How to Add a New Skill

1. Create `skills/<skill-name>/SKILL.md`
2. Include YAML frontmatter with `name`, `description`, `user-invocable: true`, and `allowed-tools`
3. The `description` field controls when the skill is auto-invoked — write it as trigger conditions
4. Skill body is Markdown that Claude follows as instructions when the skill is invoked

## How to Add a New Example Template

Place Markdown templates in `examples/`. Update the README.md file structure section to document the new file.

## Plugin Config

- `.claude-plugin/plugin.json`: Must have `name`, `version`, `description`, `author`, `repository`, `license`, `skills`, `keywords`
- `.claude-plugin/marketplace.json`: Follows `https://anthropic.com/claude-code/marketplace.schema.json` — lists plugins with `source` pointing to the plugin root
- `.codex-plugin/plugin.json`: Codex manifest. Keep `skills: "./skills/"`; do not add Claude Code `hooks` here.
- `.agents/plugins/marketplace.json`: Codex marketplace. Keep marketplace name `pitimon-claude-governance` and plugin source path `./plugin`.

## Validation

Run `bash tests/validate-plugin.sh --skip-install-check` to verify plugin structure integrity. The script checks JSON validity, cross-file naming consistency, Claude and Codex manifests, file integrity, hooks, examples, agents, compliance references, and keyword coverage.
