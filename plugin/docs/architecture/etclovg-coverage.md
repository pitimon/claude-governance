# ETCLOVG Coverage Map — claude-governance

**Status**: Reference document (not an ADR — no decision change; scope-anchor only)
**Source taxonomy**: NotebookLM notebook `0f90fcee-b566-4a0b-919a-3df1aa7443cb` — "Agent Harness Engineering 202605" (48 sources, owner-curated, 2026-05-24).
**Plugin version at creation**: v3.3.3
**Maintained**: Updated in the same PR as any architecture decision that changes layer coverage. Next full re-evaluation: 2026-11-26 (6 months from creation, per ADR-016 drop-date discipline in sibling plugin `pitimon/8-habit-ai-dev`).

---

## Context

Agent-harness research (notebook cited above) defines the **ETCLOVG taxonomy** — a 7-layer breakdown of what wraps a model to turn it into a reliable autonomous agent:

> `Agent = Model + Harness`
> The model is the engine. The harness is everything that surrounds it (sandbox, tools, memory, lifecycle, observability, verification, governance) that turns reasoning into reliable autonomous action.

This document maps which of those 7 layers `claude-governance` covers today, which are out-of-scope by **charter**, and which are out-of-scope by **plugin boundary** (routed to a sibling plugin).

**This is not a roadmap.** Layers marked `None`, `OOS-charter`, or `OOS-plugin-boundary` are not commitments to add. Layers marked `Partial` are not commitments to fill. Per ADR-014 (in `8-habit-ai-dev`) friction-first doctrine, pattern attractiveness alone is not a shipping criterion.

---

## Per-layer coverage

