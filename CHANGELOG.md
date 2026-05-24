# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.3.6] - 2026-05-25

### Changed

- **Institutionalize the ETCLOVG README↔canonical mirror-sync rule** (issue [#46](https://github.com/pitimon/claude-governance/issues/46), PR [#47](https://github.com/pitimon/claude-governance/pull/47)). v3.3.5 PR [#44](https://github.com/pitimon/claude-governance/pull/44) inlined the 7-layer ETCLOVG verdict table in `README.md` for adopter discoverability, but the canonical map's Maintenance section did not acknowledge the mirror — so a future ADR that shifted a layer's `Status` could update the canonical table and silently leave the README copy stale (same doc-drift failure class that v3.3.5 PR [#43](https://github.com/pitimon/claude-governance/pull/43) just fixed). Two surgical hunks (3 lines total, additive only):
  - `docs/architecture/etclovg-coverage.md` Maintenance section gains a **"README mirror sync"** bullet declaring this doc the **single source of truth** and requiring any layer-`Status` change to update the README table in the same PR.
  - `README.md` § "Agent Harness Coverage (ETCLOVG)" carries an HTML comment above the section pointing back to the canonical SSOT and citing #46.

  No table row / count / verdict moved. Both tables remain consistent (Strong=1 G, Partial=3 C/L/V, None=1 O, OOS=2 E/T). This is a fitness-function-style expectation (per the canonical map's "not enforced by a CI check" language); a CI row-count assertion is held back per ADR-014 friction-first discipline (in `8-habit-ai-dev`) — promote to "ship" only on a second drift incident.

### Verification

- `bash tests/validate-plugin.sh --skip-install-check` → PASS 79 / FAIL 0 / SKIP 1 (CI signal intact).
- `bash tests/test-secret-scanner.sh` → PASS 40 / FAIL 0.
- `bash tests/test-release-qa.sh` → PASS 162 / FAIL 0 / WARN 0.

No production code, skill, hook, or runtime change — docs-only patch release for drift prevention. Consistent with the v3.3.2 / v3.3.3 / v3.3.5 docs-only release precedent.

## [3.3.5] - 2026-05-25

### Changed

- **README Architecture diagram**: converted from `mermaid` to **Unicode box-drawing ASCII** ([#43](https://github.com/pitimon/claude-governance/pull/43)). Matches the existing house style at `README.md:L248-255` (the spec-driven-dev diagram already used Unicode box-drawing chars). Same content as the prior mermaid (Always-On / On-Demand / Config + Compliance Anchors), now rendered as static text that displays in any markdown viewer without requiring a mermaid renderer (better for raw README in forks, mirrors, terminal previews, and `gh repo view`).
- **README drift refresh** to current shipped state ([#43](https://github.com/pitimon/claude-governance/pull/43)):
  - `tests/validate-plugin.sh` check count: `53+` → `80` (79 PASS + 1 SKIP in CI).
  - `tests/test-secret-scanner.sh` test count: `34` → `40` tests.
  - `tests/test-release-qa.sh` clarified as "local-only, not in CI" (per [#40](https://github.com/pitimon/claude-governance/issues/40) / v3.3.4).
  - Companion plugin tested-against versions: `8-habit-ai-dev` `2.15.0` → **`2.18.6`**, `devsecops-ai-team` `10.10.0` → **`10.14.1`**.

### Added

- **README inline ETCLOVG coverage table** ([#44](https://github.com/pitimon/claude-governance/pull/44)). New `### Agent Harness Coverage (ETCLOVG)` subsection under Architecture surfaces the per-layer verdict directly in the README:
  - Per-layer table (E / T / C / L / O / V / G) with Status + "What ships today" + Gap / Why not.
  - Coverage summary: `Strong` × 1 (G), `Partial` × 3 (C, L, V), `None` × 1 (O), `OOS-charter` × 1 (E), `OOS-plugin-boundary` × 1 (T).
  - Friction-first reminder (ADR-014 in `8-habit-ai-dev`) — `Partial` is not an invitation to expand.
  - Adopter shorthand — pair with `pitimon/devsecops-ai-team` for **E** (sandbox) or **T** (MCP) coverage.

  Content mirrors `docs/architecture/etclovg-coverage.md` (the canonical SSOT); the detail doc remains authoritative for evidence and maintenance contracts.

### Verification

- `bash tests/validate-plugin.sh --skip-install-check` → PASS 79 / FAIL 0 / SKIP 1 (CI signal intact).
- `bash tests/test-secret-scanner.sh` → PASS 40 / FAIL 0 (no scanner regression).
- `bash tests/test-release-qa.sh` → PASS 162 / FAIL 0 / WARN 0 (local QA intact).

No production code, skill, hook, or runtime change — README-only patch release for documentation accuracy and Architecture-diagram portability (precedent: v3.3.2 README-only release, v3.3.3 docs-only release).

## [3.3.4] - 2026-05-25

### Fixed

- **`tests/test-release-qa.sh`** — refresh stale local QA script (issue #40). The file was pinned to `v3.0.0` and one assertion contradicted the shipped v3.3.0 scanner fix (#29), reporting 2 FAIL / 1 WARN on direct run and disagreeing with `tests/test-secret-scanner.sh:120` about correct scanner behavior. The script is **not** in CI (`.github/workflows/validate.yml` runs only `validate-plugin.sh` + `test-secret-scanner.sh`), so the v3.3.3 release gate was always green — this fix removes a latent trap if the script is ever re-promoted to a gate.
  - **Version assertion** → regex-based semver check (`^[0-9]+\.[0-9]+\.[0-9]+$`) instead of frozen `== "3.0.0"`.
  - **`sk- OpenAI` BLOCK fixture** → realistic key with digits, matching the digit requirement added in #29. String split via adjacent literals keeps the hook's own scanner from flagging the test source while bash assembles the full key at runtime.
  - **Skill-count assertion** → `>=4` baseline instead of frozen `-eq 4` (skills are intentionally additive).
  - **Header banner** trimmed to "QA Summary"; historical `vN.N.N` comments documenting when patterns were introduced are kept as audit trail.

### Verification

- `bash tests/test-release-qa.sh` → **PASS 162 / FAIL 0 / WARN 0** (was 159/2/1; matches reporter's claim).
- `bash tests/test-secret-scanner.sh` → PASS 40 / FAIL 0 (no sibling regression).
- `bash tests/validate-plugin.sh --skip-install-check` → PASS 79 / FAIL 0 / SKIP 1 (CI signal intact).

## [3.3.3] - 2026-05-24

### Added

- **`docs/architecture/etclovg-coverage.md`** — ETCLOVG 7-layer agent-harness taxonomy coverage map. Anchors scope decisions for future ADRs by making explicit per-layer status:
  - `G` (Governance) — **Strong** (primary plugin focus; Three Loops, secret-scanner, governance-reviewer, 31 governance checks, 4 compliance mappings)
  - `V` (Verification), `L` (Lifecycle), `C` (Context+Memory) — **Partial**
  - `O` (Observability) — **None** (not in scope today)
  - `E` (Execution / Sandbox) — **OOS-charter** (read-only-guidance principle, `pitimon/8-habit-ai-dev/CLAUDE.md` §50-67)
  - `T` (Tooling / MCP) — **OOS-plugin-boundary** (routed to `pitimon/devsecops-ai-team`, memory observation #233270)

  Source taxonomy: NotebookLM notebook `0f90fcee-b566-4a0b-919a-3df1aa7443cb` ("Agent Harness Engineering 202605", 48 sources, 2026-05-24). Drop date for re-evaluation: 2026-11-26 (6mo per ADR-016-style discipline). Reference document — not an ADR; no decision change. README architecture section + ADR-006 References now link to it.

### Changed

- **`README.md`** — Project Structure tree now includes `docs/architecture/`; a one-line forward link under the architecture mermaid points to the coverage map.
- **`docs/adr/ADR-006-hook-design-principle-write-vs-edit.md`** — References section now cites the coverage map; ADR-006 is the canonical artifact under the `G` layer's hook-design discipline.

## [3.3.2] - 2026-05-24

### Fixed

- **README ADR inventory drift** (closes [#33](https://github.com/pitimon/claude-governance/issues/33)) — Two README diagrams listed only ADR-001 and ADR-002 while the on-disk catalog had grown to 6 records (ADR-003 EU AI Act, ADR-004 ISO 42001, ADR-005 NIST AI RMF, ADR-006 hook design principle):
  - **Project Structure tree** (around line 336) now lists all 6 ADR files individually.
  - **Architecture mermaid** node `D2` (around line 283) now reads `ADR Catalog (6 records)` instead of `ADR-001 + ADR-002` — generic label future-proofs the diagram against the next ADR landing.

  Pre-existing drift caught during the `8-habit-reviewer` audit of PR #32 (2026-05-11); deferred for 14 days. No runtime change, no behavior change for client installs — patch release for README-only fix per the v3.3.1 (`c667f89`) ADR-006 docs-only release precedent.

## [3.3.1] - 2026-05-17

### Added

- **ADR-006: Hook Design Principle — Distinguish Write-new vs Edit-tracked Operations** (closes [#34](https://github.com/pitimon/claude-governance/issues/34)) — forward-looking architectural guidance for any PreToolUse hook in this plugin (or downstream user configurations) that targets file operations. Hooks MUST distinguish create-new from edit-tracked before deciding to block, using one of two mechanical tests:
  1. **File existence**: target path does not exist on disk → create-new
  2. **Git-tracked status**: `git ls-files --error-unmatch <path>` exits non-zero → create-new

  Includes a reference bash implementation pattern for a `.md` create-new blocker that allows edit-tracked unconditionally.

  Motivating use case: [`pitimon/8-habit-ai-dev#197`](https://github.com/pitimon/8-habit-ai-dev/issues/197) item 4 — Adopter #2 friction on the v2.15.9 spec-digest-pattern guide. A naive `.md`-blocker hook conflates new-file creation with legitimate updates to tracked files (SPEC.md §4 save-point updates, CHANGELOG entries, current-state.md revisions, ADR drafts).

  **Existing hook audit**: `hooks/secret-scanner.sh` does NOT need this distinction — it scans content regardless of file state because secret-leak risk applies equally to new and existing files. ADR-006 is forward-looking guidance, not a corrective change.

### Pattern

**Preventive design guidance, not reactive patching.** A friction shape was surfaced in a downstream plugin's adopter report. The architectural fix lives in the hook layer (this plugin) per the documented plugin boundary. ADR-006 records the principle before any concrete `.md`-targeting hook ships, so future hook authors have a documented constraint to work against and adopters have a published architectural principle to point to in upstream issues.

## [3.3.0] - 2026-05-03

### Added

- NIST AI RMF 1.0 compliance toolkit (closes #29):
  - `docs/compliance/NIST-AI-RMF-MAPPING.md` — first-class cross-reference doc with 4-row function-level mapping (NIST Govern/Map/Measure/Manage ↔ ISO 42001 Annex A clauses ↔ EU AI Act Articles), cited Microsoft-authored ISO 42001 crosswalk URL with SHA-256 verification snippet (link-rot mitigation), EU AI Act gap list (Art. 5/22/43/48-49/71/73/99), NIST AI 600-1 (GenAI Profile) ↔ DSGAI cross-references, 8-habit-ai-dev pointers for runtime concerns, NIST.AI.100-1 DOI as permanent authoritative anchor
  - `docs/adr/ADR-005-nist-ai-rmf-cross-reference-doc.md` — On-the-Loop framework selection rationale; structural fitness function (`validate-plugin.sh` section 3.13); multi-trigger review (customer ask OR NIST 1.1+ OR regulator mandate OR third standalone skill request)
  - `docs/research/nist-ai-rmf-compliance-brief.md` — Deep + Compare research (verified via `8-habit-ai-dev:research-verifier` agent: 6/7 claims VERIFIED)
  - `docs/research/nist-ai-rmf-toolkit-prd.md` — 10 EARS criteria, 6 success criteria, 5 risks, 4-commit sequencing constraint
  - Bidirectional cross-references added to `docs/compliance/ISO-42001-MAPPING.md` and `docs/compliance/EU-AI-ACT-MAPPING.md` (tailored 2-column tables per host audience)
  - `tests/validate-plugin.sh` section 3.13 — 4 new structural gates (NIST mapping exists + ADR-005 exists + ISO mapping cites NIST mapping by path + EU AI Act mapping cites NIST mapping by path)

### Fixed

- Secret scanner OpenAI/Stripe regex false-positive (issue #29 sub-scope): the `sk-` BLOCK pattern matched 22-char compounds inside English phrases (specifically the canonical NIST AI RMF home-page URL slug), blocking writes that cited that URL. Discovered while writing the v3.3.0 NIST AI RMF research brief and PRD (the brief itself had to use a heredoc workaround twice). Two-stage check now: (a) base regex with left word boundary `(^|[^A-Za-z])sk-...` rejects matches preceded by a letter, (b) matched text must contain at least one digit (real OpenAI/Stripe/Anthropic keys are alphanumeric with digits by construction). The 3 affected patterns (`sk-`, `sk-proj-`, `sk-ant-`) moved from `BLOCK_PATTERNS` to a new `DIGIT_REQUIRED_BLOCK_PATTERNS` array with its own loop. Other BLOCK patterns (Bearer, JWT, GitHub PAT, AWS, etc.) retain original single-stage behavior. Test suite: 36 → 40 tests, 40 PASS / 0 FAIL. The v3.0.x 20-char length floor is preserved.

### Notes

- This release is the first `claude-governance` compliance framework that lands as a **cross-reference doc instead of a standalone skill** — see ADR-005 for the demand-first rationale (extends ADR-004's pattern). When a third standalone skill is requested, the consolidated lesson `~/.claude/lessons/2026-05-03-claude-governance-compliance-toolkit-arc.md` action item #3 commits to extracting the meta-pattern into a `compliance-framework-template/` skeleton at that point
- "NOT A CERTIFICATION GUARANTEE" disclaimer (consistent with ISO 42001 voluntary-not-regulatory precedent from v3.2.0)
- Microsoft-authored ISO 42001 crosswalk URL cited as canonical mapping (no re-derivation of 70+ subcategory mappings)

### Deferred

- Standalone `/nist-ai-rmf-check` skill — Tier 2 deferred per ADR-005 demand-first pattern
- `compliance-framework-template/` skeleton extraction — Tier 2 deferred until a third standalone skill is requested (NIST as cross-ref doc doesn't count as a skill data point)
- ISO/IEC 42005:2024 (AI impact assessment) — Tier 3
- README.md updates (add `/iso-42001-check` + `/eu-ai-act-check` On-Demand commands + Compliance Frameworks subsection + new NIST cross-ref doc row) — same precedent as v3.1.0 + v3.2.0 (formatter rewrites all tables, 138+ lines noise). Combined doc-only follow-up PR

## [3.2.0] - 2026-05-03

### Added

- ISO/IEC 42001:2023 AI Management System (AIMS) compliance toolkit (closes #27):
  - `/iso-42001-check` skill — 38-control tiered checklist (17 MUST + 15 SHOULD + 6 COULD) covering Annex A clauses A.2-A.10, with mode-selection scope-check (`--scope`) supporting four postures (certification / self-attestation / internal-alignment / customer-requirement) and conditional A.10 tier promotion based on third-party AI sourcing
  - `skills/iso-42001-check/reference.md` — full Annex A control list with Tier × Status orthogonal axes (3×3 matrix), tier heuristic table, and per-clause checklist
  - `docs/compliance/ISO-42001-MAPPING.md` — coverage scorecard (12 ENFORCED / 20 EVIDENCE-ONLY / 6 GAP, 0 MUST+GAP), per-clause status tables, Standards Family section (ISO 23894 / 5338 / 22989 / 38507 as informative cross-refs), end-to-end self-attestation example, EU AI Act + DSGAI cross-references
  - `docs/adr/ADR-004-iso-42001-framework-selection.md` — On-the-Loop framework selection rationale; structural validator gates rejected numeric MUST-count circularity; A.10 conditional-MUST mechanism documented
  - `tests/validate-plugin.sh` section 3.12 — structural fitness function (file presence, 9 clause headings, every clause has ≥1 MUST, MUST items cite ≥5 distinct skills, NOT A CERTIFICATION GUARANTEE disclaimer present, DSGAI cross-ref section present)
  - Bidirectional cross-references added to `docs/compliance/DSGAI-MAPPING.md` and `docs/compliance/EU-AI-ACT-MAPPING.md`

### Notes

- ISO/IEC 42001:2023 is paywalled (~CHF 174). All control titles are paraphrased from secondary sources (ISMS.online + Cyberzoni, verified 2026-05-03); no `docs/research/` analogue ships and no verbatim ISO 42001 text appears in this plugin
- "NOT A CERTIFICATION GUARANTEE" disclaimer (not "NOT LEGAL ADVICE") reflects ISO 42001's voluntary, certifiable nature — distinct from EU AI Act's regulatory enforceability
- ISO 23894 (risk management), 5338 (lifecycle), 22989 (vocabulary), 38507 (board governance) are informative cross-references only; standalone skills will be added if user demand emerges per ADR-004 Review Trigger

### Deferred

- README.md updates (add `/iso-42001-check` + `/eu-ai-act-check` to On-Demand commands table, add Compliance Frameworks subsection) — deferred to a doc-only follow-up PR. Same precedent as v3.1.0 and #23: the local Markdown formatter rewrites all tables on every Edit, producing 138+ lines of unrelated noise.

## [3.1.0] - 2026-05-02

### Added

- EU AI Act compliance toolkit migrated from `pitimon/8-habit-ai-dev` v2.3.0 (closes #21):
  - `/eu-ai-act-check` skill — 9-obligation tiered checklist (25 MUST + 27 SHOULD + 8 COULD) covering Articles 9-15 of Regulation (EU) 2024/1689, with scope pre-flight (`--scope`) for Annex III high-risk classification and EU deployment confirmation
  - `docs/research/eu-ai-act-obligations.md` — primary-source verified Articles 9-15 quotes (verbatim from 8-habit-ai-dev)
  - `docs/compliance/EU-AI-ACT-MAPPING.md` — Article-to-skill mapping guide rewritten for the governance plugin's skill set; routes 4 of 9 obligations to governance skills (1, 2, 3, 5, 6, 8, 9) and explicitly marks 2 as External (4 record-keeping, 7 accuracy — runtime concerns)
  - `docs/adr/ADR-003-eu-ai-act-compliance-toolkit.md` — migration provenance + plugin boundary rationale (8-habit = workflow discipline, claude-governance = compliance enforcement + framework mappings)
- Bidirectional cross-references between EU AI Act Article 15 ¶5 and OWASP DSGAI04/DSGAI11 controls (added to both `EU-AI-ACT-MAPPING.md` Obligation 9 and `DSGAI-MAPPING.md` new "EU AI Act Cross-References" section)
- 8 new structural validation checks in `tests/validate-plugin.sh` (53 → 64) covering reference.md, research file, mapping file, ADR-003 existence; tier integrity (≥25 MUST items); NOT LEGAL ADVICE disclaimer; all 9 obligation sections; DSGAI cross-reference section
- 2 new keywords in `plugin.json`: `eu-ai-act`, `compliance` (13 → 15)

### Changed

- Skill references inside the migrated EU AI Act toolkit rewritten from 8-habit-ai-dev's workflow skills (`/security-check`, `/design`, `/build-brief`, `/monitor-setup`, `/reflect`, `/review-ai`, `/requirements`, `/ai-dev-log`) to claude-governance equivalents (`/governance-check`, `/spec-driven-dev`, `/create-adr`, `governance-reviewer` agent) per ADR-003 plugin boundary
- Covey/8-habit framing dropped from the migrated skill (no `Habit: H1+H8` markers; "Step 3 — Habit Checkpoint" → "Step 3 — Conscience Check"); the value preserved is the 9-obligation checklist + scope pre-flight + verified quotes, not the habit framing
- `EU-AI-ACT-MAPPING.md` end-to-end example now shows the two-plugin flow (workflow discipline via 8-habit-ai-dev + compliance enforcement via claude-governance)

### Coordination

- `pitimon/8-habit-ai-dev` v2.3.1 (separate follow-up release, same maintainer) will delete the migrated files (`skills/eu-ai-act-check/`, `docs/research/eu-ai-act-obligations.md`, `guides/eu-ai-act-mapping.md`) and add ADR-006 mirroring this migration. Hard rule: do NOT merge that PR before this v3.1.0 ships.

### Deferred

- README.md tagline + EU AI Act badge — deferred to a doc-only follow-up PR. The local Markdown formatter rewrites all tables on every Edit, producing 140+ lines of unrelated noise. Same precedent as #23.

## [3.0.1] - 2026-05-02

### Fixed

- Secret scanner false-positive on prose mentioning `Authorization` or `mongodb` keywords (closes #23). `${ENTRY%%:*}` (longest-suffix) cut at the first colon, degrading two pattern regexes — `mongodb(\+srv)?://[^\s]+` and `Authorization:\s*Bearer\s+...{20,}` — to their bare keyword prefixes at runtime, blocking documentation that merely mentioned the words. Replaced with `${ENTRY%:*}` (shortest-suffix) at both BLOCK and WARN loop sites.

### Added

- 2 regression tests in `tests/test-secret-scanner.sh` for the keyword-in-prose case (Auth header, DB brand) — total 36 tests (was 34).
- Convention comment in `hooks/secret-scanner.sh` noting that pattern descriptions must not contain `:`.

## [3.0.0] - 2026-03-24

### Added

- Shadow AI policy template with approved/prohibited tools, data rules, approved alternatives [DSGAI03] (closes #15)
- AI supply chain security checklist for model vetting, dependency pinning, unsafe deserialization [DSGAI04] (closes #16)
- Telemetry & logging hygiene governance checks — flags prompt/context logging in production [DSGAI14] (closes #17)
- Consequence-based authorization — extends Three Loops with blast radius dimension [DSGAI19] (closes #18)
- ADR-002: Consequence-Based Authorization — documents Three Loops extension with 4 consequence levels
- Cross-context bleed detection — session isolation + multi-tenant separation checks [DSGAI11] (closes #19)
- 9 new governance checks (total: 31 across pre-commit/pre-pr/architecture)
- 3 new security rule sections (AI artifacts, telemetry hygiene, session isolation)
- Shadow AI policy step in `/governance-setup` wizard (step 3.5)
- Consequence Override in session-start: irreversible operations always In-the-Loop

### Changed

- DSGAI-MAPPING.md: 11 controls implemented (up from 6), coverage gaps reduced to 4
- Three Loops model extended from 1D (task type) to 2D (task type x blast radius)
- Session-start context updated with consequence dimension (~360 tokens)
- **MAJOR**: governance-check grows from 22 to 31 checks with 5 new DSGAI controls

## [2.3.0] - 2026-03-24

### Added

- OWASP DSGAI Tier 1 compliance — 6 controls mapped to governance framework (closes #14)
- Secret scanner BLOCK/WARN architecture — credentials BLOCK (exit 2), PII WARN (exit 0 + stderr) (closes #9)
- 5 new credential BLOCK patterns: Bearer token, Authorization header, oauth_token, refresh_token, client_secret (closes #11)
- 3 PII WARN patterns: email address, SSN, credit card number [DSGAI01] (closes #9)
- `tests/test-secret-scanner.sh` — 34 pattern-by-pattern tests in CI (closes #20)
- Plugin/MCP security architecture checks with least-privilege validation [DSGAI06] (closes #10)
- Context minimization architecture checks [DSGAI15] (closes #12)
- Agent credential hygiene checks in governance-check and governance-reviewer [DSGAI02] (closes #11)
- `examples/DATA-CLASSIFICATION.md.example` — data sensitivity template with AI/LLM data flows [DSGAI07] (closes #13)
- `examples/mcp-security-checklist.md` — MCP/plugin security vetting checklist [DSGAI06] (closes #10)
- `docs/compliance/DSGAI-MAPPING.md` — OWASP DSGAI control-by-control compliance matrix (closes #14)
- DSGAI cross-references (`[DSGAI##]`) in governance-check and governance-reviewer output
- Data classification step in `/governance-setup` workflow (step 3)
- Agent & Plugin Security section in `examples/rules/security.md`
- PII Protection section in `examples/rules/security.md`

### Changed

- Secret scanner refactored to dual-loop architecture: BLOCK_PATTERNS (25 patterns) + WARN_PATTERNS (3 patterns)
- Session-start hook updated with DSGAI02 credential hygiene and DSGAI15 context minimization reminders
- `examples/rules/governance.md` expanded with DSGAI-tagged checks for credentials, PII, plugin security, context minimization

### Fixed

- JWT pattern threshold reduced from `{20,}` to `{15,}` to match real-world JWT header lengths

## [2.2.1] - 2026-03-19

### Added

- Scope and When to Use sections in `create-adr`, `governance-setup`, and `spec-driven-dev` skills

### Fixed

- `sk-`, `sk-proj-`, `sk-ant-` regex patterns now include hyphens (`[A-Za-z0-9_-]`) to match real API keys (#6)

## [2.2.0] - 2026-03-19

### Added

- 9 new secret patterns: `sk-ant-*` (Anthropic), private key blocks, JWT tokens, Google API keys, Azure connection strings, MongoDB URIs, `token=`, `GITHUB_TOKEN=`, `GH_TOKEN=` (closes #1, #3)
- Python3 availability check in secret scanner — warns instead of silently failing (closes #2)
- `scripts/bump-version.sh` — single-command version bump across plugin.json, marketplace.json, CHANGELOG.md
- `docs/adr/ADR-001-adopt-governance-framework.md` — documents why and how the governance framework was adopted
- Language-agnostic governance checks: project type detection (JS/TS, Python, Go, Rust) with language-appropriate validation, debug print, and dangerous function patterns
- Scope and When to Use sections in both `/governance-check` (quick checklist) and `governance-reviewer` agent (deep review) with cross-references
- Scanner limitations documentation in README with complementary tool recommendations (closes #5)
- `.gitignore` patterns for `.p12`, `.pfx`, `credentials.json`, `service-account*.json`, IDE dirs, `!.env.example` exception (closes #4)
- Validation check for `scripts/bump-version.sh` existence in `validate-plugin.sh`

### Changed

- Secret scanner error message now shows multi-language env var examples (JS, Python, Go)
- Session-start hook updated with expanded secret patterns and language-neutral terminology
- `governance.md` rules template expanded with multi-language validation and debug print patterns
- `governance-reviewer` agent now detects project language and applies language-specific checks

### Fixed

- `grep` crash on private key pattern (`-----BEGIN`) by using `--` argument separator

## [2.1.1] - 2026-02-24

### Fixed

- `validate-plugin.sh`: replace post-increment `((PASS++))` with pre-increment `(( ++PASS ))` to prevent `set -euo pipefail` exit on bash 5.x (Ubuntu CI)

## [2.1.0] - 2026-02-22

### Added

- CI/CD validation via `.github/workflows/validate.yml` and `tests/validate-plugin.sh`
- `skills` field in plugin.json pointing to `./skills/`
- Expanded keywords from 5 to 13 for better marketplace discovery
- `user-invocable: true` and `allowed-tools` frontmatter to all skills
- `.gitignore` for secrets and OS files
- This CHANGELOG

### Changed

- Moved `commands/governance-check.md` → `skills/governance-check/SKILL.md`
- Moved `commands/create-adr.md` → `skills/create-adr/SKILL.md`
- Updated README.md and CLAUDE.md to reflect new structure
- Version bump to 2.1.0

### Removed

- `commands/` directory (consolidated into `skills/`)
- Duplicate `.claude-plugin/hooks/hooks.json` (canonical copy lives in `hooks/`)

## [2.0.0] - 2026-02-22

### Added

- Hooks system: `session-start.sh` (governance context injection), `secret-scanner.sh` (blocks hardcoded secrets)
- Commands: `/governance-check` (fitness function runner), `/create-adr` (ADR generator)
- Skills: `/governance-setup` (project initialization wizard)
- Agent: `governance-reviewer.md` (compliance review)
- 5 rules templates in `examples/rules/` (governance, coding-style, git-workflow, testing, security)
- `examples/project-claude-md.example` template
- `scripts/install-rules.sh` installer

### Changed

- Restructured README.md with architecture diagram, token budget, and comprehensive docs

## [1.0.0] - 2026-02-22

### Added

- Initial plugin with spec-driven-dev skill
- DOMAIN.md.example template
- governance-rule.md example
- adr-template.md example
- Plugin metadata (plugin.json, marketplace.json)
- MIT License
