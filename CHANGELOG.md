# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
