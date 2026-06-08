# Plugin Integration

`claude-governance` provides **policy and enforcement** (fitness functions,
ADRs, Three Loops, compliance frameworks). It works **fully standalone** —
no dependency on companion plugins.

For projects that combine this plugin with `8-habit-ai-dev` (workflow) and/or
`devsecops-ai-team` (tooling), see the canonical integration guide:

→ **[github.com/pitimon/8-habit-ai-dev — docs/INTEGRATION.md](https://github.com/pitimon/8-habit-ai-dev/blob/main/docs/INTEGRATION.md)**

## Things specific to this plugin worth noting

- **Three Loops canonical source**: This plugin defines Three Loops in
  `CLAUDE.md`, extended by **[ADR-002: Consequence-Based Authorization](adr/ADR-002-consequence-based-authorization.md)**
  with a 4-level blast-radius dimension (Reversible / Contained / Broad /
  Irreversible). `devsecops-ai-team` adopts the same Out/On/In-of-Loop
  vocabulary but does not mirror the ADR-002 extension.
- **EU AI Act canonical**: `/eu-ai-act-check` is the canonical
  implementation, received per **[ADR-003: EU AI Act Compliance Toolkit
  Migration from 8-habit-ai-dev](adr/ADR-003-eu-ai-act-compliance-toolkit.md)**.
  `8-habit-ai-dev` provides a stub redirect per its ADR-012 (migrated
  2026-05-02).
- **`/governance-check` vs scanner tools**: This plugin's fitness functions
  are pre-commit policy gates. They complement (do not replace)
  `devsecops-ai-team`'s tool-based scans (`/sast-scan`, `/secret-scan`,
  `/sca-scan`).

## Tested versions

- `claude-governance` 3.3.0
- `8-habit-ai-dev` 2.15.0
- `devsecops-ai-team` 10.10.0

## Related

- Canonical integration doc: https://github.com/pitimon/8-habit-ai-dev/blob/main/docs/INTEGRATION.md
- Tracking issue: [pitimon/claude-governance#31](https://github.com/pitimon/claude-governance/issues/31)
- Canonical issue: [pitimon/8-habit-ai-dev#170](https://github.com/pitimon/8-habit-ai-dev/issues/170)
