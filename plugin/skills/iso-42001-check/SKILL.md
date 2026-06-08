---
name: iso-42001-check
description: ISO/IEC 42001:2023 AI Management System (AIMS) compliance checklist — 38 controls across 9 Annex A clauses (A.2-A.10). Use BEFORE certification audit, customer compliance request, or major AIMS review. Mode-selection scope-check supports certification, self-attestation, internal-alignment, and customer-requirement postures.
user-invocable: true
argument-hint: "[component to check, --scope for pre-flight, --full for all tiers]"
allowed-tools: ["Read", "Glob", "Grep", "Bash"]
---

# ISO/IEC 42001 AIMS Compliance Check (38 Annex A Controls)

**Standard**: ISO/IEC 42001:2023 — Information technology — Artificial intelligence — Management system
**Status**: Voluntary, certifiable. Not regulatory.
**Anti-pattern**: Discovering AIMS gaps during the certification audit instead of months before.

> ⚠️ **NOT A CERTIFICATION GUARANTEE.** This skill produces a developer-facing AIMS readiness checklist. Certification requires a third-party audit by an accredited certification body. The skill helps surface gaps and prepare evidence — nothing more.

> **Paywall notice**: ISO/IEC 42001:2023 is paywalled (~CHF 174 from `iso.org/standard/81230.html`). Control titles in `reference.md` are paraphrased from secondary sources; consult the standard for normative wording.

