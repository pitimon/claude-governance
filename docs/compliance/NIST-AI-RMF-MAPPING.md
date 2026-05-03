# NIST AI RMF 1.0 Cross-Reference Mapping

> Maps NIST AI Risk Management Framework 1.0 (NIST.AI.100-1) to claude-governance compliance toolkits — ISO/IEC 42001:2023 + EU AI Act + OWASP DSGAI.
> Plugin version: v3.3.0 | Coverage: cross-reference doc (NOT a standalone audit checklist — see ADR-005)

> **NOT A CERTIFICATION GUARANTEE** — this document is a developer-facing navigation aid for bridging existing ISO 42001 / EU AI Act evidence to US procurement contexts (EO 14110-driven). It is **not** an attestation of NIST AI RMF compliance, **not** a substitute for FedRAMP / NIST SP 800-53 processes, and **not** a certification path. NIST AI RMF 1.0 is voluntary US federal guidance.

> **Why this is a cross-reference doc, not a skill** — see ADR-005. NIST AI RMF has no third-party audit/certification path that requires a per-control checklist; its value is bridging existing evidence to US procurement contexts. A standalone `/nist-ai-rmf-check` skill is deferred to demand signal per the ADR-004 demand-first pattern.

## Authoritative Sources

- **NIST AI RMF 1.0 DOI** (permanent anchor): `https://doi.org/10.6028/NIST.AI.100-1` — released 2023-01-26, voluntary, freely accessible
- **NIST AI 600-1 (Generative AI Profile)**: `https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf` — official NIST companion published 2024-07-26, addresses 12 GenAI-specific risks
- **NIST AI Resource Center**: `https://airc.nist.gov/airmf-resources/` — Playbook (PDF/CSV/Excel/JSON formats), 13 community + NIST-authored crosswalks

## Canonical NIST → ISO 42001 Crosswalk (Microsoft-authored)

The official mapping from NIST AI RMF functions/categories/subcategories to ISO/IEC 42001:2023 clauses is published as a Microsoft-authored crosswalk hosted on the NIST AI Resource Center:

```
URL:    https://airc.nist.gov/docs/NIST_AI_RMF_to_ISO_IEC_42001_Crosswalk.pdf
Author: Gregory Montgomery (Microsoft)
Format: 16 pages, Excel-origin PDF
SHA-256 (captured 2026-05-03): 170efdf7be08a988213b54fb8293f3ea67f0627aff6f0541052dfbb0744afed3

# Verify the cited PDF has not drifted:
curl -sL https://airc.nist.gov/docs/NIST_AI_RMF_to_ISO_IEC_42001_Crosswalk.pdf | sha256sum
# Expected first 64 hex chars: 170efdf7be08a988213b54fb8293f3ea67f0627aff6f0541052dfbb0744afed3
```

This document does **not** re-derive the 70+ subcategory mappings from the Microsoft crosswalk. For per-subcategory NIST↔ISO 42001 detail, consult the canonical PDF above. This document provides a 4-row function-level summary plus a NIST↔EU AI Act overlap analysis (which the Microsoft crosswalk does not cover).

## 3-Way Function Mapping

| NIST Function | ISO 42001 Annex A clause(s) | EU AI Act Article(s) | Notes |
|---------------|------------------------------|----------------------|-------|
| **GOVERN** (6 categories, 19 subcategories) | A.2 (Policies), A.3 (Internal Org), A.10 (Third-Party) | Art. 16, 17, 26(6), 4 | Org-level; spans policy, accountability, supplier governance. NIST GOVERN.6 (third-party software/data risks) maps directly to ISO A.10 + EU AI Act Art. 16 (provider obligations). |
| **MAP** | A.5 (Assessing Impacts), A.7 (Data) | Art. 6, 9(1), Annex III, 10, 14, 13, 9(2), 27 | Risk + impact + data-context identification. NIST MAP overlaps EU AI Act Art. 9 (risk management) and Art. 10 (data governance) substantially. |
| **MEASURE** | A.6.2.4 (V&V), A.6.2.6 (Operation/Monitoring) | Art. 15(1), Annex IV(2)(e-f), 9(6-7), 10(2)(f), 10(5), 43, 31-39 | Performance + conformity + post-market metrics. NIST MEASURE supplies the testing discipline EU AI Act Art. 15 demands; conformity assessment (Art. 43) and notified bodies (Art. 31-39) are EU-specific. |
| **MANAGE** | A.6.2.5 (Deployment), A.8 (Information for Interested Parties), A.9 (Use) | Art. 9(4), 9(2)(b), 20, 18, 12, 73, 72 | Treatment, deployment, monitoring, communication. NIST MANAGE.4 (post-deployment monitoring) maps to EU AI Act Art. 72 (post-market monitoring) + Art. 73 (serious incident reporting — 15-day timeline EU-specific). |

> The 4 NIST functions × ~70-75 subcategories are sized larger than ISO 42001's 38 sub-controls. For per-subcategory detail and exact subcategory↔clause mappings, see the Microsoft crosswalk PDF cited above.

## EU AI Act Coverage Gaps

NIST AI RMF substantially overlaps EU AI Act Articles 9-17 (~60-70% foundation per GLACIS community analysis at `https://www.glacis.io/guide-nist-ai-rmf-vs-eu-ai-act`), but the EU AI Act adds mandatory items NIST does NOT address:

