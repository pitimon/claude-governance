---
name: spec-driven-dev
description: >
  Create a formal specification before implementation.
  Use when: starting any feature larger than a trivial fix, planning a new module,
  or when requirements need clarity before coding begins.
  Developer defines WHAT and constraints, AI generates HOW within guardrails.
  Invoke with /spec-driven-dev to start the spec-driven development workflow.
user-invocable: true
allowed-tools: ["Read", "Grep", "Glob", "Write", "AskUserQuestion"]
---

# Spec-Driven Development

Developer = spec author (defines WHAT + constraints). AI = code generator (implements HOW within guardrails).

## Decision Loop Classification

Before starting, classify the feature using Three Loops:

- **Out-of-Loop** (AI autonomous): Skip spec — trivial fixes, formatting, import organization
- **On-the-Loop** (AI proposes, human approves): Write spec, get approval, implement with oversight
- **In-the-Loop** (human decides): Write spec, human drives design, AI assists implementation

## Workflow

### 1. Understand

- Explore relevant codebase areas (Glob, Grep, Read)
- Clarify requirements with user (AskUserQuestion)
- Reference `DOMAIN.md` for entity definitions and invariants (if present)

### 2. Specify

Write `spec.md` in project root or feature directory using the template below.

### 3. Plan

- Enter Plan Mode to generate implementation plan from spec
- Plan must reference spec acceptance criteria
- Identify files to create/modify

### 4. Implement

- Code to spec in iterations (On-the-Loop: AI proposes, human approves)
- Each iteration should be reviewable
- Follow existing patterns from codebase

### 5. Verify

- Check implementation against each acceptance criterion
- Run tests (unit, integration, E2E as appropriate)
- Validate domain invariants from `DOMAIN.md` are preserved (if present)

---

## Spec Template

Create this as `spec.md` (or `<feature-name>.spec.md`) in the appropriate directory:

```markdown
# Spec: [Feature Name]

## Overview

- **Motivation**: Why this feature exists
- **Success criteria**: How we know it's done

## Requirements

### Functional (MUST)

- [ ] Requirement 1
- [ ] Requirement 2

### Functional (SHOULD)

- [ ] Nice-to-have 1

### Non-Functional

- Performance: [targets]
- Security: [considerations]

## Domain Impact

- **Entities affected**: (reference DOMAIN.md if available)
- **New invariants**: any new constraints introduced
- **API changes**: request/response schema changes

## Constraints

- **Anti-requirements**: what NOT to do
- **Patterns to follow**: existing codebase patterns
- **Dependencies**: external services, libraries
- **Compatibility**: backwards compatibility requirements

## Acceptance Criteria

1. Given [context], when [action], then [result]
2. Edge case: [scenario] -> [expected behavior]
3. Error case: [scenario] -> [expected error handling]

## Verification

- **Unit tests**: [what to test]
- **Integration tests**: [API/service interactions]
- **E2E tests**: [user flows, if applicable]
- **Production validation**: [how to verify in prod]
```

---

## Governance Checklist

Before marking the spec as ready:

- [ ] Decision loop classified (Out/On/In-the-Loop)
- [ ] Domain impact assessed
- [ ] Anti-requirements defined (what NOT to do)
- [ ] Acceptance criteria are testable
- [ ] Breaking changes identified and flagged
