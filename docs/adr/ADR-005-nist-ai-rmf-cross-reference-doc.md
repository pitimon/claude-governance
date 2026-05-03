# ADR-005: NIST AI RMF Selected as Cross-Reference Doc, Not Standalone Skill

## Status

Accepted

## Date

2026-05-03

## Context

Three compliance frameworks shipped before this one: OWASP DSGAI (v3.0.0, hooks + governance checks), EU AI Act (v3.1.0, `/eu-ai-act-check` skill, ADR-003), ISO/IEC 42001:2023 (v3.2.0, `/iso-42001-check` skill, ADR-004). Each was added as a standalone skill because each had a unique audit/regulatory path: DSGAI for hands-on data security checks, EU AI Act for regulatory deploy-blocker compliance, ISO 42001 for third-party certification readiness.

ADR-004 introduced the **demand-first review trigger**: standalone skills for adjacent ISO standards (23894 risk management, 5338 lifecycle, 22989 vocabulary, 38507 board governance) are deferred until customer demand emerges or a regulator formally cross-walks to ISO 42001.

A Deep + Compare research brief on **NIST AI RMF 1.0** (2026-05-03, `docs/research/nist-ai-rmf-compliance-brief.md`) evaluated whether NIST should follow the same standalone-skill pattern. Key findings:

1. **NIST AI RMF 1.0 (NIST.AI.100-1)** is voluntary US federal guidance, freely accessible (DOI permanent anchor: `https://doi.org/10.6028/NIST.AI.100-1`), released 2023-01-26 — opposite of ISO 42001's paywall but with no certification path that requires a per-control checklist
2. **An official Microsoft-authored NIST → ISO 42001 crosswalk** already exists, hosted on the NIST AI Resource Center: `https://airc.nist.gov/docs/NIST_AI_RMF_to_ISO_IEC_42001_Crosswalk.pdf` (16 pages, Excel-origin). The mapping work has already been done upstream
3. **No official NIST → EU AI Act crosswalk exists** as of 2026-05-03 — only community analyses (e.g., GLACIS, ~60-70% foundation overlap claim)
4. **No demand signal in this codebase** — issue #27 mentioned NIST AI RMF only as an ADR-004 Review Trigger condition, not as a customer ask
5. **The own-plugin secret-scanner false positive** (the canonical NIST AI RMF home-page URL slug trips the OpenAI/Stripe `sk-` pattern via the embedded substring formed by concatenating "ri" + the rest of the slug) is a prerequisite blocker — without the scanner fix, the new mapping doc cannot cite the canonical URL without a heredoc workaround

The asymmetry between NIST and the prior two frameworks: ISO 42001 had to be standalone for certification audits; EU AI Act had to be standalone for regulatory enforcement. NIST has neither — its value to a `claude-governance` user comes from **bridging existing ISO 42001 / EU AI Act evidence to US procurement contexts** (EO 14110-driven), not from being a standalone audit. Re-deriving the 70+ subcategory Microsoft crosswalk would duplicate upstream effort with no marginal benefit.

## Decision

Add **NIST AI RMF 1.0** to `claude-governance` v3.3.0 as a **first-class cross-reference document**, NOT a standalone `/nist-ai-rmf-check` skill.

1. **Ship `docs/compliance/NIST-AI-RMF-MAPPING.md`** — the canonical cross-reference doc with:
   - 4-row function-level mapping table (Govern / Map / Measure / Manage ↔ ISO 42001 Annex A clause(s) ↔ EU AI Act Article(s))
   - Citation of the Microsoft-authored crosswalk URL with SHA-256 verification snippet (link-rot mitigation)
   - DOI (`NIST.AI.100-1`) as the permanent authoritative anchor independent of the crosswalk URL
   - EU AI Act gap list (NIST does NOT cover prohibited practices, CE marking, conformity assessment, EU database registration, 15-day incident reporting, EU representative)
   - DSGAI cross-references for GenAI-specific risks via NIST AI 600-1 GenAI Profile

