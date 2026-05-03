# OWASP DSGAI Compliance Mapping

> Maps claude-governance controls to [OWASP GenAI Data Security (DSGAI)](https://genai.owasp.org) v1.0 (March 2026).
> Plugin version: v3.0.0 | Coverage: Tier 1 + Tier 2 (11 controls)

## Implemented Controls

| DSGAI ID | Risk                                          | claude-governance Implementation                                           | Component                                                                       |
| -------- | --------------------------------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| DSGAI01  | Sensitive Data Leakage                        | PII WARN patterns (email, SSN, credit card)                                | `hooks/secret-scanner.sh`                                                       |
| DSGAI02  | Agent Identity & Credential Exposure          | OAuth/bearer/refresh/client_secret BLOCK patterns + governance checks      | `hooks/secret-scanner.sh`, `skills/governance-check/SKILL.md`                   |
| DSGAI03  | Shadow AI & Unsanctioned Data Flows           | Shadow AI policy template + architecture check for approved tooling        | `examples/shadow-ai-policy.md`, `skills/governance-check/SKILL.md`              |
| DSGAI04  | Data, Model & Artifact Poisoning              | Model file detection, unsafe deserialization checks, AI dependency pinning | `skills/governance-check/SKILL.md`, `examples/ai-supply-chain-checklist.md`     |
| DSGAI06  | Tool, Plugin & Agent Data Exchange            | Plugin/MCP security architecture checks, MCP security checklist            | `skills/governance-check/SKILL.md`, `examples/mcp-security-checklist.md`        |
| DSGAI07  | Data Governance & Classification              | DATA-CLASSIFICATION.md template with AI/LLM data flow tracking             | `examples/DATA-CLASSIFICATION.md.example`, `skills/governance-setup/SKILL.md`   |
| DSGAI08  | Non-Compliance & Regulatory Violations        | This compliance mapping, DSGAI cross-references in all outputs             | `docs/compliance/DSGAI-MAPPING.md`                                              |
| DSGAI11  | Cross-Context & Multi-User Conversation Bleed | Session isolation + multi-tenant data separation architecture checks       | `skills/governance-check/SKILL.md`, `agents/governance-reviewer.md`             |
| DSGAI14  | Excessive Telemetry & Monitoring Leakage      | Telemetry hygiene + telemetry redaction pre-commit checks                  | `skills/governance-check/SKILL.md`, `agents/governance-reviewer.md`             |
| DSGAI15  | Over-Broad Context & Prompt Over-Sharing      | Context minimization architecture checks, session-start reminder           | `skills/governance-check/SKILL.md`, `hooks/session-start.sh`                    |
| DSGAI19  | Human-in-the-Loop & Labeler Overexposure      | Consequence-based auth extending Three Loops, irreversible op safeguards   | `hooks/session-start.sh`, `docs/adr/ADR-002-consequence-based-authorization.md` |

## Control Details — Tier 1 (v2.3.0)

### DSGAI01 — Sensitive Data Leakage

- **Scanner patterns:** Email, SSN (XXX-XX-XXXX), credit card (16 digits)
- **Behavior:** WARN (exit 0) — does not block writes
- **Complementary tools:** GitLeaks, TruffleHog, `/secret-scan`

### DSGAI02 — Agent Identity & Credential Exposure

- **Scanner patterns:** Bearer, OAuth, refresh tokens, client secrets (BLOCK — exit 2)
- **Governance check:** Pre-commit #9 + architecture #8

### DSGAI06 — Tool, Plugin & Agent Data Exchange

- **Governance check:** Architecture #6 — plugin/MCP least-privilege
- **Template:** `examples/mcp-security-checklist.md`
- **Cross-ref:** OWASP Agentic ASI04, ASI09

### DSGAI07 — Data Governance & Classification

- **Template:** `examples/DATA-CLASSIFICATION.md.example` — 4 levels
- **Integration:** `/governance-setup` step 3

### DSGAI08 — Non-Compliance & Regulatory Violations

- **This document** + `[DSGAI##]` tags in all governance outputs

### DSGAI15 — Over-Broad Context & Prompt Over-Sharing

- **Governance check:** Architecture #7 — session hooks < 500 tokens, no secrets in CLAUDE.md

## Control Details — Tier 2 (v3.0.0)

### DSGAI03 — Shadow AI & Unsanctioned Data Flows

- **Template:** `examples/shadow-ai-policy.md` — approved tools, data rules, prohibited patterns, exceptions
- **Governance check:** Architecture #9 — verify approved AI tooling documented
- **Integration:** `/governance-setup` step 3.5 offers Shadow AI policy creation
- **Win-Win (H4):** Includes approved alternatives, not just prohibitions

### DSGAI04 — Data, Model & Artifact Poisoning

- **Governance check:** Pre-commit #10 (model files), #11 (unsafe deserialization), #12 (dependency pinning)
- **Template:** `examples/ai-supply-chain-checklist.md` — model vetting, dataset provenance, safe alternatives
- **Security rule:** AI Artifact Security section in `examples/rules/security.md`
- **Cross-ref:** OWASP LLM Top 10 LLM03 (Supply Chain)

### DSGAI11 — Cross-Context & Multi-User Conversation Bleed

- **Governance check:** Architecture #11 (session isolation), #12 (multi-tenant separation)
- **Deep review:** `governance-reviewer` checks memory scoping, cache keys, tenant isolation
- **Security rule:** Session Isolation section in `examples/rules/security.md`

### DSGAI14 — Excessive Telemetry & Monitoring Leakage

- **Governance check:** Pre-commit #13 (telemetry hygiene), #14 (telemetry redaction)
- **Deep review:** `governance-reviewer` reviews observability configs
- **Security rule:** Telemetry Hygiene section in `examples/rules/security.md`
- **Key patterns:** `log.*prompt`, `log.*context`, `logger.*user_input`

### DSGAI19 — Human-in-the-Loop & Labeler Overexposure

- **Three Loops extension:** Consequence Override — irreversible ops always In-the-Loop
- **ADR:** `docs/adr/ADR-002-consequence-based-authorization.md`
- **Governance check:** Architecture #10 (irreversible operation safeguards)
- **Consequence levels:** Reversible → Contained → Broad → Irreversible

## Remaining Gaps

| DSGAI ID | Risk                                       | Status                            |
| -------- | ------------------------------------------ | --------------------------------- |
| DSGAI05  | Data Integrity & Validation Failures       | Not started                       |
| DSGAI09  | Multimodal Capture & Cross-Channel Leakage | Not applicable (text-only plugin) |
| DSGAI12  | Unsafe Natural-Language Data Gateways      | Deferred to `/genai-data-scan`    |
| DSGAI13  | Vector Store Platform Data Security        | Deferred to `/agentic-scan`       |

## EU AI Act Cross-References

EU AI Act Article 15 ¶5 names exactly 5 AI-specific attack categories that align with DSGAI controls. Use this table for bidirectional traceability when generating evidence for both frameworks:

| EU AI Act Art. 15 ¶5 attack              | DSGAI control      | Reference in this plugin                                                    |
| ---------------------------------------- | ------------------ | --------------------------------------------------------------------------- |
| Data poisoning (training data)           | DSGAI04            | `examples/ai-supply-chain-checklist.md`, `skills/governance-check/SKILL.md` |
| Model poisoning (pre-trained components) | DSGAI04            | same                                                                        |
| Adversarial examples / model evasion     | DSGAI04 (extended) | same                                                                        |
| Confidentiality attacks                  | DSGAI11            | `skills/governance-check/SKILL.md`, `agents/governance-reviewer.md`         |
| Model flaws                              | DSGAI04 + DSGAI11  | combined                                                                    |

See `docs/compliance/EU-AI-ACT-MAPPING.md` for the full Article-to-skill mapping (all 9 obligations, Articles 9-15). The bidirectional pointer in `EU-AI-ACT-MAPPING.md` Obligation 9 (Cybersecurity) points back to this section.

## ISO 42001 Cross-References

ISO/IEC 42001:2023 Annex A controls overlap with several DSGAI controls. Use this table for bidirectional traceability when generating evidence for both frameworks (per ADR-004):

| DSGAI control                              | ISO 42001 Annex A clause                                             | Reference                                                                                       |
| ------------------------------------------ | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| DSGAI03 (Shadow AI)                        | A.4.4 (Tooling resources)                                            | `examples/shadow-ai-policy.md`                                                                  |
| DSGAI04 (Data, Model & Artifact Poisoning) | A.7.4 (Quality of data), A.7.5 (Data provenance), A.10.3 (Suppliers) | `skills/governance-check/SKILL.md` (pre-commit #10-12), `examples/ai-supply-chain-checklist.md` |
| DSGAI07 (Data Governance & Classification) | A.4.3 (Data resources), A.7.2 (Data for development)                 | `examples/DATA-CLASSIFICATION.md.example`                                                       |
| DSGAI19 (Human-in-the-Loop)                | A.9.2 (Processes for responsible use)                                | `docs/adr/ADR-002-consequence-based-authorization.md`                                           |

See `docs/compliance/ISO-42001-MAPPING.md` for the full Annex A coverage scorecard (38 controls across 9 clauses) and the bidirectional pointer back from ISO 42001 to DSGAI.

## Complementary Tools

- **devsecops-ai-team** plugin: `/genai-data-scan` (DSGAI full scan), `/agentic-scan` (Agentic Top 10), `/mcp-scan` (MCP security)
- **GitLeaks / TruffleHog:** Git history secret scanning (DSGAI01 Tier 3)
- **Checkov / Trivy:** IaC and container security (DSGAI04/05)
