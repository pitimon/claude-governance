# ADR-008: governance-reviewer agent uses `model: inherit`

## Status

Accepted (2026-07-10). Resolves [#49](https://github.com/pitimon/claude-governance/issues/49).

## Context

The `governance-reviewer` agent (`agents/governance-reviewer.md`) was pinned to `model: sonnet`. Issue #49 asked whether it should move to Opus for deeper compliance review, since it checks cross-file domain invariants and architecture boundaries — reasoning-heavy work where a stronger model helps.

The agent's review process has two kinds of work:

- **Mechanical (steps 1–3):** regex secret scans, file/function size counts, debug-print greps, conventional-commit checks. Model tier is not the bottleneck here.
- **Judgment-heavy (steps 4–5):** cross-file domain-invariant verification and architecture-boundary analysis. This is where a stronger model earns its cost.

Three options were considered:

1. **Keep `sonnet`** — cheap, but weakens the judgment-heavy steps on every invocation.
2. **Hard-pin `opus`** — strongest review, but spends the *operator's* Opus budget on **every** invocation, including trivial single-file diffs. A governance plugin that unilaterally escalates its users' inference cost is itself a governance smell — cost/consequence tradeoffs belong to the operator, per this plugin's own Three Loops model (ADR-002).
3. **`inherit`** — the agent runs on the tier of the session that invokes it.

## Decision

Set `model: inherit` on the `governance-reviewer` agent.

The operator controls the tier by choosing the session they invoke it from: a release-gating review run from an Opus-tier session gets Opus for the judgment-heavy steps; a quick check stays cheap on whatever tier is already running. The agent body documents this ("for a release-gating review, invoke from an Opus-tier session").

This keeps the model-tier decision with the operator rather than the plugin forcing a premium tier — consistent with ADR-002 (consequence-based authorization: cost/consequence tradeoffs are the operator's call).

## Consequences

- Release-critical reviews and cheap spot-checks both get an appropriate tier without a config change.
- **Documented downside:** on a Haiku-tier session, the last-gate review runs on Haiku and is correspondingly weaker. Operators who need a hard floor for release gating must invoke from an Opus session (or fork a stronger session for the review). If a hard floor is ever required unconditionally, revisit this ADR — pinning `opus` is defensible, but it is a cost-policy decision and must be recorded as one.
- `model: inherit` is a Claude Code agent-frontmatter concept. Codex does not register plugin agents (its manifest is skills-only), so this change has no effect on Codex users.

## Governance

- **Decision Loop**: On-the-Loop — AI proposes the model policy; the human maintainer accepts it, and the operator chooses the invoking tier per review.
- **Fitness Function**: `grep '^model:' agents/governance-reviewer.md` returns `inherit`. Any future change back to a hard pin must cite a cost-policy rationale in a superseding ADR.
