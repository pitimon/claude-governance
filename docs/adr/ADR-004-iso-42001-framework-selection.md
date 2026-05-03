# ADR-004: ISO/IEC 42001 Selected First Among the ISO AI Standards Family

## Status

Accepted

## Date

2026-05-03

## Context

The ISO/IEC AI standards family contains five complementary documents, each addressing a different governance concern:

- **ISO/IEC 42001:2023** — AI Management System (AIMS), the certifiable umbrella standard
- **ISO/IEC 23894:2023** — AI risk management guidance
- **ISO/IEC 5338:2023** — AI system life cycle processes
- **ISO/IEC 22989:2022** — AI vocabulary and terminology
- **ISO/IEC 38507:2022** — Governance implications of AI for boards

Issue #27 asked for ISO compliance mapping after the EU AI Act toolkit (ADR-003, v3.1.0) and DSGAI mapping (#14, v3.0.0) shipped. Two questions had to be answered before authoring:

1. **Which standard first?** All five are relevant; shipping all at once would dilute review and produce a sprawling skill catalogue.
2. **Standalone skill or informative reference?** Standalone skills add maintenance burden; informative references add discoverability without commitment.

Demand signal driving the timing: organizations with EU AI Act exposure are increasingly asked by enterprise customers and auditors for ISO 42001 certification readiness as a complementary, internationally recognized AIMS evidence base. ISO 42001 is the only **certifiable management-system standard** in the family — the others are companions to it.

## Decision

Add **ISO/IEC 42001:2023** as a first-class compliance toolkit in `pitimon/claude-governance` v3.2.0:

1. **Ship four artifacts** mirroring the EU AI Act toolkit shape:
   - `skills/iso-42001-check/SKILL.md` — orchestrator (mode-selection scope-check, tiered checklist, report)
   - `skills/iso-42001-check/reference.md` — 9 H2 sections (Clauses A.2-A.10), 38 sub-controls with tier tags, paywall disclaimer, 3×3 (Tier × Status) matrix
   - `docs/compliance/ISO-42001-MAPPING.md` — coverage scorecard, per-clause status tables, gap analysis, Standards Family section, EU AI Act + DSGAI cross-references
   - This ADR

2. **ISO 23894 / 5338 / 22989 ride as informative cross-references**, not standalone skills. They appear in two places:
   - `skills/iso-42001-check/reference.md` end — short "Related Standards (informative)" — 3-4 lines each, what 42001 clause each extends, explicit "NOT a separate skill in this plugin"
   - `docs/compliance/ISO-42001-MAPPING.md` mid-doc — longer "Standards Family" section, one paragraph per standard

3. **Tier (MUST/SHOULD/COULD) and Status (ENFORCED/EVIDENCE-ONLY/GAP) are orthogonal axes.** Tier expresses normative weight (deploy-blocker semantics, mirroring EU AI Act); Status expresses whether this plugin enforces it. Conflating them pollutes the signal — e.g., A.2.2 (AI Policy) is `MUST + EVIDENCE-ONLY` (foundational but no automation possible); A.6.2.4 (V&V) is `MUST + ENFORCED` (foundational AND we check it via test coverage).

4. **A.10 (Third-Party Relationships) is conditionally MUST.** Promoted to MUST when scope-pre-flight Q3 = "uses third-party AI components" (modal user — OpenAI/Anthropic/Hugging Face). Stays COULD only when "in-house models only".

5. **No `docs/research/iso-42001-controls.md` analogue ships.** ISO 42001 is paywalled (~CHF 174); the EU AI Act precedent shipped a research doc with verbatim Official Journal quotes — that is not legal here. Control intent is paraphrased; clause codes are cited.

6. **Disclaimer is "NOT A CERTIFICATION GUARANTEE"**, not "NOT LEGAL ADVICE" — ISO 42001 is voluntary, not regulatory. The disclaimer reflects that the plugin is a developer-facing reference, not an auditor.

## Consequences

### Positive

- Single skill matches the certifiable artifact a customer/auditor will ask for; informative cross-refs to 23894/5338/22989 mean no plugin sprawl
- Coverage scorecard + per-clause status tables make it easy to see where the plugin already enforces vs where the user must produce evidence
- Bidirectional cross-references (DSGAI ↔ ISO 42001, EU AI Act ↔ ISO 42001) help users navigate the framework family and reuse evidence
- Tier vs Status orthogonality avoids the trap of marking a control as "weaker" just because the plugin happens not to enforce it
- A.10 conditional-MUST mechanism reflects how AI is actually built today (mostly third-party model APIs)
- Reusable pattern: future ISO standards (27001, 23894 standalone if demand emerges) inherit the paywall-aware shape

