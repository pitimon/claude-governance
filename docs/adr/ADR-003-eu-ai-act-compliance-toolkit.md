# ADR-003: EU AI Act Compliance Toolkit Migration from 8-habit-ai-dev

## Status

Accepted

## Date

2026-05-02

## Context

The EU AI Act compliance toolkit (`/eu-ai-act-check` skill, primary-source research, mapping guide) was originally built in `pitimon/8-habit-ai-dev` v2.3.0 via PRs #65-70 (April 2026). At the time, it was placed there because compliance reviews were modeled as "another step in the workflow."

Subsequent boundary review (memory observation #233270, 2026-04-07, "Both Recommended for Maximum Coverage") clarified that the two plugins are complementary by design:

- **`8-habit-ai-dev`** = workflow discipline (HOW to develop well — the 7-step Covey-derived process, /reflect, /calibrate)
- **`claude-governance`** = compliance enforcement + framework mappings (WHAT standards apply — DSGAI mapping, fitness functions, secret scanning, ADRs, Three Loops decision model)

Under that boundary, EU AI Act compliance is a **framework mapping** (Articles 9-15 → governance controls), not a workflow step. It belongs in this plugin alongside `docs/compliance/DSGAI-MAPPING.md`, not in the workflow plugin. The original placement was a boundary error.

Issue #21 tracked this migration as a planned correction. The cross-plugin handoff pattern (precedent: `guides/habit-nudges.md` specified in 8-habit, implemented in this plugin) made it a clean refactor: same maintainer, sequenced release.

## Decision

Migrate the EU AI Act compliance toolkit from `pitimon/8-habit-ai-dev` to `pitimon/claude-governance` v3.1.0:

1. **Move** the following files to this plugin (verbatim where the content is primary-source, surgical rewrite where the content references skills):
   - `skills/eu-ai-act-check/SKILL.md` + `reference.md` (rewrite skill references; drop Covey/habit framing)
   - `docs/research/eu-ai-act-obligations.md` (verbatim — primary-source verified Articles 9-15 quotes)
   - `guides/eu-ai-act-mapping.md` → `docs/compliance/EU-AI-ACT-MAPPING.md` (renamed to match `DSGAI-MAPPING.md` convention; rewrite skill names throughout)

2. **Cross-reference bidirectionally** with `docs/compliance/DSGAI-MAPPING.md`. EU AI Act Article 15 ¶5 names 5 AI-specific attack categories that align with DSGAI04 + DSGAI11 controls.

3. **Sequence the cross-plugin coordination**: ship v3.1.0 here first; then ship `pitimon/8-habit-ai-dev` v2.3.1 to delete the migrated files. Order matters — deleting in 8-habit before this plugin ships would leave a dangling reference.

4. **Preserve provenance**: this ADR + the v3.1.0 PR description explicitly link 8-habit PRs #65-70 + 8-habit's original ADR-005 + this plugin's issue #21 as the source chain.

5. **Drop Covey framing** rather than partial-rewrite. The source SKILL.md has `Habit: H1 + H8` markers, "Step 3 — Habit Checkpoint", and a Handoff section routing to 8-habit skills. Governance plugin doesn't use Covey framing — these get dropped, not rewritten. The 9-obligation checklist + scope pre-flight + verified quotes are the value being preserved.

## Consequences

### Positive

- Plugin boundary integrity restored — framework mappings live in the framework plugin
- Discoverability improves: `docs/compliance/` now contains both DSGAI and EU AI Act mappings, single browse location
- Bidirectional cross-references make Article 15 ¶5 ↔ DSGAI04/11 traceable for auditors
- Clearer install advice: "Install both plugins for full workflow + compliance" instead of "compliance lives in the workflow plugin"
- Reusable migration pattern established for any future cross-plugin moves (move + surgical rewrite, not redesign; drop framing that doesn't fit destination plugin's voice)

### Negative

- Cross-plugin documentation overhead: a brief window where the same content exists in both repos until 8-habit v2.3.1 ships
- Existing `pitimon/8-habit-ai-dev` users who invoke `/eu-ai-act-check` will need to install `pitimon/claude-governance` after v2.3.1 lands
- One ADR (this) + one mirror ADR in 8-habit (their ADR-006) document the same migration from two angles

### Risks

- **Order-of-merge risk**: if 8-habit v2.3.1 deletion ships before claude-governance v3.1.0, users on the latest 8-habit see a broken `/eu-ai-act-check` reference. Mitigation: explicit hard rule in plan + this ADR; same maintainer controls release timing
- **Drift risk**: future contributors might add EU AI Act content to 8-habit again without remembering the boundary. Mitigation: 8-habit's CLAUDE.md "Plugin Boundary" section already calls this out (added v2.3.0+Stage-A); this ADR adds a durable record on the receiving side

## Governance

- **Decision Loop**: In-the-Loop — extends the cross-plugin boundary contract; affects users of both plugins; regulatory framework decision
- **Fitness Function**: `tests/validate-plugin.sh` section 6 enforces presence of all 5 migrated/new files (SKILL.md, reference.md, research file, mapping file, this ADR) and tier-count integrity (≥25 MUST items)
- **Review Trigger**: When considering moving any framework-mapping content (SLSA, NIST, ISO, etc.) between this plugin and 8-habit-ai-dev, re-read this ADR for the boundary precedent

## Provenance

- **Source PRs (8-habit-ai-dev)**: pitimon/8-habit-ai-dev#65, #66, #67, #68, #69, #70 (all merged April 2026 in v2.3.0)
- **Source ADR**: pitimon/8-habit-ai-dev `docs/adr/ADR-005-eu-ai-act-compliance-toolkit.md`
- **Tracking issue**: pitimon/claude-governance#21
- **Memory observation**: #233270 (2026-04-07) — plugin boundary decision
- **Companion deletion ADR**: to be added in pitimon/8-habit-ai-dev v2.3.1 as ADR-006

## NOT LEGAL ADVICE

Reminder: the migrated `/eu-ai-act-check` skill is a developer-facing compliance reference, not legal counsel. The migration changes its location, not its legal status. The NOT LEGAL ADVICE disclaimer is preserved verbatim in all migrated files. EU AI Act enforcement begins 2 August 2026 (subject to Digital Omnibus harmonized standards conditionality).
