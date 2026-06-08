# ADR-002: Extend Three Loops with Consequence-Based Authorization

## Status

Accepted

## Date

2026-03-24

## Context

The Three Loops Decision Model classifies tasks by AI autonomy level based on **task type**:

- Out-of-Loop: formatting, lint fixes, simple bugs
- On-the-Loop: features, API changes, refactoring
- In-the-Loop: architecture, security, breaking changes

However, task type alone is insufficient for safe authorization. A formatting change applied to a production deployment config has fundamentally different consequences than formatting a test file — yet both would be classified as "Out-of-Loop" under the original model.

OWASP DSGAI06 (Tool, Plugin & Agent Data Exchange Risks) introduces "consequence-based authorization": read-only operations proceed with standard auth, reversible writes proceed with logging, and irreversible operations require human approval. DSGAI19 (Human-in-the-Loop & Labeler Overexposure) reinforces that human oversight must be proportional to potential harm.

The Three Loops model needs a second dimension: **blast radius**.

## Decision

Extend the Three Loops model with a consequence dimension that classifies operations by their reversibility and blast radius:

| Consequence Level | Description                                      | Examples                                                                  |
| ----------------- | ------------------------------------------------ | ------------------------------------------------------------------------- |
| **Reversible**    | Can be auto-reverted with no lasting impact      | Formatting, lint fixes, local file edits                                  |
| **Contained**     | Affects a single service, user, or scope         | Feature branch changes, test environment deploys                          |
| **Broad**         | Affects multiple services, users, or data stores | Shared library changes, staging deploys, schema migrations                |
| **Irreversible**  | Cannot be undone; data loss or external impact   | Production deploy, data deletion, credential rotation, public API changes |

**Override rule**: Irreversible operations are **always In-the-Loop** regardless of task type. A "simple" formatting fix that triggers a production deployment pipeline requires human approval.

The extended model becomes a 2D matrix:

```
                    Task Type
                    Out-of-Loop    On-the-Loop    In-the-Loop
Consequence
  Reversible        autonomous      propose         human-driven
  Contained         autonomous      propose         human-driven
  Broad             propose         propose         human-driven
  Irreversible      HUMAN-DRIVEN    HUMAN-DRIVEN    human-driven
```

## Consequences

### Positive

- Prevents catastrophic autonomous actions where task type alone would allow autonomy
- Aligns with OWASP DSGAI06 consequence-based authorization and DSGAI19 HITL requirements
- Simple mental model: "Can I undo this? If not → In-the-Loop"

### Negative

- Slight overhead in classification — developers must assess both task type AND consequence
- May slow down legitimate autonomous workflows for irreversible but low-risk operations

### Risks

- Over-classification (everything marked irreversible) could create bottlenecks — mitigate with clear examples
- Under-classification of indirect irreversibility (e.g., a config change that triggers an irreversible pipeline)

## Governance

- **Decision Loop**: In-the-Loop — This extends the fundamental decision framework
- **Fitness Function**: Architecture check for irreversible operation safeguards (confirmation gates, dry-run modes)
- **Review Trigger**: When adding new deployment pipelines, destructive operations, or external-facing changes
