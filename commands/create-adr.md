---
name: create-adr
description: Create an Architecture Decision Record (ADR) to document a technical decision with governance classification and fitness function.
argument-hint: "<decision title>"
allowed-tools: ["Read", "Write", "Glob", "Bash", "AskUserQuestion"]
---

# Create Architecture Decision Record

Generate an ADR for the given decision title.

## Workflow

### 1. Determine ADR Number

Check `docs/adr/` for existing ADRs. Find the highest numbered ADR and increment by 1. If the directory doesn't exist, create it and start at ADR-001.

```bash
ls docs/adr/ADR-*.md 2>/dev/null | sort -t- -k2 -n | tail -1
```

### 2. Gather Context

Ask the user (using AskUserQuestion) for:

**Question 1: Context**
"What problem or situation motivated this decision?"

**Question 2: Decision**
"What did you decide? Describe the chosen approach."

**Question 3: Governance Loop**
Options:
- "Out-of-Loop — AI can implement autonomously (formatting, simple fixes)"
- "On-the-Loop — AI proposes, human approves (features, API changes)"
- "In-the-Loop — Human decides, AI assists (architecture, security, breaking changes)"

### 3. Generate ADR

Write the ADR file to `docs/adr/ADR-NNN-<kebab-case-title>.md` using this template:

```markdown
# ADR-NNN: <Title>

## Status
Accepted

## Date
<today's date in YYYY-MM-DD>

## Context
<user's context answer>

## Decision
<user's decision answer>

## Consequences

### Positive
- <infer 2-3 positive consequences from the decision>

### Negative
- <infer 1-2 trade-offs or downsides>

### Risks
- <infer 1-2 risks>

## Governance
- **Decision Loop**: <selected loop>
- **Fitness Function**: <suggest an automated check to verify this decision is upheld>
- **Review Trigger**: <when should this decision be revisited>
```

### 4. Confirm

Show the user the generated ADR path and a summary. Suggest they review and adjust the consequences section.
