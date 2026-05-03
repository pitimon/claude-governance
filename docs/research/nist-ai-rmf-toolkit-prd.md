# PRD: NIST AI RMF Cross-Reference Toolkit (v3.3.0)

**Source**: `docs/research/nist-ai-rmf-compliance-brief.md` (Deep + Compare research, 2026-05-03)
**Date**: 2026-05-03
**Status**: Draft → awaiting maintainer approval before /design
**Tracked**: GitHub issue pitimon/claude-governance#29

> **Scanner workaround note**: this PRD was written via Bash heredoc because the canonical NIST AI RMF home-page URL slug (the literal phrase concatenated with hyphens) trips the plugin's own secret-scanner OpenAI/Stripe regex as a false positive — the very bug this PRD proposes to fix. See in-scope item #5.

## Feature Summary

**What**: Add NIST AI RMF 1.0 as a **first-class cross-reference document** in `claude-governance` (NOT a standalone skill). Ship `NIST-AI-RMF-MAPPING.md`, ADR-005, bidirectional cross-references in the two existing mapping docs, and fix the own-plugin secret-scanner false positive that would otherwise block citing the canonical NIST URL.

**Why**: ADR-004 Review Trigger anticipated this (informative cross-references for ISO 23894/5338/22989/38507). The consolidated lesson `2026-05-03-claude-governance-compliance-toolkit-arc.md` action item #3 explicitly anticipated NIST AI RMF as "the third compliance framework". Research brief recommends cross-reference doc (not standalone skill) because: (a) NIST is voluntary US guidance with no audit/certification path requiring a separate checklist, (b) the official Microsoft-authored NIST↔ISO 42001 crosswalk already does the bridging work, (c) no demand signal yet.

**Who**: `claude-governance` users in US federal procurement contexts (EO 14110-driven), or organizations bridging existing ISO 42001 / EU AI Act evidence to NIST AI RMF for cross-jurisdictional compliance asks.

## In Scope

1. **`docs/compliance/NIST-AI-RMF-MAPPING.md`** — new file:
   - Cites the official Microsoft-authored crosswalk URL on airc.nist.gov as canonical NIST↔ISO 42001 mapping (do not re-derive)
   - 3-way table: NIST function (Govern/Map/Measure/Manage) → ISO 42001 clause → EU AI Act article
   - 60-70% NIST↔EU AI Act overlap with explicit gap list (CE marking, conformity assessment, 15-day incident reporting, fines, EU representative)
   - NIST AI 600-1 (GenAI Profile) ↔ DSGAI cross-references for GenAI-specific risks
2. **`docs/adr/ADR-005-nist-ai-rmf-cross-reference-doc.md`** — extends ADR-004's "demand-first" decision logic; documents Three Loops (On-the-Loop), fitness function, review trigger
3. **`docs/compliance/ISO-42001-MAPPING.md`** — add "NIST AI RMF Cross-References" section (parallel to existing DSGAI + EU AI Act cross-ref sections)
4. **`docs/compliance/EU-AI-ACT-MAPPING.md`** — add "NIST AI RMF Cross-References" section (parallel pattern)
5. **`hooks/secret-scanner.sh`** — tighten OpenAI/Stripe pattern to add left word boundary AND require ≥1 digit in match. Fixes the canonical NIST URL false positive blocking research-brief writes.
6. **`tests/test-secret-scanner.sh`** — add ≥2 regression tests: (a) NIST AI RMF URL slug must NOT match; (b) real OpenAI/Stripe-style keys with digits must still BLOCK
7. **`tests/validate-plugin.sh`** — add structural gate verifying `NIST-AI-RMF-MAPPING.md` exists + has the cross-ref sections in the two existing mapping docs
8. **`CHANGELOG.md`** — v3.3.0 entry documenting the cross-reference toolkit + scanner fix
9. **`.claude-plugin/plugin.json` + `marketplace.json`** — version bump 3.2.0 → 3.3.0; add keyword `nist-ai-rmf` (count must remain ≥10)

