# ADR-007: Codex Native Packaging

## Status

Accepted

## Context

`claude-governance` started as a Claude Code plugin. Its core guidance is portable because skills are Markdown files, but part of the plugin is Claude Code-specific:

- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` are Claude Code manifests.
- `hooks/hooks.json`, `hooks/session-start.sh`, and `hooks/secret-scanner.sh` rely on Claude Code hook events.
- Codex expects `.codex-plugin/plugin.json` plus a marketplace file at `.agents/plugins/marketplace.json`.

The goal is to make the governance skills installable through `codex plugin add` without claiming that Claude Code hooks are active in Codex.

## Decision

Add native Codex packaging:

- `.codex-plugin/plugin.json` exposes the shared `./skills/` directory.
- `.agents/plugins/marketplace.json` publishes marketplace name `pitimon-claude-governance`.
- A root-level `plugin` symlink points to `.` because Codex marketplace entries require a child source path; `./plugin` is the stable child path.
- Codex package metadata describes the hook boundary explicitly: skills and docs are available, Claude Code hooks remain Claude-only.

## Consequences

Users can install the plugin in Codex:

```bash
codex plugin marketplace add pitimon/claude-governance
codex plugin add claude-governance@pitimon-claude-governance
```

If the marketplace was added before Codex packaging existed, users must refresh the snapshot first:

```bash
codex plugin marketplace upgrade pitimon-claude-governance
```

Codex users get the six governance skills:

- `governance-check`
- `create-adr`
- `spec-driven-dev`
- `governance-setup`
- `eu-ai-act-check`
- `iso-42001-check`

Codex users do not get automatic SessionStart context injection or PreToolUse secret scanning from this plugin. They should run `governance-check` and the compliance skills explicitly until Codex supports equivalent hook packaging.
