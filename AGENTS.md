# Agents working on claude-governance

This is your install + operating protocol. Claude Code reads `./CLAUDE.md` automatically. Codex and other agents should start here.

## What this is

`claude-governance` is a governance plugin for AI-assisted development. It ships Markdown skills, shell hooks for Claude Code, examples, ADRs, and compliance references. The Codex package exposes the skills and repository guidance; Claude Code-specific hooks remain Claude-only until Codex supports equivalent plugin hooks.

## Install

- **Claude Code**: `claude plugin marketplace add pitimon/claude-governance && claude plugin install claude-governance@claude-governance`
- **Codex**: `codex plugin marketplace add pitimon/claude-governance && codex plugin add claude-governance@pitimon-claude-governance`
- **Codex refresh if already added**: `codex plugin marketplace upgrade pitimon-claude-governance`

## Read this order

1. `./AGENTS.md` - cross-agent install and operating protocol.
2. `./CLAUDE.md` - architecture reference and Claude Code-specific hook behavior.
3. `./README.md` - user-facing overview, workflows, and project structure.
4. The relevant `skills/<name>/SKILL.md` for the user's request.

## Trust boundary

Skills are guidance that an agent executes under the user's authority. Claude Code hooks provide local enforcement for Claude Code only. In Codex, use the skills as explicit checklists and workflows; do not assume `hooks/session-start.sh` or `hooks/secret-scanner.sh` are automatically active. Note that Codex still _parses_ `hooks/hooks.json` at install with a strict schema (top level = `hooks` only — see issue #51), so that file must stay schema-pure even though Codex does not run the hooks.

## Common tasks

- **"Check this before commit"** -> `skills/governance-check/SKILL.md`
- **"Record why we chose this architecture"** -> `skills/create-adr/SKILL.md`
- **"Plan this feature before coding"** -> `skills/spec-driven-dev/SKILL.md`
- **"Set up governance in this repo"** -> `skills/governance-setup/SKILL.md`
- **"Check EU AI Act readiness"** -> `skills/eu-ai-act-check/SKILL.md`
- **"Check ISO 42001 readiness"** -> `skills/iso-42001-check/SKILL.md`
