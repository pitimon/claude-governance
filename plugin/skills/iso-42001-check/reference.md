# ISO/IEC 42001:2023 Annex A — Full Control Checklist

Full Annex A reference. Loaded from `SKILL.md` during Step 1 when the user runs the actual compliance check. Every item cites the specific clause/sub-control identifier in ISO/IEC 42001:2023.

> **NOT A CERTIFICATION GUARANTEE** — this checklist is a developer-facing reference, not an auditor or certification body. Running the skill (or passing this checklist) does not constitute ISO/IEC 42001:2023 certification. Certification requires a third-party audit by an accredited body. ISO/IEC 42001 is voluntary, not regulatory.

> **Paywall notice** — ISO/IEC 42001:2023 is a paywalled standard (~CHF 174 from `iso.org/standard/81230.html`). Control titles below are **paraphrased** from secondary sources (ISMS.online + Cyberzoni, verified 2026-05-03); consult the standard for normative wording. **No verbatim ISO 42001 text appears in this plugin.**

> **AI system definition** — uses ISO/IEC 22989:2022 vocabulary for "AI system". Verify the 22989 clause cite from a current copy of that standard before publishing certification evidence.

## Tier vs Status: Orthogonal Axes

**Tier** = normative weight (deploy-blocker semantics). **Status** = whether this plugin enforces it. Any combination is valid:

|            | ENFORCED | EVIDENCE-ONLY | GAP |
| ---------- | -------- | ------------- | --- |
| **MUST**   | ✓        | ✓             | ⚠️  |
| **SHOULD** | ✓        | ✓             | ✓   |
| **COULD**  | ✓        | ✓             | ✓   |

`MUST + GAP` is a deploy-blocker — flagged prominently in `docs/compliance/ISO-42001-MAPPING.md`.

## Tier Heuristic

ISO/IEC 42001 itself does not designate normative weight as MUST/SHOULD/COULD. This plugin derives the heuristic:

| Tier       | Derivation                                                                                                                                                                                 |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **MUST**   | Foundational AIMS controls without which there is no management system (policy, roles, impact assessment, lifecycle objectives, V&V, intended use, third-party governance when applicable) |
| **SHOULD** | Expected of any documented AIMS — secondary requirements (operational records, monitoring procedures, supplier review cadence)                                                             |
| **COULD**  | Context-conditional: continuous-learning systems, large-scale compute, deployer-side-only controls, optional bias-impact assessment scopes                                                 |

> **A.10 (Third-Party Relationships) is conditionally MUST.** Marked MUST below assuming the modal plugin user uses third-party AI components (OpenAI, Anthropic, Hugging Face). Demote A.10 controls to COULD only when scope-pre-flight Q3 = "in-house models only".

## Clause A.2 — Policies Related to AI

**Mapped skills**: `examples/project-claude-md.example`, `docs/adr/ADR-001-adopt-governance-framework.md`, `governance-reviewer` agent

- [ ] **[MUST]** A.2.2 — AI policy is documented and approved by management
- [ ] **[SHOULD]** A.2.3 — AI policy aligned with other organisational policies
- [ ] **[SHOULD]** A.2.4 — AI policy reviewed at planned intervals or after significant changes

**Evidence file**: `docs/compliance/iso-42001/A2-policies/ai-policy.md`

## Clause A.3 — Internal Organization

**Mapped skills**: `agents/governance-reviewer.md`, `docs/adr/ADR-001-adopt-governance-framework.md`

- [ ] **[MUST]** A.3.2 — AI roles and responsibilities defined and assigned
- [ ] **[SHOULD]** A.3.3 — Process exists to report concerns about AI systems

**Evidence file**: `docs/compliance/iso-42001/A3-org/roles.md`

## Clause A.4 — Resources for AI Systems

**Mapped skills**: `/spec-driven-dev`, cross-ref `docs/compliance/DSGAI-MAPPING.md` (DSGAI04 supply chain, DSGAI07 data sourcing)