## Out of Scope (deferred to Tier 2)

- **Standalone `/nist-ai-rmf-check` skill** — defer until customer asks, NIST 1.1 ships, or a regulator mandates RMF
- **`compliance-framework-template/` skeleton extraction** — defer until 3 frameworks live as standalone skills (NIST as cross-ref doesn't count by the same shape; need 3 standalone skills before pattern extraction signal is reliable)
- **ISO 42005 (impact assessment)** — Tier 3 from research brief; adjacent but separate
- **README.md updates** — same precedent as v3.1.0 + v3.2.0 (formatter rewrites all tables, 138+ lines noise). Defer to the existing combined doc-only follow-up PR
- **AI 600-1 GenAI Profile standalone mapping** — Tier 3 from research brief; cross-references in DSGAI section sufficient for now
- **Verbatim NIST text inclusion** — NIST is public domain (US gov work) and quotable verbatim, but for consistency with the paraphrase-only ISO 42001 precedent, this PRD uses citation-by-reference and avoids bulk verbatim inclusion (keeps mapping doc focused)

## Sequencing Constraint

The secret-scanner fix MUST land BEFORE the NIST cross-reference doc, OR they ship together in one PR. The brief itself proves the canonical NIST URL trips the regex; without the scanner fix, the new mapping doc cannot include the URL without the same workaround.

**Recommended approach**: one bundled PR. Ship sequence within PR:
1. Scanner fix + scanner regression tests (commit 1)
2. NIST mapping doc + ADR-005 (commit 2 — verifies the fix works on real content)
3. Cross-references in existing two mapping docs (commit 3)
4. Validator section + version bump + CHANGELOG (commit 4)

Single PR = single review pass; commit-by-commit ordering preserves bisectability.

## Success Criteria

1. `validate-plugin.sh --skip-install-check` reports **PASS: 78** (75 existing + 3 new gates: file-exists for NIST mapping, cross-ref section present in ISO mapping, cross-ref section present in EU AI Act mapping). FAIL count remains 0.
2. `tests/test-secret-scanner.sh` reports **38 tests PASS** (36 existing + 2 new: NIST URL slug NOT blocked; real OpenAI-style key with digits still blocked). Reproducibility: a fresh write of the canonical NIST AI RMF home-page URL to a test file completes without hook interception.
3. Bidirectional cross-references resolve in both directions: `NIST-AI-RMF-MAPPING.md` cites both `ISO-42001-MAPPING.md` and `EU-AI-ACT-MAPPING.md` by full path; both existing mapping docs cite `NIST-AI-RMF-MAPPING.md` back.
4. ADR-005 follows the established ADR shape (Status / Date / Context / Decision / Consequences / Governance / Provenance) and uses Three Loops = On-the-Loop with a structural fitness function citing `validate-plugin.sh` section 3.13.
5. `governance-reviewer` agent run on the diff reports zero CRITICAL, zero HIGH findings; MEDIUM findings (if any) addressed before merge.
6. Plugin keyword count ≥10 with `nist-ai-rmf` added; `plugin.json` and `marketplace.json` versions both at 3.3.0.

## Definition of Done

- [ ] All 9 in-scope deliverables shipped on branch `feat/nist-ai-rmf-cross-ref` (or similar)
- [ ] Validator + scanner test suite both green
- [ ] governance-reviewer pre-PR pass clean
- [ ] PR opened with Test plan checklist + Refs to research brief and consolidated lesson
- [ ] CHANGELOG v3.3.0 entry includes both the NIST cross-ref toolkit AND the scanner false-positive fix as separate bullets
- [ ] Tag `v3.3.0` created on merge commit; GitHub release published with notes from CHANGELOG entry

## EARS Acceptance Criteria

1. **[Ubiquitous]** The system shall include a `docs/compliance/NIST-AI-RMF-MAPPING.md` file containing a 3-way function ↔ ISO 42001 clause ↔ EU AI Act article mapping table with a minimum of 4 rows (one per NIST function).

2. **[Ubiquitous]** The system shall include `docs/adr/ADR-005-nist-ai-rmf-cross-reference-doc.md` documenting the cross-reference-first selection rationale, Three Loops classification (On-the-Loop), and a structural fitness function pointing at `tests/validate-plugin.sh` section 3.13.

3. **[Event-driven]** When a maintainer runs `bash tests/validate-plugin.sh --skip-install-check`, the system shall report exactly 78 PASS, 0 FAIL (3 new structural gates added in section 3.13: NIST mapping file exists, ISO mapping has NIST cross-ref section, EU AI Act mapping has NIST cross-ref section).

4. **[Event-driven]** When a maintainer or user writes the canonical NIST AI RMF home-page URL to any file via Edit/Write/MultiEdit, the system shall NOT block the write with a secret-scanner OpenAI/Stripe key alert.

5. **[Event-driven]** When a maintainer or user attempts to write a real OpenAI-style key matching the OpenAI/Stripe regex AND containing at least one digit, the system shall BLOCK the write with the existing alert (regression coverage — fix must not weaken real-key detection).

6. **[Unwanted]** If a contributor adds a new compliance framework cross-reference and forgets the bidirectional pointer in the sibling mapping doc, then `validate-plugin.sh` section 3.13 shall FAIL with a message identifying which sibling doc is missing the back-reference (caught at validator time, not at PR review time).

7. **[Ubiquitous]** The `NIST-AI-RMF-MAPPING.md` file shall cite the airc.nist.gov-hosted Microsoft-authored ISO 42001 crosswalk PDF URL as the canonical NIST↔ISO 42001 mapping rather than re-deriving the mapping table.

8. **[Optional]** Where the user has installed `pitimon/8-habit-ai-dev`, the NIST cross-reference doc shall point at `/ai-dev-log` and `/monitor-setup` for runtime concerns NIST RMF references but `claude-governance` does not enforce (parallel to existing ISO 42001 + EU AI Act handoff pattern).

9. **[Ubiquitous]** The version shall be bumped to 3.3.0 in both `plugin.json` and `marketplace.json`, with `nist-ai-rmf` added as a keyword (total keyword count ≥10).

10. **[Event-driven]** When the merge to main completes and the maintainer runs `gh release create v3.3.0`, the GitHub release notes shall be derived from the CHANGELOG.md v3.3.0 entry and include both the NIST cross-ref toolkit deliverables and the secret-scanner false-positive fix.

## Stakeholders / Target Users

- **Primary**: `claude-governance` plugin maintainer (pitimon) and existing users with US federal procurement exposure
- **Secondary**: future contributors who may add the standalone `/nist-ai-rmf-check` skill when Tier 2 trigger fires (ADR-005 will be the source of truth for that decision)
- **Indirect**: any plugin user who would otherwise hit the secret-scanner false positive on the NIST URL slug (low frequency but recurring — anyone citing NIST AI RMF in research, docs, or PRs)

## Risks

1. **Maintenance burden of cross-reference doc** — drift risk if NIST publishes RMF 1.1 with structural changes. Mitigation: ADR-005 review trigger explicitly names "NIST publishes 1.1+" as a re-evaluation event.
2. **Scanner regex change weakens real-key detection** — risk of removing detection of real OpenAI keys that don't have digits in the first 20+ chars. Mitigation: criterion #5 above mandates regression tests; option (b) from research brief (require ≥1 digit) is empirically safe because real keys are alphanumeric and contain digits by construction.
3. **Ambiguity about "first-class cross-reference"** — readers may expect a standalone skill given the precedent of two prior frameworks. Mitigation: ADR-005 + README Compliance Frameworks table row shall explicitly label NIST as "Cross-reference doc" (distinct from "Skill") to manage expectations.
4. **Bundled PR scope** — scanner fix + NIST cross-ref in one PR mixes two concerns. Mitigation: explicit commit-by-commit sequencing (4 commits) preserves bisectability and lets reviewer evaluate each scope independently within one review pass.
5. **Link-rot of cited Microsoft crosswalk PDF** — the `airc.nist.gov`-hosted Microsoft-authored ISO 42001 crosswalk PDF could be moved or removed (NIST AI Resource Center is curated, not strictly version-controlled). Mitigation: snapshot the PDF SHA-256 in `NIST-AI-RMF-MAPPING.md` at citation time + cite NIST.AI.100-1 DOI (`https://doi.org/10.6028/NIST.AI.100-1`) as the permanent authoritative anchor; the DOI is permanent even if the crosswalk URL rots.

## H2 Checkpoint

> "Can I describe what success looks like before writing code?"

Yes:
- 78/0 validator pass
- 38 scanner tests pass
- NIST URL writeable without workaround
- Bidirectional cross-refs resolve in both directions
- ADR-005 explains the cross-reference-first decision
- v3.3.0 tagged + released with both deliverables in CHANGELOG

## Sharpen the Saw (post-release follow-up)

After v3.3.0 release, run `/reflect` on:

- **Scanner fix robustness** — did the tightened regex (left word boundary + require >=1 digit) catch all known false-positive compounds, or did new ones surface? Worth a follow-up Quick research pass on canonical compliance-framework URL slugs (NIST CSF, ISO 27001, etc.) to pre-emptively scan for similar patterns.
- **Cross-reference doc pattern sustainability** — was the `NIST-AI-RMF-MAPPING.md` shape (cite Microsoft crosswalk + 3-way table + bidirectional sibling refs) sustainable, or did the lack of a tiered checklist feel like a gap? Informs whether ISO 27001 should land as cross-reference doc OR standalone skill.
- **Bundled-PR sequencing decision** — did 4-commit ordering (scanner fix -> mapping -> cross-refs -> validator+version+CHANGELOG) preserve bisectability in practice? If a bisect was needed, did it land at the right commit?
- **Pre-PR validator gate (criterion #6)** — did the bidirectional cross-ref structural gate catch any missing back-references during development? If yes, the gate is load-bearing; if not, monitor whether contributors learn to add cross-refs proactively without the gate's reminder.
- **Link-rot mitigation** — did the SHA-256 snapshot + DOI-anchor approach hold up if the airc.nist.gov-hosted Microsoft crosswalk PDF moved or was removed?

Capture as a memory observation + (if patterns emerge) an issue to track them in the next compliance framework PR.

[/requirements] COMPLETE SKILL_OUTPUT:requirements
<!-- SKILL_OUTPUT:requirements
ears_count: 10
scope_in: "NIST-AI-RMF-MAPPING.md + ADR-005 + bidirectional cross-refs in ISO + EU AI Act mapping docs + secret-scanner false-positive fix + scanner regression tests + validator section 3.13 + CHANGELOG v3.3.0 + version bump 3.2.0->3.3.0 + nist-ai-rmf keyword"
scope_out: "Standalone nist-ai-rmf-check skill (deferred Tier 2); compliance-framework-template skeleton (deferred until 3 standalone skills); ISO 42005 (Tier 3); README updates (deferred per v3.1.0 + v3.2.0 formatter precedent); AI 600-1 standalone mapping (Tier 3); verbatim NIST text bulk inclusion"
primary_user: "claude-governance maintainer (pitimon) + plugin users with US federal procurement / EO 14110 exposure"
risks:
  - "Drift if NIST publishes RMF 1.1 (mitigation: ADR-005 review trigger)"
  - "Scanner regex change weakens real-key detection (mitigation: criterion #5 regression tests)"
  - "Ambiguity cross-reference-doc vs skill (mitigation: README label distinct)"
  - "Bundled PR scope (mitigation: 4-commit sequencing for bisectability)"
success_criteria_count: 6
END_SKILL_OUTPUT -->
