---
name: governance-setup
description: >
  Initialize governance framework in the current project.
  Use when: setting up a new project with governance, adding governance to an existing project,
  or when the user asks to "set up governance", "initialize governance", or "add governance".
  Creates DOMAIN.md, docs/adr/, and optionally installs rules to ~/.claude/rules/.
user-invocable: true
allowed-tools: ["Read", "Write", "Glob", "Bash", "AskUserQuestion"]
---

# Governance Setup

Initialize the governance framework in the current project. Guide the user through each step with confirmations.

## Prerequisites

Check if governance artifacts already exist:

- `DOMAIN.md` in project root
- `docs/adr/` directory
- `~/.claude/rules/governance.md`

Report what exists and what will be created.

## Workflow

### 1. Create DOMAIN.md

If `DOMAIN.md` doesn't exist, ask the user:
"What is this project about? Briefly describe the main entities/domain objects."

Then generate a `DOMAIN.md` using the template from the plugin's `examples/DOMAIN.md.example`, customized with the user's entities. Include:

- Core entities with fields, types, constraints
- Invariants for each entity
- API contract rules (if applicable)
- Data standards

### 2. Set Up ADR Directory

Create `docs/adr/` if it doesn't exist. Copy the ADR template:

```bash
mkdir -p docs/adr
```

Create `docs/adr/ADR-001-adopt-governance-framework.md` as the first ADR documenting the decision to adopt governance.

### 3. Install Rules (Optional)

Ask the user: "Would you like to install governance rules to `~/.claude/rules/`? This enables fitness function checks across all your projects."

Options:

- "Yes — install all 5 rules (governance, coding-style, git-workflow, testing, security)"
- "Just governance rule"
- "Skip — I'll manage rules myself"

If they choose to install, copy from the plugin's `examples/rules/` directory:

```bash
cp ${CLAUDE_PLUGIN_ROOT}/examples/rules/*.md ~/.claude/rules/
```

### 4. Update CLAUDE.md (Optional)

Ask if they want to add a governance section to their project's `CLAUDE.md`. If yes, add:

```markdown
## Decision Autonomy (Three Loops Model)

### Out-of-Loop (AI executes autonomously)

- Code formatting, linting fixes
- Import organization, unused variable removal
- Simple bug fixes with clear root cause

### On-the-Loop (AI proposes, human approves)

- New feature implementation (use Plan Mode)
- API endpoint changes
- Refactoring > 3 files

### In-the-Loop (Human decides, AI assists)

- Architecture decisions
- Security model changes
- Breaking changes
```

### 5. Summary

Print a summary of what was created:

```
Governance initialized:
- DOMAIN.md — domain model (edit to match your entities)
- docs/adr/ — architecture decision records
- docs/adr/ADR-001 — governance adoption record
- ~/.claude/rules/ — fitness function rules (if installed)

Next steps:
1. Edit DOMAIN.md to define your actual entities
2. Run /governance-check to verify your project
3. Use /spec-driven-dev for new features
4. Use /create-adr to record decisions
```