- [ ] **[MUST]** A.4.2 — AI system resources documented (data, tooling, system, computing, human)
- [ ] **[SHOULD]** A.4.3 — Data resources identified and documented per AI system
- [ ] **[COULD]** A.4.4 — Tooling resources identified (frameworks, libraries, dev environments)
- [ ] **[COULD]** A.4.5 — System and computing resources identified (capacity, scaling, cost)
- [ ] **[COULD]** A.4.6 — Human resources identified (skills, training, oversight roles)

**Evidence file**: `docs/compliance/iso-42001/A4-resources/resource-inventory.md`

## Clause A.5 — Assessing Impacts of AI Systems

**Mapped skills**: `/spec-driven-dev` (impact section), `governance-reviewer` agent

- [ ] **[MUST]** A.5.2 — AI system impact-assessment process defined and applied
- [ ] **[MUST]** A.5.3 — Impact assessments documented per AI system
- [ ] **[COULD]** A.5.4 — Impact on individuals/groups assessed (fundamental rights, fairness)
- [ ] **[COULD]** A.5.5 — Societal impacts assessed (environmental, economic, cultural)

**Evidence file**: `docs/compliance/iso-42001/A5-impacts/impact-assessment.md`

## Clause A.6 — AI System Life Cycle

**Mapped skills**: `/spec-driven-dev`, `/governance-check` (pre-pr: test coverage ≥80%), `/create-adr`, **External** for deployment/monitoring/event-logs (use `pitimon/8-habit-ai-dev`'s `/deploy-guide` and `/monitor-setup` plus runtime telemetry)

- [ ] **[MUST]** A.6.1.2 — Objectives for responsible AI development defined
- [ ] **[SHOULD]** A.6.1.3 — Processes for responsible AI design and development documented
- [ ] **[MUST]** A.6.2.2 — AI system requirements and specification documented
- [ ] **[SHOULD]** A.6.2.3 — AI system design and development decisions documented
- [ ] **[MUST]** A.6.2.4 — AI system verified and validated against requirements
- [ ] **[SHOULD]** A.6.2.5 — AI system deployment process defined
- [ ] **[SHOULD]** A.6.2.6 — AI system operation and monitoring procedures defined
- [ ] **[SHOULD]** A.6.2.7 — AI system technical documentation maintained through lifecycle
- [ ] **[COULD]** A.6.2.8 — Event logs recorded for AI system operation (runtime concern)

**Evidence file**: `docs/compliance/iso-42001/A6-lifecycle/lifecycle-records.md`

> 🔗 The Three Loops decision model (`docs/adr/ADR-002-consequence-based-authorization.md`) is one valid way to satisfy A.6.1.2 + A.6.2.5 (responsible development objectives + deployment governance). Three Loops terminology is from human-autonomy teaming literature (Endsley 1999, DARPA), NOT ISO/IEC 42001. Cite A.6 sub-control IDs in audit, not Three Loops labels.

## Clause A.7 — Data for AI Systems

**Mapped skills**: `governance-reviewer` agent, cross-ref `docs/compliance/DSGAI-MAPPING.md` (DSGAI04 supply chain, DSGAI07 data sourcing)

- [ ] **[SHOULD]** A.7.2 — Data for development and enhancement identified
- [ ] **[SHOULD]** A.7.3 — Data acquisition process documented
- [ ] **[MUST]** A.7.4 — Data quality criteria defined and verified for AI systems
- [ ] **[MUST]** A.7.5 — Data provenance documented (source, transformations, lineage)
- [ ] **[SHOULD]** A.7.6 — Data preparation methods documented (cleaning, normalisation, augmentation)

**Evidence file**: `docs/compliance/iso-42001/A7-data/data-governance.md`

> 🔗 OWASP DSGAI04 (Insecure AI Supply Chain) and DSGAI07 (Direct Prompt Injection / Data Sourcing Risks) operationalize A.7.4 and A.7.5 with concrete checks. See `docs/compliance/DSGAI-MAPPING.md` "ISO 42001 Cross-References" section.

## Clause A.8 — Information for Interested Parties of AI Systems

**Mapped skills**: `/spec-driven-dev`, **External** for incident communication (use `pitimon/8-habit-ai-dev`'s `/ai-dev-log` plus org incident response process)

- [ ] **[MUST]** A.8.2 — System documentation and information for users provided
- [ ] **[SHOULD]** A.8.3 — External reporting process defined (regulators, customers, public)
- [ ] **[SHOULD]** A.8.4 — Incident communication process defined
- [ ] **[SHOULD]** A.8.5 — Information for interested parties (deployers, end-users, affected persons) documented

**Evidence file**: `docs/compliance/iso-42001/A8-info/user-documentation.md`

## Clause A.9 — Use of AI Systems

**Mapped skills**: `/spec-driven-dev`, `docs/adr/ADR-002-consequence-based-authorization.md` (Three Loops), cross-ref `docs/compliance/DSGAI-MAPPING.md` (DSGAI19 Irreversible Operations)

- [ ] **[MUST]** A.9.2 — Processes for responsible AI system use defined
- [ ] **[MUST]** A.9.3 — Objectives for responsible use defined and aligned with intended purpose
- [ ] **[MUST]** A.9.4 — Intended use of the AI system documented and communicated

**Evidence file**: `docs/compliance/iso-42001/A9-use/responsible-use.md`

## Clause A.10 — Third-Party and Customer Relationships

**Tier note**: A.10 is **conditionally MUST** — promoted when scope-pre-flight Q3 = "uses third-party AI components" (OpenAI, Anthropic, Hugging Face, etc.). Demote to COULD only when "in-house models only". The defaults below assume the modal plugin user (third-party AI used).

**Mapped skills**: `/create-adr`, cross-ref `docs/compliance/DSGAI-MAPPING.md` (DSGAI04 Insecure AI Supply Chain, DSGAI03 Shadow AI)

- [ ] **[MUST]** A.10.2 — Responsibilities allocated between organisation and third parties
- [ ] **[MUST]** A.10.3 — Suppliers of AI components, data, or services managed (selection, evaluation, monitoring)
- [ ] **[MUST]** A.10.4 — Customer relationships managed (information provided, feedback collected, incidents handled)

**Evidence file**: `docs/compliance/iso-42001/A10-third-party/supplier-register.md`

## Related Standards (informative)

The following ISO/IEC standards complement 42001. **None are mapped to standalone skills in this plugin** — they appear here as informative pointers per ADR-004.

- **ISO/IEC 23894:2023 — AI risk management.** Companion to Clause A.5 (Assessing Impacts). Consult when expanding the impact-assessment process beyond A.5.2/A.5.3 baseline. Provides risk-treatment vocabulary aligned with ISO 31000.
- **ISO/IEC 5338:2023 — AI system life cycle processes.** Companion to Clause A.6 (Life Cycle). Consult when documenting AI-specific life-cycle activities (training, retraining, model retirement) beyond the A.6.2 baseline.
- **ISO/IEC 22989:2022 — AI vocabulary.** Terminology reference. Consult to anchor "AI system", "AI agent", "machine learning", and other vocabulary used across the 42001 family.
- **ISO/IEC 38507:2022 — Governance of AI for boards.** Companion to Clauses A.2 + A.3 (Policies, Internal Organization). Consult when scaling AIMS to board-level oversight.

If user demand emerges for standalone skills mapping any of the above, file an issue referencing ADR-004's Review Trigger.

## Tier Summary (for default-mode runners)

| Tier       | Item count | Default behavior                                                                                                                                      |
| ---------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **MUST**   | 17         | Always run; any FAIL = AIMS gap (deploy-blocker for certification users; review priority for self-attesters)                                          |
| **SHOULD** | 15         | Run with `--full`; FAIL = warning; required for full AIMS evidence base                                                                               |
| **COULD**  | 6          | Run with `--full` only if context applies (continuous-learning, fundamental-rights impact, large-scale compute)                                       |
| **Total**  | 38         | Per ISO/IEC 42001:2023 Annex A enumeration (verified 2026-05-03 via ISMS.online + Cyberzoni; primary source paywalled at iso.org/standard/81230.html) |

> **Verify counts**: `grep -c '^- \[ \] \*\*\[MUST\]\*\*' skills/iso-42001-check/reference.md`
> **Verify clause coverage**: `grep -c '^## Clause A\.' skills/iso-42001-check/reference.md` should return `9`.