> **Companion plugin**: For the 7-step development workflow that produces AIMS-shaped evidence as a side effect, install [`pitimon/8-habit-ai-dev`](https://github.com/pitimon/8-habit-ai-dev) alongside this plugin. The two plugins are complementary by design.

## When to Use

- Before a third-party ISO 42001 certification audit
- After an enterprise customer asks for ISO 42001 readiness evidence
- During architecture design of a new AI system (apply A.5 + A.6 controls early)
- After significant changes to AI policy, data governance, or third-party AI dependencies
- For periodic AIMS self-attestation (quarterly / annually)

## When to Skip

- Project does **not produce/deploy/operate an AI system** (per ISO/IEC 22989 vocabulary) — skip entirely
- Already covered by a recent (<90 day) `/iso-42001-check` run with no material AIMS changes since
- Pursuing a different AI governance framework (e.g., NIST AI RMF only) — though cross-walks may exist

## Process

### Step 0 — Scope Pre-Flight (--scope flag)

Mode selection (not binary skip — ISO 42001 is voluntary):

```
SCOPE CHECK (ISO/IEC 42001:2023 AIMS)
─────────────────────────────────────────────────
1. Does this project produce, deploy, or operate an AI system (per ISO/IEC 22989)?
   - [ ] Yes → continue
   - [ ] No → STOP, document in `docs/compliance/iso-42001/scope-decision.md`

2. Org posture (pick exactly one):
   - [ ] certification          (3rd-party audit; --full sweep is the default)
   - [ ] self-attestation       (Tier 1 default; --full for Tier 2)
   - [ ] internal-alignment     (Tier 1 default)
   - [ ] customer-requirement   (Tier 1 default; expand on customer ask)

3. AI component sourcing (drives A.10 tier — see reference.md):
   - [ ] uses third-party AI components (OpenAI, Anthropic, Hugging Face, etc.) → A.10 stays MUST
   - [ ] in-house models only → A.10 demoted to COULD
```

Document the chosen mode + AI sourcing answer in `docs/compliance/iso-42001/scope-decision.md` so the next run can re-confirm.

### Step 1 — Tiered Annex A Checklist

To prevent checklist fatigue, items are grouped into 3 tiers. **Default mode runs Tier 1 (MUST) only**. Use `--full` to include Tier 2 + 3.

| Tier       | Meaning                                                                                   | Action               | Default?                    |
| ---------- | ----------------------------------------------------------------------------------------- | -------------------- | --------------------------- |
| **MUST**   | Foundational AIMS controls without which there is no management system                    | Hard fail = AIMS gap | ✅ Default (all postures)   |
| **SHOULD** | Expected of any documented AIMS — secondary requirements                                  | Soft warning         | `--full` (or certification) |
| **COULD**  | Context-conditional (continuous-learning, fundamental-rights impact, large-scale compute) | Info only            | `--full`                    |

**Tier vs Status are orthogonal.** Tier expresses normative weight; Status (ENFORCED / EVIDENCE-ONLY / GAP) expresses whether this plugin enforces the control. See the 3×3 matrix at the top of `reference.md`.

For each item, mark Pass / Fail / N/A with 1-line evidence. Items are tagged inline with **[MUST]** / **[SHOULD]** / **[COULD]** so a default-mode runner can filter to MUST only.

**Annex A counts**: 17 MUST, 15 SHOULD, 6 COULD = 38 total across 9 clauses (A.2-A.10). Verified 2026-05-03; the full checklist with sub-control IDs, mapped skills, and evidence file paths is in the reference file.

Load `${CLAUDE_PLUGIN_ROOT}/skills/iso-42001-check/reference.md` for the full Annex A checklist.

### Step 2 — Generate Report

```
## ISO/IEC 42001 AIMS Compliance Report
**Date**: YYYY-MM-DD
**System**: [name]
**Posture**: certification / self-attestation / internal-alignment / customer-requirement
**Third-party AI**: yes / no
**Overall**: [X/9 clauses PASS, Y/9 PARTIAL, Z/9 FAIL]

| Clause | Title | Controls | Status | Evidence | Gaps |
|--------|-------|----------|--------|----------|------|
| A.2 | Policies Related to AI | 3 | PASS | ai-policy.md | — |
| A.3 | Internal Organization | 2 | PARTIAL | roles.md | A.3.3 reporting process undefined |
| A.4 | Resources for AI Systems | 5 | PASS | resource-inventory.md | — |
| A.5 | Assessing Impacts | 4 | PARTIAL | impact-assessment.md | A.5.4 individuals/groups not assessed |
| A.6 | AI System Life Cycle | 9 | PASS | lifecycle-records.md | — |
| A.7 | Data for AI Systems | 5 | PASS | data-governance.md | — |
| A.8 | Information for Interested Parties | 4 | PASS | user-documentation.md | — |
| A.9 | Use of AI Systems | 3 | PASS | responsible-use.md | — |
| A.10 | Third-Party Relationships | 3 | FAIL | supplier-register.md | A.10.3 no supplier evaluation cadence |

### MUST + GAP (deploy-blockers for certification)
- [list of MUST items where Status = GAP]

### Critical Gaps
- [list of FAIL items]

### Recommended Next Actions
- [actionable items mapped to governance skills or external runtime concerns]
```

Save to `docs/compliance/iso-42001/reports/YYYY-MM-DD-<system>.md` **in the user's project repository** (not in this plugin). Create the folder once via `mkdir -p docs/compliance/iso-42001/reports` if it doesn't exist.

### Step 3 — Conscience Check

> "Have I built an actual AI Management System, or just produced a checklist for the auditor?"
> "Do I understand WHY ISO 42001 exists (responsible AI governance at organizational scale), not just WHAT to evidence?"
> "If our AI system caused harm tomorrow, would these controls have prevented it — or just documented it?"

## Handoff

- **Expects from predecessor**: A defined AI system with documented intended purpose and at least one round of `/spec-driven-dev`
- **Produces for successor**: Compliance report + gap list. Failures route back to:
  - `/spec-driven-dev` for documentation gaps (A.5, A.6, A.8, A.9)
  - `/governance-check` for V&V and process gaps (A.6.2.4 test coverage)
  - `/create-adr` for policy + decision gaps (A.2, A.10)
  - `governance-reviewer` agent for deep multi-file audit (A.5, A.7)
  - **External** (use `pitimon/8-habit-ai-dev`'s `/deploy-guide`, `/monitor-setup`, `/ai-dev-log`) for runtime concerns: deployment (A.6.2.5), operation/monitoring (A.6.2.6), event logs (A.6.2.8), incident communication (A.8.4)

## Definition of Done

- [ ] Scope pre-flight completed; posture + AI sourcing documented in `scope-decision.md`
- [ ] All 38 Annex A controls checked with Pass/Fail/N-A + 1-line evidence (or 17 MUST in default mode)
- [ ] MUST + GAP items identified explicitly (deploy-blockers for certification)
- [ ] Critical gaps mapped to remediation route (governance skill or external)
- [ ] Report saved under `docs/compliance/iso-42001/reports/` in the user's project repo
- [ ] Conscience Check questions answered honestly
- [ ] (For certification audit) Auditor engagement scheduled with evidence package ready

## References

- Annex A reference: `${CLAUDE_PLUGIN_ROOT}/skills/iso-42001-check/reference.md` (38 controls with paraphrased titles, tier tags, evidence paths)
- User-facing mapping: `${CLAUDE_PLUGIN_ROOT}/docs/compliance/ISO-42001-MAPPING.md` (coverage scorecard, gap analysis, Standards Family, end-to-end example)
- Framework selection rationale: `${CLAUDE_PLUGIN_ROOT}/docs/adr/ADR-004-iso-42001-framework-selection.md` (why 42001 first; why 23894/5338/22989 are informative cross-refs only)
- DSGAI cross-reference: `${CLAUDE_PLUGIN_ROOT}/docs/compliance/DSGAI-MAPPING.md` (DSGAI04 ↔ A.7.4/A.7.5/A.10.3, DSGAI19 ↔ A.9.x, DSGAI03 ↔ A.4.x)
- EU AI Act cross-reference: `${CLAUDE_PLUGIN_ROOT}/docs/compliance/EU-AI-ACT-MAPPING.md` (Art. 10 ↔ A.5/A.7, Art. 11 ↔ A.6, Art. 14 ↔ A.9)

> ⚠️ **NOT A CERTIFICATION GUARANTEE.** This skill is a developer reference. The 38-control checklist is derived from secondary sources of ISO/IEC 42001:2023 Annex A; consult the paywalled standard for normative wording. ISO 42001 certification requires a third-party audit by an accredited certification body — passing this checklist is not certification.