| EU AI Act Requirement | Article | NIST AI RMF coverage |
|------------------------|---------|----------------------|
| Prohibited AI practices (subliminal techniques, social scoring, etc.) | Art. 5 | None (NIST is risk-based, not prohibition-based) |
| CE marking | Art. 48-49 | None (EU-specific conformity marking) |
| Conformity assessment procedures | Art. 43 | Partial (NIST MEASURE supplies methodology but not the CE marking process) |
| EU AI database registration for high-risk systems | Art. 71 | None (EU-specific registration mechanism) |
| 15-day serious incident reporting to market surveillance authorities | Art. 73 | Partial (NIST MANAGE.4 covers monitoring but not the 15-day EU timeline) |
| Explicit fines (€35M or 7% global revenue) | Art. 99 | None (NIST is voluntary, no enforcement mechanism) |
| Authorized EU representative for non-EU providers | Art. 22 | None (EU-specific provider obligation) |

**Practical consequence**: organizations implementing NIST AI RMF have ~60-70% of the foundation needed for EU AI Act compliance, but must close the EU-specific gaps above. NIST RMF is a **starting point** for EU AI Act readiness, not a substitute.

## DSGAI Cross-References (GenAI-specific risks)

NIST AI 600-1 (Generative AI Profile, 2024-07-26) extends NIST AI RMF 1.0 with 12 GenAI-specific risks. Several overlap directly with OWASP DSGAI controls already covered by claude-governance v3.0.0:

| NIST AI 600-1 GenAI Risk | DSGAI Control | claude-governance enforcement |
|---------------------------|---------------|-------------------------------|
| Information Integrity | DSGAI04 (Data, Model & Artifact Poisoning) | `skills/governance-check/SKILL.md` (pre-commit #10-12) |
| Data Privacy | DSGAI01 (Sensitive Data Leakage) + DSGAI07 (Data Governance) | `hooks/secret-scanner.sh` PII WARN patterns + `examples/DATA-CLASSIFICATION.md.example` |
| Confabulation | (no direct DSGAI mapping; design-time concern) | External — runtime evaluation tooling |
| Harmful Bias | (informative; no direct DSGAI mapping) | External — fairness testing tooling |
| CBRN Information | (out-of-scope for code-level scanning) | External — content policy / model alignment |

For the full OWASP DSGAI 11-control mapping, see `docs/compliance/DSGAI-MAPPING.md`.

## 8-Habit-AI-Dev Pointers (Runtime Concerns)

NIST AI RMF references several runtime activities that `claude-governance` does not enforce directly. If you have `pitimon/8-habit-ai-dev` installed, use these companion skills:

- **NIST GOVERN.5 (workforce diversity / stakeholder engagement)** → no direct skill (organizational practice)
- **NIST MAP.5 (risk impact characterization)** → `/research` (Standard depth) for impact analysis
- **NIST MEASURE.4 (testing in deployment)** → `/monitor-setup` for observability + drift detection
- **NIST MANAGE.4 (post-deployment monitoring + incident response)** → `/monitor-setup` + `/ai-dev-log` for AI development transparency log + org incident response runbook
- **NIST AI 600-1 GAI 5.1 (generative AI deployment)** → `/deploy-guide` for staging-first deployment discipline

## Cross-References to Sibling Mapping Docs

- **ISO/IEC 42001:2023 mapping**: `docs/compliance/ISO-42001-MAPPING.md` — the full 38-control Annex A mapping (the canonical Microsoft crosswalk above provides per-subcategory NIST↔ISO 42001 detail; the ISO mapping doc adds the per-clause Status taxonomy with ENFORCED/EVIDENCE-ONLY/GAP coverage)
- **EU AI Act mapping**: `docs/compliance/EU-AI-ACT-MAPPING.md` — the full Articles 9-15 obligation reference with claude-governance skill routing
- **OWASP DSGAI mapping**: `docs/compliance/DSGAI-MAPPING.md` — the 11-control DSGAI mapping with hook + skill enforcement detail

## Standards Family (informative)

The following standards are adjacent to NIST AI RMF and may be relevant depending on jurisdiction or sector:

- **NIST SP 800-53** — security controls (federal information systems); NIST AI RMF is complementary, not a substitute
- **NIST CSF 2.0** — cybersecurity framework; AI RMF maps to CSF GOVERN function via airc.nist.gov community crosswalks
- **NIST AI 600-1** — Generative AI Profile (companion document, July 2024); 12 GenAI risk categories (see DSGAI cross-reference table above)
- **NIST AI 100-X series** (planned) — additional AI RMF Profiles (e.g., critical infrastructure, concept note April 2026)
- **ISO/IEC 42005:2024** — AI impact assessment; community NIST→42005 crosswalk available at airc.nist.gov (Tier 3 deferred for now per consolidated lesson)
- **OECD AI Principles** + **EO 14110 / 13960** — NIST-authored crosswalk available at airc.nist.gov

## Provenance

- **Tracking issue**: pitimon/claude-governance#29
- **Research brief**: `docs/research/nist-ai-rmf-compliance-brief.md` (Deep + Compare mode, 2026-05-03)
- **Decision rationale**: `docs/adr/ADR-005-nist-ai-rmf-cross-reference-doc.md`
- **PRD**: `docs/research/nist-ai-rmf-toolkit-prd.md`
- **Citation date**: 2026-05-03 (Microsoft crosswalk SHA-256 captured at this time; if SHA verification fails, see Authoritative Sources DOI as the permanent anchor)

> **NOT A CERTIFICATION GUARANTEE.** This cross-reference doc is a navigation aid, not an attestation. NIST AI RMF 1.0 is voluntary US federal guidance — running through this document or citing the Microsoft crosswalk does not constitute NIST AI RMF compliance. For US federal procurement attestation, consult NIST SP 800-53 / FedRAMP processes.
