# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
