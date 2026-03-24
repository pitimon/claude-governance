# Shadow AI Policy Template

> Organizational policy for approved and unsanctioned AI tool usage. Reference: OWASP DSGAI03.

## Purpose

Define which AI tools are approved for organizational use, what data may be sent to them, and how to handle unsanctioned AI adoption. This policy reduces data leakage risk from ungoverned AI tools.

## Definitions

- **Approved AI tools**: AI services reviewed and authorized by security/governance for organizational use
- **Unsanctioned AI (Shadow AI)**: Any AI tool adopted without formal security review — includes consumer SaaS (ChatGPT, Gemini), browser plugins with AI features, embedded AI in productivity tools, and internally-built ungoverned AI endpoints

## Approved Tool List

| Tool                      | Version/Tier | Scope             | Max Data Level | Training Opt-Out      | Reviewed     |
| ------------------------- | ------------ | ----------------- | -------------- | --------------------- | ------------ |
| _Claude Code_             | _Current_    | _Development_     | _Internal (2)_ | _Yes_                 | _2026-01-15_ |
| _GitHub Copilot Business_ | _Enterprise_ | _Code completion_ | _Internal (2)_ | _Yes (telemetry off)_ | _2026-01-15_ |

## Data Classification Rules for AI Tools

| Data Level       | May Send to Approved AI?                             | May Send to External AI? |
| ---------------- | ---------------------------------------------------- | ------------------------ |
| Public (1)       | Yes                                                  | Yes                      |
| Internal (2)     | Yes (with approved tools only)                       | No                       |
| Confidential (3) | Case-by-case (requires manager approval)             | No                       |
| Restricted (4)   | No — never send PII, credentials, PHI to any AI tool | No                       |

## Prohibited Patterns

Flag these in code reviews, configs, and CI:

- References to unsanctioned AI endpoints in source code or configs
- API keys for non-approved AI services
- Browser extension AI tools not on the approved list
- Data pipelines sending Confidential+ data to external AI endpoints
- Fine-tuning or RAG indexing with unreviewed data sources

## Consequences for Violations

1. **First occurrence**: Education and remediation — remove unauthorized tool, rotate any exposed credentials
2. **Repeated violations**: Escalation to manager and security team
3. **Data breach via Shadow AI**: Incident response per organizational IR plan

## Exception Process

1. Submit AI tool request to security/governance team
2. Security assessment: data handling, retention, training opt-out, cross-border, DPA
3. If approved: add to Approved Tool List with scope and data level restrictions
4. If denied: document rationale, suggest approved alternatives

## Review Cadence

- **Quarterly**: Review approved tool list, update versions and scope
- **On vendor change**: Re-assess if vendor changes terms, pricing, or data handling
- **On incident**: Review after any Shadow AI-related security event
- **Annual**: Full policy review with stakeholder input

## Approved Alternatives

> H4 Win-Win: Don't just prohibit — provide governed alternatives.

For each common Shadow AI use case, provide an approved path:

| Need                     | Shadow AI Risk              | Approved Alternative                      |
| ------------------------ | --------------------------- | ----------------------------------------- |
| _Code generation_        | _Pasting code into ChatGPT_ | _Claude Code / GitHub Copilot (approved)_ |
| _Document summarization_ | _Uploading to consumer AI_  | _Internal RAG system (if available)_      |
| _Email drafting_         | _Browser AI plugins_        | _Approved AI writing tool (specify)_      |
