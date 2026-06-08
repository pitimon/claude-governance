# ISO/IEC 42001:2023 Compliance Mapping

> Maps `claude-governance` controls to [ISO/IEC 42001:2023](https://www.iso.org/standard/81230.html) AI Management System (AIMS) Annex A controls.
> Plugin version: v3.2.0 | Coverage: 38 Annex A sub-controls across 9 clauses (A.2-A.10)

> **NOT A CERTIFICATION GUARANTEE** — running this mapping does not constitute ISO/IEC 42001:2023 certification. Certification requires a third-party audit by an accredited certification body. ISO 42001 is voluntary, not regulatory.

> **Paywall notice** — ISO/IEC 42001:2023 control titles below are paraphrased from secondary sources (ISMS.online + Cyberzoni, verified 2026-05-03). Consult the standard for normative wording.

## Coverage Scorecard

```
ISO 42001 Annex A Coverage (38 controls across 9 clauses)
─────────────────────────────────────────────────────────
ENFORCED       : 12/38 (32%) — automated check exists in plugin
EVIDENCE-ONLY  : 20/38 (53%) — user must produce/maintain a record; plugin provides path + skill
GAP            :  6/38 (16%) — no current enforcement; cite external tool or future skill

MUST + GAP (deploy-blockers for certification): 0/17 ✓
```

**Tier × Status matrix** (modal user with third-party AI components):

|            | ENFORCED | EVIDENCE-ONLY | GAP | Total |
| ---------- | -------- | ------------- | --- | ----- |
| **MUST**   | 9        | 8             | 0   | 17    |
| **SHOULD** | 3        | 7             | 5   | 15    |
| **COULD**  | 0        | 5             | 1   | 6     |
| **Total**  | 12       | 20            | 6   | 38    |

## Per-Clause Status Tables

### A.2 — Policies Related to AI (3 controls)

| Control | Title                             | Tier   | Status        | Anchor                                                                                 | Evidence file                                        |
| ------- | --------------------------------- | ------ | ------------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| A.2.2   | AI policy documented and approved | MUST   | EVIDENCE-ONLY | `docs/adr/ADR-001-adopt-governance-framework.md`, `examples/project-claude-md.example` | `docs/compliance/iso-42001/A2-policies/ai-policy.md` |
| A.2.3   | Alignment with other org policies | SHOULD | EVIDENCE-ONLY | `docs/adr/ADR-001-adopt-governance-framework.md`                                       | same                                                 |
| A.2.4   | AI policy reviewed at intervals   | SHOULD | EVIDENCE-ONLY | `agents/governance-reviewer.md`                                                        | same                                                 |

### A.3 — Internal Organization (2 controls)

| Control | Title                         | Tier   | Status        | Anchor                                                                            | Evidence file                               |
| ------- | ----------------------------- | ------ | ------------- | --------------------------------------------------------------------------------- | ------------------------------------------- |
| A.3.2   | AI roles and responsibilities | MUST   | EVIDENCE-ONLY | `agents/governance-reviewer.md`, `docs/adr/ADR-001-adopt-governance-framework.md` | `docs/compliance/iso-42001/A3-org/roles.md` |
| A.3.3   | Reporting of concerns         | SHOULD | GAP           | External — security disclosure / responsible disclosure process                   | same                                        |

### A.4 — Resources for AI Systems (5 controls)

| Control | Title                          | Tier   | Status        | Anchor                                | Evidence file                                                  |
| ------- | ------------------------------ | ------ | ------------- | ------------------------------------- | -------------------------------------------------------------- |
| A.4.2   | Resource documentation         | MUST   | EVIDENCE-ONLY | `/spec-driven-dev`                    | `docs/compliance/iso-42001/A4-resources/resource-inventory.md` |
| A.4.3   | Data resources                 | SHOULD | EVIDENCE-ONLY | `/spec-driven-dev`, cross-ref DSGAI07 | same                                                           |
| A.4.4   | Tooling resources              | COULD  | EVIDENCE-ONLY | `/spec-driven-dev`                    | same                                                           |
| A.4.5   | System and computing resources | COULD  | EVIDENCE-ONLY | `/spec-driven-dev`                    | same                                                           |
| A.4.6   | Human resources                | COULD  | EVIDENCE-ONLY | `/spec-driven-dev`                    | same                                                           |

### A.5 — Assessing Impacts of AI Systems (4 controls)

| Control | Title                         | Tier  | Status        | Anchor                              | Evidence file                                               |
| ------- | ----------------------------- | ----- | ------------- | ----------------------------------- | ----------------------------------------------------------- |
| A.5.2   | Impact assessment process     | MUST  | ENFORCED      | `/spec-driven-dev` (impact section) | `docs/compliance/iso-42001/A5-impacts/impact-assessment.md` |
| A.5.3   | Impact assessments documented | MUST  | ENFORCED      | `/spec-driven-dev`, `/create-adr`   | same                                                        |
| A.5.4   | Impact on individuals/groups  | COULD | EVIDENCE-ONLY | `agents/governance-reviewer.md`     | same                                                        |
| A.5.5   | Societal impacts              | COULD | EVIDENCE-ONLY | `agents/governance-reviewer.md`     | same                                                        |

### A.6 — AI System Life Cycle (9 controls)

| Control | Title                                       | Tier   | Status   | Anchor                                                | Evidence file                                                 |
| ------- | ------------------------------------------- | ------ | -------- | ----------------------------------------------------- | ------------------------------------------------------------- |
| A.6.1.2 | Objectives for responsible development      | MUST   | ENFORCED | `/spec-driven-dev`                                    | `docs/compliance/iso-42001/A6-lifecycle/lifecycle-records.md` |
| A.6.1.3 | Processes for responsible AI design         | SHOULD | ENFORCED | `/spec-driven-dev`, `agents/governance-reviewer.md`   | same                                                          |
| A.6.2.2 | AI system requirements & specification      | MUST   | ENFORCED | `/spec-driven-dev`                                    | same                                                          |
| A.6.2.3 | Design and development decisions documented | SHOULD | ENFORCED | `/create-adr`, `/spec-driven-dev`                     | same                                                          |
| A.6.2.4 | Verification and validation                 | MUST   | ENFORCED | `/governance-check` (pre-pr: test coverage ≥80%)      | same                                                          |
| A.6.2.5 | AI system deployment process                | SHOULD | GAP      | External — `pitimon/8-habit-ai-dev` `/deploy-guide`   | same                                                          |
| A.6.2.6 | Operation and monitoring procedures         | SHOULD | GAP      | External — `pitimon/8-habit-ai-dev` `/monitor-setup`  | same                                                          |
| A.6.2.7 | Technical documentation maintained          | SHOULD | ENFORCED | `/create-adr`                                         | same                                                          |
| A.6.2.8 | Event logs recorded                         | COULD  | GAP      | External — runtime telemetry (Datadog, OpenTelemetry) | same                                                          |

### A.7 — Data for AI Systems (5 controls)

| Control | Title                                | Tier   | Status        | Anchor                                             | Evidence file                                          |
| ------- | ------------------------------------ | ------ | ------------- | -------------------------------------------------- | ------------------------------------------------------ |
| A.7.2   | Data for development and enhancement | SHOULD | EVIDENCE-ONLY | `/spec-driven-dev`, cross-ref DSGAI07              | `docs/compliance/iso-42001/A7-data/data-governance.md` |
| A.7.3   | Acquisition of data                  | SHOULD | EVIDENCE-ONLY | cross-ref DSGAI07                                  | same                                                   |
| A.7.4   | Quality of data                      | MUST   | EVIDENCE-ONLY | `agents/governance-reviewer.md`, cross-ref DSGAI04 | same                                                   |
| A.7.5   | Data provenance                      | MUST   | EVIDENCE-ONLY | cross-ref DSGAI04                                  | same                                                   |
| A.7.6   | Data preparation                     | SHOULD | EVIDENCE-ONLY | `agents/governance-reviewer.md`                    | same                                                   |

### A.8 — Information for Interested Parties (4 controls)

| Control | Title                                          | Tier   | Status        | Anchor                                            | Evidence file                                             |
| ------- | ---------------------------------------------- | ------ | ------------- | ------------------------------------------------- | --------------------------------------------------------- |
| A.8.2   | System documentation and information for users | MUST   | ENFORCED      | `/spec-driven-dev`                                | `docs/compliance/iso-42001/A8-info/user-documentation.md` |
| A.8.3   | External reporting process                     | SHOULD | GAP           | External — `pitimon/8-habit-ai-dev` `/ai-dev-log` | same                                                      |
| A.8.4   | Incident communication                         | SHOULD | GAP           | External — org incident response process          | same                                                      |
| A.8.5   | Information for interested parties             | SHOULD | EVIDENCE-ONLY | `/spec-driven-dev`                                | same                                                      |

### A.9 — Use of AI Systems (3 controls)

| Control | Title                          | Tier | Status   | Anchor                                                                                  | Evidence file                                         |
| ------- | ------------------------------ | ---- | -------- | --------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| A.9.2   | Processes for responsible use  | MUST | ENFORCED | `/spec-driven-dev`, `docs/adr/ADR-002-consequence-based-authorization.md` (Three Loops) | `docs/compliance/iso-42001/A9-use/responsible-use.md` |
| A.9.3   | Objectives for responsible use | MUST | ENFORCED | `/spec-driven-dev`                                                                      | same                                                  |
| A.9.4   | Intended use                   | MUST | ENFORCED | `/spec-driven-dev`                                                                      | same                                                  |

### A.10 — Third-Party and Customer Relationships (3 controls)

> **Tier note**: A.10 is conditionally MUST. Marked MUST below assuming modal plugin user uses third-party AI components. Demote to COULD only when scope-pre-flight Q3 = "in-house models only".

| Control | Title                       | Tier | Status        | Anchor                           | Evidence file                                                    |
| ------- | --------------------------- | ---- | ------------- | -------------------------------- | ---------------------------------------------------------------- |
| A.10.2  | Allocating responsibilities | MUST | EVIDENCE-ONLY | `/create-adr`                    | `docs/compliance/iso-42001/A10-third-party/supplier-register.md` |
| A.10.3  | Suppliers                   | MUST | EVIDENCE-ONLY | cross-ref DSGAI04 (supply chain) | same                                                             |
| A.10.4  | Customers                   | MUST | EVIDENCE-ONLY | `/create-adr`                    | same                                                             |

## Remaining Gaps

| Control | Tier   | Title                    | Status | Mitigation                                                                          |
| ------- | ------ | ------------------------ | ------ | ----------------------------------------------------------------------------------- |
| A.3.3   | SHOULD | Reporting of concerns    | GAP    | Document responsible-disclosure process at org level (SECURITY.md, security@ inbox) |
| A.6.2.5 | SHOULD | AI system deployment     | GAP    | Use `pitimon/8-habit-ai-dev` `/deploy-guide` for staging-first deploy discipline    |
| A.6.2.6 | SHOULD | Operation and monitoring | GAP    | Use `pitimon/8-habit-ai-dev` `/monitor-setup` for observability and drift detection |
| A.6.2.8 | COULD  | Event logs               | GAP    | Runtime telemetry (Datadog, OpenTelemetry, ELK); not a code-pattern concern         |
| A.8.3   | SHOULD | External reporting       | GAP    | Use `pitimon/8-habit-ai-dev` `/ai-dev-log` for AI development transparency log      |
| A.8.4   | SHOULD | Incident communication   | GAP    | Org incident response runbook (typically lives outside any single plugin)           |

**Zero MUST controls in GAP status** — all foundational AIMS controls are at minimum EVIDENCE-ONLY (plugin provides path + skill that produces the evidence).

## Standards Family (informative)

The following ISO/IEC standards complement 42001. **None are mapped to standalone skills in this plugin** — they appear here as informative pointers per ADR-004. If user demand emerges for a standalone mapping, file an issue referencing ADR-004's Review Trigger.

- **ISO/IEC 23894:2023 — AI risk management.** Companion to Clause A.5 (Assessing Impacts). Provides risk-treatment vocabulary aligned with ISO 31000. Consult when:
  - Expanding the impact-assessment process (A.5.2/A.5.3) beyond a single document
  - Building a risk register that needs ISO 31000 integration with non-AI organisational risks
  - Mapping AI risks to enterprise risk frameworks (COSO ERM)

- **ISO/IEC 5338:2023 — AI system life cycle processes.** Companion to Clause A.6 (Life Cycle). Builds on ISO/IEC/IEEE 15288 (system life-cycle processes) with AI-specific activities. Consult when:
  - Documenting AI-specific life-cycle activities (training, retraining, model retirement) beyond the A.6.2 baseline
  - Aligning AI life cycle with existing 15288-based engineering processes
  - Defining hand-offs between data science and engineering teams

- **ISO/IEC 22989:2022 — AI vocabulary.** Terminology reference. Consult to anchor "AI system", "AI agent", "machine learning", and other vocabulary. Cited at the top of `reference.md` to define "AI system" for the scope-check.

- **ISO/IEC 38507:2022 — Governance of AI for boards.** Companion to Clauses A.2 + A.3 (Policies, Internal Organization). Consult when:
  - Scaling AIMS to board-level oversight
  - Defining the relationship between management (42001 A.3) and board governance
  - Enterprise organizations with mature governance frameworks

## End-to-End Example: Mid-Sized SaaS Pursuing AIMS Self-Attestation

A 50-person SaaS company uses OpenAI's API for an AI-powered customer support feature. CEO wants to publish an AIMS self-attestation to bid on enterprise deals. Posture: **self-attestation** + **uses third-party AI components** → A.10 stays MUST.

**Workflow** (using both plugins):

1. **Run scope pre-flight**: `/iso-42001-check --scope` → confirm AI system per ISO 22989, posture = self-attestation, AI sourcing = third-party.

2. **Tier 1 sweep (17 MUST controls)**:
   - A.2.2 → write `docs/compliance/iso-42001/A2-policies/ai-policy.md` referencing ADR-001 + project CLAUDE.md
   - A.3.2 → document AI roles in `docs/compliance/iso-42001/A3-org/roles.md` (CTO accountable, eng lead operational)
   - A.5.2 + A.5.3 → run `/spec-driven-dev` for the AI feature; spec.md impact section satisfies both
   - A.6.1.2, A.6.2.2 → `/spec-driven-dev` requirements section
   - A.6.2.4 → `/governance-check pre-pr` confirms test coverage ≥80%
   - A.7.4 + A.7.5 → since this is an OpenAI passthrough (no training data): document data flow + redaction in `data-governance.md`; cross-ref DSGAI04 for supply chain
   - A.8.2 → `/spec-driven-dev` user-facing docs section
   - A.9.2 + A.9.3 + A.9.4 → `/spec-driven-dev` intended-use + Three Loops decision model
   - A.10.2 + A.10.3 + A.10.4 → `/create-adr` for OpenAI vendor selection + monitoring + customer-data flow boundaries

3. **Run `/iso-42001-check`** with default mode → generate report. MUST findings PASS = 17/17 ✓ → publish self-attestation.

4. **Tier 2 sweep (with `--full`)** when an enterprise customer asks for deeper evidence → produce remaining 15 SHOULD records. The 6 GAP items are addressed via 8-habit (`/deploy-guide`, `/monitor-setup`, `/ai-dev-log`) plus org-level incident response.

5. **`/reflect` after first cycle** → capture which controls produced friction; iterate.

This pattern produces an AIMS evidence package in roughly 2-3 weeks for a small team, vs months of from-scratch effort.

## EU AI Act Cross-References

ISO 42001 Annex A and EU AI Act Articles 9-15 substantially overlap (both address AI governance), but with different framings: 42001 = management system controls, EU AI Act = legal obligations for high-risk systems. Use this table for bidirectional traceability when generating evidence for both frameworks:

| EU AI Act Article                      | ISO 42001 Annex A clause                                                  | Notes                                                                                                                               |
| -------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Article 9 (Risk Management)            | A.5 (Assessing Impacts)                                                   | Both require systematic impact / risk assessment process. EU AI Act adds residual-risk acceptability + post-market monitoring loop. |
| Article 10 (Data Governance)           | A.7 (Data for AI Systems)                                                 | Direct overlap. EU AI Act ¶3 ("relevant, sufficiently representative") aligns with A.7.4 (Data Quality).                            |
| Article 11 (Technical Documentation)   | A.6.2.7 (Technical Documentation) + A.6.2.3 (Design Documentation)        | Both require lifecycle-maintained technical docs. EU AI Act Annex IV provides explicit content list.                                |
| Article 12 (Record-Keeping)            | A.6.2.8 (Event Logs)                                                      | Both runtime concerns. Use external tooling (telemetry platforms).                                                                  |
| Article 13 (Transparency to Deployers) | A.8.2 (System Documentation) + A.8.5 (Information for Interested Parties) | Direct overlap on user-facing instructions for use.                                                                                 |
| Article 14 (Human Oversight)           | A.9.2 (Processes for Responsible Use)                                     | Three Loops decision model (ADR-002) satisfies both.                                                                                |
| Article 15 ¶1-3 (Accuracy, Robustness) | A.6.2.4 (V&V) + A.6.2.6 (Operation and Monitoring)                        | EU AI Act adds explicit metrics declaration in Art. 13 ¶3(b)(ii).                                                                   |
| Article 15 ¶5 (Cybersecurity)          | A.7.4 (Data Quality) + A.10.3 (Suppliers) + DSGAI controls                | Cross-walks to DSGAI04, DSGAI11 — see DSGAI cross-references below.                                                                 |

See `docs/compliance/EU-AI-ACT-MAPPING.md` for the full Article-to-skill mapping. This bidirectional cross-walk lets a team reuse evidence: a single `data-governance.md` satisfies Article 10 + A.7.4 + A.7.5 + DSGAI04.

## DSGAI Cross-References

OWASP DSGAI controls operationalize several ISO 42001 controls with concrete code-level checks:

| ISO 42001 Annex A                     | DSGAI control                              | Plugin reference                                       |
| ------------------------------------- | ------------------------------------------ | ------------------------------------------------------ |
| A.4.3 (Data resources)                | DSGAI07 (Data Governance & Classification) | `examples/DATA-CLASSIFICATION.md.example`              |
| A.4.4 (Tooling resources)             | DSGAI03 (Shadow AI)                        | `examples/shadow-ai-policy.md`                         |
| A.7.2 (Data for development)          | DSGAI07                                    | `examples/DATA-CLASSIFICATION.md.example`              |
| A.7.4 (Data quality)                  | DSGAI04 (Data, Model & Artifact Poisoning) | `skills/governance-check/SKILL.md` (pre-commit #10-12) |
| A.7.5 (Data provenance)               | DSGAI04                                    | same                                                   |
| A.9.2 (Processes for responsible use) | DSGAI19 (Human-in-the-Loop)                | `docs/adr/ADR-002-consequence-based-authorization.md`  |
| A.10.3 (Suppliers)                    | DSGAI04 (supply chain)                     | `examples/ai-supply-chain-checklist.md`                |

See `docs/compliance/DSGAI-MAPPING.md` "ISO 42001 Cross-References" section for the bidirectional pointer back from DSGAI to 42001.

## NIST AI RMF Cross-References

NIST AI RMF 1.0 functions overlap substantially with ISO 42001 Annex A clauses per the official Microsoft-authored crosswalk hosted on the NIST AI Resource Center (`https://airc.nist.gov/docs/NIST_AI_RMF_to_ISO_IEC_42001_Crosswalk.pdf`). Use this table for evidence reuse when bridging NIST RMF artifacts to ISO 42001 audit packages:

| NIST Function | ISO 42001 Annex A clause(s) |
|---------------|------------------------------|
| **GOVERN**    | A.2 (Policies), A.3 (Internal Org), A.10 (Third-Party) |
| **MAP**       | A.5 (Assessing Impacts), A.7 (Data) |
| **MEASURE**   | A.6.2.4 (V&V), A.6.2.6 (Operation/Monitoring) |
| **MANAGE**    | A.6.2.5 (Deployment), A.8 (Information for Interested Parties), A.9 (Use) |

See `docs/compliance/NIST-AI-RMF-MAPPING.md` for the canonical 3-way table (NIST function vs ISO 42001 clause vs EU AI Act article), the cited Microsoft-authored crosswalk PDF SHA-256 verification snippet, and the EU AI Act gap list. ADR-005 documents why NIST AI RMF lands as a cross-reference doc rather than a standalone skill.

## Complementary Tools

- **`pitimon/8-habit-ai-dev`** plugin: `/deploy-guide` (A.6.2.5), `/monitor-setup` (A.6.2.6), `/ai-dev-log` (A.8.3), `/review-ai` (A.6.2.4 augmentation)
- **`pitimon/devsecops-ai-team`** plugin: `/aibom-generate` (AI bill of materials for A.4.2 + A.10.3), `/eu-ai-act-assess` (Article 10 ↔ A.7), `/threat-model` (A.5 augmentation)
- **Runtime telemetry**: Datadog, OpenTelemetry, ELK (A.6.2.8 event logs)
- **Org-level documents** (outside any plugin): SECURITY.md (A.3.3 reporting concerns), incident response runbook (A.8.4), customer agreements (A.10.4)
