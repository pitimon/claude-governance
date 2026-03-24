# OWASP DSGAI Compliance Mapping

> Maps claude-governance controls to [OWASP GenAI Data Security (DSGAI)](https://genai.owasp.org) v1.0 (March 2026).
> Plugin version: v2.3.0 | Coverage: Tier 1 (Foundational)

## Implemented Controls

| DSGAI ID | Risk                                     | claude-governance Implementation                                                             | Component                                                                                      |
| -------- | ---------------------------------------- | -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| DSGAI01  | Sensitive Data Leakage                   | PII WARN patterns (email, SSN, credit card) — warns without blocking                         | `hooks/secret-scanner.sh`                                                                      |
| DSGAI02  | Agent Identity & Credential Exposure     | OAuth/bearer/refresh/client_secret BLOCK patterns + agent credential governance checks       | `hooks/secret-scanner.sh`, `skills/governance-check/SKILL.md`, `agents/governance-reviewer.md` |
| DSGAI06  | Tool, Plugin & Agent Data Exchange       | Plugin/MCP security architecture checks, MCP security checklist template                     | `skills/governance-check/SKILL.md`, `examples/mcp-security-checklist.md`                       |
| DSGAI07  | Data Governance & Classification         | DATA-CLASSIFICATION.md template with AI/LLM data flow tracking, governance-setup integration | `examples/DATA-CLASSIFICATION.md.example`, `skills/governance-setup/SKILL.md`                  |
| DSGAI08  | Non-Compliance & Regulatory Violations   | This compliance mapping document, DSGAI cross-references in all governance outputs           | `docs/compliance/DSGAI-MAPPING.md`                                                             |
| DSGAI15  | Over-Broad Context & Prompt Over-Sharing | Context minimization architecture checks, session-start reminder                             | `skills/governance-check/SKILL.md`, `hooks/session-start.sh`                                   |

## Control Details

### DSGAI01 — Sensitive Data Leakage

- **Scanner patterns:** Email, SSN (XXX-XX-XXXX), credit card (16 digits)
- **Behavior:** WARN (stderr + exit 0) — does not block writes to avoid false positives on test data
- **Governance check:** Pre-commit category references PII warnings
- **Complementary tools:** GitLeaks, TruffleHog, `/secret-scan` (devsecops-ai-team)

### DSGAI02 — Agent Identity & Credential Exposure

- **Scanner patterns:** Bearer tokens, OAuth tokens, refresh tokens, client secrets (BLOCK — exit 2)
- **Governance check:** Pre-commit item 9 (agent credentials) + architecture item 8 (credential hygiene)
- **Single source of truth:** `hooks/secret-scanner.sh` BLOCK_PATTERNS array

### DSGAI06 — Tool, Plugin & Agent Data Exchange

- **Governance check:** Architecture item 6 — plugin/MCP least-privilege, trusted sources, no wildcard access
- **Template:** `examples/mcp-security-checklist.md` — pre-install, config review, periodic audit
- **Cross-reference:** OWASP Agentic Top 10 ASI04 (Tool/Function Abuse), ASI09 (Operational Misalignment)

### DSGAI07 — Data Governance & Classification

- **Template:** `examples/DATA-CLASSIFICATION.md.example` — 4 levels (Public/Internal/Confidential/Restricted)
- **Integration:** `/governance-setup` step 3 offers data classification during project init
- **AI-specific:** Tracks what data is sent to LLMs and minimization strategies

### DSGAI08 — Non-Compliance & Regulatory Violations

- **This document** maps controls to DSGAI risks
- **All governance outputs** include `[DSGAI##]` references where applicable
- **Coverage gaps** explicitly documented below

### DSGAI15 — Over-Broad Context & Prompt Over-Sharing

- **Governance check:** Architecture item 7 — session hooks < 500 tokens, no secrets in CLAUDE.md
- **Session-start:** Context minimization reminder injected every session
- **Root cause mitigation:** Reducing context surface shrinks attack surface for DSGAI01, DSGAI09, DSGAI18

## Coverage Gaps (Planned for v3.0.0)

| DSGAI ID | Risk                                          | Status                            | Milestone |
| -------- | --------------------------------------------- | --------------------------------- | --------- |
| DSGAI03  | Shadow AI & Unsanctioned Data Flows           | Planned (#15)                     | v3.0.0    |
| DSGAI04  | Data, Model & Artifact Poisoning              | Planned (#16)                     | v3.0.0    |
| DSGAI05  | Data Integrity & Validation Failures          | Not started                       | —         |
| DSGAI09  | Multimodal Capture & Cross-Channel Leakage    | Not applicable (text-only plugin) | —         |
| DSGAI11  | Cross-Context & Multi-User Conversation Bleed | Planned (#19)                     | v3.0.0    |
| DSGAI12  | Unsafe Natural-Language Data Gateways         | Deferred to `/genai-data-scan`    | —         |
| DSGAI13  | Vector Store Platform Data Security           | Deferred to `/agentic-scan`       | —         |
| DSGAI14  | Excessive Telemetry & Monitoring Leakage      | Planned (#17)                     | v3.0.0    |
| DSGAI19  | Human-in-the-Loop & Labeler Overexposure      | Planned (#18)                     | v3.0.0    |

## Complementary Tools

For DSGAI controls beyond claude-governance's scope, use:

- **devsecops-ai-team** plugin: `/genai-data-scan` (DSGAI full scan), `/agentic-scan` (OWASP Agentic Top 10), `/mcp-scan` (MCP security)
- **GitLeaks / TruffleHog:** Git history secret scanning (DSGAI01 Tier 2)
- **Checkov / Trivy:** IaC and container security (DSGAI04/05)