| Layer                             | Description (from notebook)                                    | Status                | Evidence / Rationale                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| --------------------------------- | -------------------------------------------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **E** — Execution Environment     | Sandbox for safe code execution                                | `OOS-charter`         | Plugin charter: "Skills are read-only guidance — they tell Claude how to approach a task, they do not modify files themselves." Source: `pitimon/8-habit-ai-dev/CLAUDE.md` §50-67 + ADR-017 (in `8-habit-ai-dev`) Constraint C3. Charter amendment ADR required to re-evaluate.                                                                                                                                                                                                                                                                                                 |
| **T** — Tooling                   | MCP/A2A protocols for connecting tools                         | `OOS-plugin-boundary` | Plugin boundary (memory observation #233270): MCP server implementation belongs in sibling plugin `pitimon/devsecops-ai-team`. `claude-governance` is guidance, not protocol.                                                                                                                                                                                                                                                                                                                                                                                                   |
| **C** — Context & Memory          | Compaction, Progressive Disclosure, long-context management    | `Partial`             | `hooks/session-start.sh` injects ~360 tokens of governance context per session — not full skill content. Skills load on `/command` invocation, not pre-loaded into the context window. Both behaviors already match Progressive Disclosure. **Not yet covered**: Compaction (notebook §13-17) and Context Resets (Anthropic engineering blogs).                                                                                                                                                                                                                                 |
| **L** — Lifecycle & Orchestration | Single- and multi-agent task loops                             | `Partial`             | Three Loops decision model (`docs/adr/ADR-002-consequence-based-authorization.md`) classifies autonomy per task type with Consequence Override for irreversible operations. **Not yet covered**: formal multi-agent orchestration or Planner-Generator-Evaluator structural separation (notebook §27-30).                                                                                                                                                                                                                                                                       |
| **O** — Observability             | Tracing, log collection, agent-run evidence                    | `None`                | Not in scope today. No agent-run telemetry, no trace collection, no SLA metrics for governance checks. Sibling `pitimon/devsecops-ai-team` has scan-event history (SQLite) and `agent-health` skill — `claude-governance` does not yet trace its own use.                                                                                                                                                                                                                                                                                                                       |
| **V** — Verification              | Closed-loop test / evaluate before commit                      | `Partial`             | Pre-commit / pre-PR / architecture fitness functions (`skills/governance-check/SKILL.md` — 31 checks across 3 categories). `governance-reviewer` agent for deep multi-file review with severity grading. `tests/validate-plugin.sh` enforces structural integrity (79+ checks). **Not yet codified**: explicit "verify outcome via sandbox or test BEFORE allowing fix" gate — the _Verify Before You Fix_ pattern (notebook §31-32; arXiv source). Remains a candidate for future codification with ADR-014 friction-first applied.                                            |
| **G** — Governance & Security     | Permissions, oversight, decision authority, secrets discipline | `Strong`              | Primary focus of the plugin. (1) Three Loops decision model in ADR-002 with Consequence Override for irreversible ops. (2) `hooks/secret-scanner.sh` — 25 BLOCK patterns + 3 WARN patterns, ADR-006-compliant write-new vs edit-tracked discipline. (3) `governance-reviewer` agent — deep multi-file review with severity grading. (4) 31 governance checks across pre-commit / pre-PR / architecture categories. (5) Compliance mappings: EU AI Act (ADR-003), ISO/IEC 42001 (ADR-004), NIST AI RMF (ADR-005), OWASP DSGAI (`docs/compliance/DSGAI-MAPPING.md`, 11 controls). |

### Legend

- **Strong** — primary coverage; multiple artifacts; documented invariants
- **Partial** — coverage exists but incomplete relative to the layer's taxonomy definition
- **None** — no current coverage; eligible for future scope expansion if a friction signal surfaces
- **OOS-charter** — out of scope per the read-only-guidance principle; charter-amendment ADR required to re-evaluate
- **OOS-plugin-boundary** — out of scope because routed to a sibling plugin per the plugin boundary statement (memory observation #233270)

### Coverage summary

| Status              | Count | Layers  |
| ------------------- | ----: | ------- |
| Strong              |     1 | G       |
| Partial             |     3 | C, L, V |
| None                |     1 | O       |
| OOS-charter         |     1 | E       |
| OOS-plugin-boundary |     1 | T       |

---

## How to use this document

### For ADR authors

If a new ADR proposes scope expansion into a layer currently marked `OOS-charter`, `OOS-plugin-boundary`, or `None`, the ADR must:

1. Cite this map's current verdict for the affected layer.
2. Document the charter-amendment rationale (for `OOS-charter`), the plugin-boundary re-evaluation (for `OOS-plugin-boundary`), or the friction signal (for `None`).
3. Update this map in the same PR.

If a new ADR moves a layer from `Partial` toward `Strong` (e.g., adds a new artifact under an existing layer), update the Evidence column in the same PR.

### For contributors

A `Partial` layer is not an open invitation to fill. Friction-first doctrine applies (ADR-014 in `8-habit-ai-dev`): pattern attractiveness alone is not a shipping criterion. If you believe a `Partial` layer should be expanded, please cite a first-person friction case (issue, lesson, post-mortem) where the gap caused real cost.

### For adopters

This map tells you what this plugin is currently designed to govern (`G` strong) and what it does not attempt (`E`, `T` — by design). If your project needs sandboxing or MCP/tooling protocol enforcement, look at the sibling plugin `pitimon/devsecops-ai-team`, which covers complementary security-scan and supply-chain layers.

---

## Related external sources (selected from the notebook's 48)

These are the canonical external references for the ETCLOVG taxonomy and its component patterns. Verified existing at notebook curation time (2026-05-24); not re-verified per-link in this map — see notebook for source list with citation IDs.

- _Agent Harness Engineering: A Survey_ — Preprints.org / OpenReview (defines ETCLOVG taxonomy)
- _Agent Contracts: A Formal Framework_ — arXiv (7-tuple `C = (I, O, S, R, T, Φ, Ψ)`)
- _Observability-Driven Automatic Evolution of Coding-Agent Harnesses_ — arXiv (AHE / Meta-Harness)
- _Verify Before You Fix_ — arXiv (execution-grounding before code modification)
- Anthropic Engineering: _Building Effective Agents_, _Harness design for long-running application development_, _Scaling Managed Agents_
- `Awesome-Harness-Engineering` — GitHub catalog of harness-engineering tools and protocols

---

## Maintenance

- **Review trigger**: any new ADR that adds, expands, or changes architecture decisions affecting layer coverage updates this map in the same PR. This is recorded as a fitness-function-style expectation here, not enforced by a CI check.
- **README mirror sync**: a condensed copy of the per-layer verdict table is inlined in `README.md` § "Agent Harness Coverage (ETCLOVG)" (added v3.3.5, PR #44). **This document is the single source of truth** — any change to a layer's `Status` here MUST update the README table in the same PR, or the two drift (the doc-drift class PR #43 fixed in v3.3.5).
- **Drop date / next full re-evaluation**: **2026-11-26** (6 months from creation). At that point: if no layer status has shifted and no friction signal has arrived for any `Partial`/`None` layer, mark this map as "stable" and extend review interval. Otherwise refresh the Evidence column to reflect current state.
- **Source-snapshot dependency**: this map cites NotebookLM notebook `0f90fcee` as of 2026-05-24. If the notebook is re-curated and the ETCLOVG layer names or responsibilities drift, validate the per-layer rows against the new taxonomy before refreshing.
- **Charter alignment**: any move from `OOS-charter` to a non-OOS status requires a new ADR amending the read-only-guidance principle stated in `pitimon/8-habit-ai-dev/CLAUDE.md` §50-67.