### Negative

- Users who want pure risk-management (23894 only, no AIMS) get redirected through 42001 framing
- Paywall constraint forces paraphrasing — readers cannot verify wording without buying the standard
- Tier allocation (MUST/SHOULD/COULD) is plugin-author judgment since ISO 42001 itself doesn't designate normative weight; reviewers must audit the heuristic at top of `reference.md`
- One more compliance doc to keep current when ISO 42001 is amended

### Risks

- **Standard revision**: ISO 42001 Amd 1 (anticipated) could shift control numbering. Mitigation: structural validator gates (every clause has ≥1 MUST + MUST items reference ≥5 distinct skills) catch breakage faster than numeric count gates would.
- **Tier drift**: future contributors may quietly re-tier controls to lower the bar. Mitigation: validator structural gates + heuristic table at top of `reference.md` make changes visible in PR review.
- **Cross-plugin drift**: if `pitimon/8-habit-ai-dev` adds an ISO 42001 redirect stub later (parallel to the existing `/eu-ai-act-check` stub), this ADR is the source of truth — that stub must point back here.
- **Tier-allocation circularity if validator gates were numeric**: rejected during planning. The validator does not check "MUST count ≥ N" because the implementer would just pick a smaller N. Structural gates are load-bearing.

## Governance

- **Decision Loop**: **On-the-Loop** — additive toolkit; users not pursuing 42001 ignore the skill; not foundational like ADR-001/002, no cross-plugin coordination like ADR-003. Author proposes, maintainer approves at PR review.
- **Fitness Function**: `tests/validate-plugin.sh` section 3.12 enforces **structural gates** (not numeric counts):
  1. Files exist: `skills/iso-42001-check/SKILL.md`, `skills/iso-42001-check/reference.md`, `docs/compliance/ISO-42001-MAPPING.md`, this ADR
  2. `reference.md` has 9 clause headings (A.2 through A.10)
  3. Every clause has ≥1 `**[MUST]**` item (no clause is all-SHOULD/COULD)
  4. MUST items collectively cite ≥5 distinct existing skills/checks (proves cross-references are real, not orphaned text)
  5. `NOT A CERTIFICATION GUARANTEE` disclaimer present in SKILL.md, reference.md, and mapping doc
  6. `docs/compliance/DSGAI-MAPPING.md` has new `## ISO 42001 Cross-References` section
- **Review Trigger**: re-open this decision when any of:
  1. User demand for a standalone `/iso-23894-check` or `/iso-5338-check` (currently informative cross-refs only)
  2. ISO/IEC 42001 Amd 1 (or a 42001:202X revision) is published — re-verify Annex A enumeration and tier allocations
  3. A regulator (EU AI Act harmonized standards process, NIST AI RMF) formally cross-walks to 42001 — the cross-walk may shift which controls are MUST in regulated contexts

## Provenance

- **Tracking issue**: pitimon/claude-governance#27
- **Annex A enumeration sources** (paywall fallback): ISMS.online (full sub-control list, verified 2026-05-03), Cyberzoni (cross-verification on A.2-A.5 + A.7-A.10). Primary source `iso.org/standard/81230.html` returned 403 during verification; BSI public listing did not include full Annex A.
- **Verified counts**: 38 sub-controls across 9 clauses (A.2=3, A.3=2, A.4=5, A.5=4, A.6=9, A.7=5, A.8=4, A.9=3, A.10=3). Note: A.6 has sub-clause structure (A.6.1.x + A.6.2.x); one secondary source counted A.6 as 8 due to hierarchy interpretation.
- **Plan file**: `/Users/itarun/.claude/plans/read-https-github-com-pitimon-claude-gov-golden-gosling.md`
- **Memory observation**: #82340 (2026-05-03) — DSGAI mapping structure, ADR patterns, governance check inventory cataloged for ISO 42001 adaptation
- **Related ADRs**: ADR-001 (governance framework), ADR-002 (consequence-based authorization, Three Loops), ADR-003 (EU AI Act compliance toolkit migration — establishes the compliance-toolkit shape this ADR mirrors)

## NOT A CERTIFICATION GUARANTEE

Reminder: the `/iso-42001-check` skill is a developer-facing compliance reference, not an auditor or certification body. Running the skill (or passing its checklist) does not constitute ISO/IEC 42001:2023 certification. Certification requires a third-party audit by an accredited certification body. ISO/IEC 42001:2023 is voluntary, not regulatory; this skill helps surface gaps and prepare evidence, nothing more.