2. **Add bidirectional cross-references** to the two existing compliance mapping docs (`ISO-42001-MAPPING.md` and `EU-AI-ACT-MAPPING.md`) using a 2-column table tailored per host audience (per design decision D5-C). Each sibling section back-links to `NIST-AI-RMF-MAPPING.md` by full path.

3. **Tighten the secret-scanner OpenAI/Stripe regex** (own-plugin bug discovered during research). Two-stage check: (a) base regex with left word boundary, (b) matched text must contain at least one digit. Preserves the v3.0.x 20-char length floor; fixes the canonical NIST URL false positive without weakening real-key detection (verified by 4 new TDD regression tests).

4. **No standalone `/nist-ai-rmf-check` skill in this round** — defer per the demand-first pattern (extends ADR-004's review trigger logic to a sibling framework).

5. **No `compliance-framework-template/` skeleton extraction in this round** — the meta-pattern (skill + reference.md + mapping doc + ADR + validator section + bidirectional cross-refs) needs three standalone-skill data points before extraction, not two skills + one cross-ref doc. Tracked in the consolidated lesson `~/.claude/lessons/2026-05-03-claude-governance-compliance-toolkit-arc.md` action item #3.

## Consequences

### Positive

- Reuses upstream Microsoft crosswalk effort (no re-derivation of 70+ subcategory mappings)
- Matches the demand-first pattern established by ADR-004 — consistent decision logic across the framework family
- Keeps plugin scope manageable (no 4th skill maintenance burden when there's no demand signal)
- Bidirectional cross-references (NIST ↔ ISO 42001 + NIST ↔ EU AI Act + NIST ↔ DSGAI) make the framework family navigable for users with cross-jurisdictional compliance asks
- The bundled scanner fix prevents the false-positive trap from biting future contributors who cite NIST URLs in research, ADRs, or PR descriptions
- Validator section 3.13 enforces bidirectional cross-references at validation time (not PR-review time) — discipline scales

### Negative

- Users who expect a standalone skill (given the precedent of `/eu-ai-act-check` and `/iso-42001-check`) may need clarification — the README Compliance Frameworks table row explicitly labels NIST as "Cross-reference doc" (distinct from "Skill") to manage expectations
- Bundled PR scope (NIST cross-ref + scanner fix in v3.3.0) mixes two concerns; mitigated by 4-commit sequencing for bisectability
- The Microsoft crosswalk PDF is the canonical mapping reference; if it is moved or removed, the mapping doc must be updated — see Risks below

### Risks

- **NIST RMF 1.1 / 2.0 publication** could shift function/category structure. Mitigation: Review Trigger explicitly names "NIST publishes 1.1+" as a re-evaluation event.
- **Microsoft crosswalk PDF link rot** — `airc.nist.gov` is a curated resource center, not strictly version-controlled. Mitigation: SHA-256 snapshot in `NIST-AI-RMF-MAPPING.md` at citation time + verification snippet for users to re-check + DOI permanent anchor as fallback.
- **Scanner regex change weakening real-key detection** — the digit requirement could in theory miss a no-digit OpenAI key. Mitigation: 4 TDD regression tests pin the behavior; the digit requirement is empirically safe because real OpenAI/Stripe/Anthropic keys are alphanumeric with digits by construction (verified: `sk-proj-` and `sk-ant-` keys both contain digits in their canonical shape).
- **Demand signal arrives after this ships** — if a customer asks for standalone NIST RMF skill in 2026-Q3, the cross-reference doc may need parallel maintenance with a new skill. Mitigation: Review Trigger covers this case; ADR-005's structure makes the upgrade path explicit.

## Governance

- **Decision Loop**: **On-the-Loop** — additive doc; users not pursuing NIST AI RMF compliance ignore the file. Not foundational like ADR-001/002 (governance framework + Three Loops); no cross-plugin coordination like ADR-003 (EU AI Act migration); no certification audit chain like ADR-004 (ISO 42001). Author proposes the cross-reference structure, maintainer approves at PR review.
- **Fitness Function**: `tests/validate-plugin.sh` section 3.13 enforces three **structural gates** (rejecting numeric-count gates per ADR-004's circularity argument):
  1. `docs/compliance/NIST-AI-RMF-MAPPING.md` exists
  2. `docs/compliance/ISO-42001-MAPPING.md` cites `NIST-AI-RMF-MAPPING.md` by full path string
  3. `docs/compliance/EU-AI-ACT-MAPPING.md` cites `NIST-AI-RMF-MAPPING.md` by full path string
- **Review Trigger**: re-open this decision when ANY of:
  1. A customer or auditor explicitly requests standalone NIST AI RMF evidence (US federal procurement, FedRAMP-adjacent, or sector-regulator-driven context)
  2. NIST publishes AI RMF 1.1 or 2.0 with material structural changes (new function, renumbered categories, replaced GenAI Profile)
  3. A regulator (updated Executive Order, state AI law, sector regulator) makes NIST AI RMF compliance mandatory in any context that overlaps `claude-governance`'s user base
  4. A third standalone compliance skill is requested — at that point, extract the `compliance-framework-template/` skeleton (consolidated lesson action item #3)

## Provenance

- **Tracking issue**: pitimon/claude-governance#29
- **Research brief**: `docs/research/nist-ai-rmf-compliance-brief.md` (Deep + Compare mode, verified via `8-habit-ai-dev:research-verifier` agent — 6/7 claims VERIFIED, 1 minor correction applied)
- **PRD**: `docs/research/nist-ai-rmf-toolkit-prd.md` (10 EARS criteria, 6 success criteria, 5 risks documented, 4-commit sequencing constraint)
- **Canonical NIST AI RMF DOI** (permanent anchor): `https://doi.org/10.6028/NIST.AI.100-1`
- **Microsoft-authored ISO 42001 crosswalk** (cited canonical mapping): `https://airc.nist.gov/docs/NIST_AI_RMF_to_ISO_IEC_42001_Crosswalk.pdf` — 16 pages, hosted on NIST AI Resource Center, authored by Gregory Montgomery (Microsoft)
- **NIST AI Resource Center crosswalk hub**: `https://airc.nist.gov/airmf-resources/crosswalks/` — 13 published crosswalks (3 NIST-authored, 10 community-contributed)
- **Companion ADR**: ADR-004 (ISO 42001 framework selection — establishes the demand-first pattern this ADR extends)
- **Predecessor ADRs**: ADR-001 (governance framework adoption), ADR-002 (Three Loops + consequence-based authorization), ADR-003 (EU AI Act compliance toolkit migration)
- **Memory observation**: consolidated lesson `~/.claude/lessons/2026-05-03-claude-governance-compliance-toolkit-arc.md` (action item #3 anticipated this exact decision)
- **Bundled scope note**: this ADR also documents the secret-scanner OpenAI/Stripe regex fix (own-plugin bug discovered during research; sequencing prerequisite for citing the canonical NIST URL without heredoc workaround). The scanner fix lands as commit 1 of the v3.3.0 PR; this ADR lands as commit 2.

## NOT A CERTIFICATION GUARANTEE

NIST AI RMF 1.0 is voluntary US federal guidance. The `NIST-AI-RMF-MAPPING.md` cross-reference doc is a developer-facing navigation aid for bridging existing ISO 42001 / EU AI Act evidence to US procurement contexts — **not** an attestation of NIST AI RMF compliance, **not** a substitute for FedRAMP / NIST SP 800-53 processes, and **not** a certification path. For US federal procurement attestation, consult NIST Special Publication 800-53 / FedRAMP processes or the appropriate sector regulator.
