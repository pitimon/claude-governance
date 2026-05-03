# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
