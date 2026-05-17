# ADR-006: Hook Design Principle — Distinguish Write-new vs Edit-tracked Operations

## Status

Accepted

## Date

2026-05-17

## Context

`claude-governance` ships `PreToolUse` hooks that target file operations (currently `secret-scanner.sh` with matcher `Edit|Write|MultiEdit`). The existing hook scans content regardless of file state — it does the right thing because secret-leak risk applies equally to a brand-new file and an edit to a tracked file.

Adopter feedback from [`pitimon/8-habit-ai-dev#197`](https://github.com/pitimon/8-habit-ai-dev/issues/197) (Adopter #2 report on the v2.15.9 `spec-digest-pattern` guide) surfaced a different shape of hook that could be added to this plugin or to user-side hook configurations: **a hook that blocks creation of unnecessary `.md` files**. The motivating concern is preventing untracked doc-sprawl (planning notes, ad-hoc Markdown drafts), and the natural matcher is `Edit|Write|MultiEdit` on `.md` files.

Such a hook category, written naively, would conflate two structurally different operations:

| Operation        | Tool form                                                                  | What it does                          | Should the hook block?                                           |
| ---------------- | -------------------------------------------------------------------------- | ------------------------------------- | ---------------------------------------------------------------- |
| **Create-new**   | `Write` against a path that **does not yet exist** (or is not git-tracked) | Brings a brand-new file into the repo | Maybe — depends on policy ("no untracked planning docs")         |
| **Edit-tracked** | `Write` / `Edit` / `MultiEdit` against a path that **is git-tracked**      | Updates an existing committed file    | **Never (by default)** — these are legitimate maintenance writes |

When the two are conflated under a single matcher, every legitimate doc-update workflow collides with the doc-sprawl preventer. Concrete examples that hit this if the distinction is not drawn:

- `pitimon/8-habit-ai-dev` v2.16.0 `/save-spec` skill scaffolds `SPEC.md` once, but the project-orientation hub pattern instructs users to update §4 (Current state) on every task — those updates are `Write`/`Edit` against a tracked file.
- `pitimon/8-habit-ai-dev` v2.15.2 `current-state.md` convention is the same shape — manual `Edit` against a tracked file is the canonical update pattern.
- `CHANGELOG.md` entries on every release.
- ADR drafts (the file is tracked once created; revisions are `Edit`-tracked).
- Runbook revisions in operational repos.

Forcing every adopter to maintain a per-file allowlist does not scale — and the architectural fix is cheap if applied at the hook layer.

## Decision

**Any PreToolUse hook in `claude-governance` that targets file operations (or any plugin in this ecosystem with the same shape) MUST distinguish create-new from edit-tracked before deciding to block.**

The distinction is mechanical, not semantic — a hook can satisfy this principle by checking one of:

1. **File existence**: if the target path does not exist on disk, treat as create-new.
2. **Git-tracked status**: if `git ls-files --error-unmatch <path>` exits non-zero, treat as create-new.

A hook can legitimately block create-new operations for policy reasons (e.g. "no untracked Markdown planning docs") while allowing edit-tracked operations unconditionally.

### Reference implementation pattern

```bash
#!/usr/bin/env bash
# PreToolUse hook — block .md create-new but allow edit-tracked
# Matcher in hooks.json: "Edit|Write|MultiEdit"

# Claude Code passes tool args as JSON on stdin
INPUT=$(cat)
TARGET_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only enforce for .md files
case "$TARGET_PATH" in
  *.md) ;;
  *) exit 0 ;;
esac

# Distinguish create-new vs edit-tracked
if [ -f "$TARGET_PATH" ] && git ls-files --error-unmatch "$TARGET_PATH" >/dev/null 2>&1; then
  # Edit-tracked: allow unconditionally
  exit 0
fi

# Create-new: apply your policy (here: block with informative message)
echo "Blocked: cannot create new .md file at $TARGET_PATH." >&2
echo "Reason: <your policy here, e.g. 'untracked planning docs forbidden'>." >&2
echo "If this is intentional, commit the file first or update the hook policy." >&2
exit 1
```

The `git ls-files --error-unmatch` check is the **authoritative test for "is this path under version control"**. The `-f "$TARGET_PATH"` check is a cheap pre-filter — the disk check covers untracked existing files (which should also be treated as outside the create-new policy in most cases; adjust per policy).

### Existing hook audit

`hooks/secret-scanner.sh` (the only file-operation hook currently shipped) does **NOT** need this distinction — it scans content regardless of file state because secret-leak risk applies equally to new and existing files. ADR-006 is forward-looking guidance for **future hooks** in this plugin or downstream user configurations.

### What this ADR does NOT decide

- It does not require `claude-governance` to ship a `.md` create-new blocker hook. That is a separate proposal that would need its own discussion (motivating use case, opt-in vs opt-out, scope).
- It does not constrain content-scanning hooks (the existing `secret-scanner.sh` shape). Content scanning is orthogonal to file-existence checks.
- It does not apply to hooks that target non-file tools (Bash matchers, MCP matchers, etc.).

## Consequences

### Positive

- Future `.md` (or any extension)-targeting hooks in `claude-governance` ship with a documented design constraint, preventing the conflation friction surfaced in 8-habit-ai-dev#197.
- The reference implementation pattern lowers the cost of writing a correct hook from "spend a session debugging adopter complaints" to "copy the snippet".
- Adopters with hardened doc-blocker hooks elsewhere in their workspace have a published architectural principle to point to when filing upstream issues.

### Negative

- Hook authors now have one extra check to think about, with two acceptable mechanical answers (existence test vs `git ls-files`). Trade-off accepted — the alternative is friction-debugging downstream.

### Risks

- A hook implementing only the `-f` existence check (without `git ls-files`) will incorrectly allow untracked existing files (e.g. a `.gitignore`'d Markdown draft). Policy authors should pick `git ls-files` when the intent is "block anything not in version control", or pick `-f` when the intent is "block creation of files that don't exist yet". Both are acceptable per the principle; the choice depends on what "tracked" means for the policy.
- Performance: `git ls-files --error-unmatch` is a subprocess call. For high-frequency hooks, cache or batch as needed. The reference implementation accepts the cost because PreToolUse hooks fire at human-edit cadence, not at machine cadence.

## Governance

- **Decision Loop**: On-the-Loop — AI proposes future hooks following this principle; humans review hook design at PR time.
- **Fitness Function**: When reviewing any new PreToolUse hook PR that targets file operations, the reviewer MUST check that the hook either (a) is content-scanning (operates the same on create-new and edit-tracked), or (b) explicitly distinguishes the two cases using one of the two mechanical tests above.
- **Review Trigger**: Any new hook added to `hooks/hooks.json` with a `matcher` containing `Write`, `Edit`, or `MultiEdit`. Also: any cross-plugin issue citing this ADR (e.g. [`pitimon/8-habit-ai-dev#197`](https://github.com/pitimon/8-habit-ai-dev/issues/197) item 4 is the motivating precedent).

## References

- Motivating adopter report: [`pitimon/8-habit-ai-dev#197`](https://github.com/pitimon/8-habit-ai-dev/issues/197) (Adopter #2 friction notes on the v2.15.9 spec-digest-pattern guide)
- Tracking issue: [`pitimon/claude-governance#34`](https://github.com/pitimon/claude-governance/issues/34) (this ADR closes it)
- Companion stop-gap note in 8-habit-ai-dev: [`guides/spec-digest-pattern.md`](https://github.com/pitimon/8-habit-ai-dev/blob/main/guides/spec-digest-pattern.md) "Adopting alongside doc-blocker hooks" section
- Plugin boundary statement: [`pitimon/8-habit-ai-dev/CLAUDE.md` lines 50-67](https://github.com/pitimon/8-habit-ai-dev/blob/main/CLAUDE.md) — runtime enforcement belongs in `claude-governance`; workflow discipline belongs in `8-habit-ai-dev`. This ADR is correctly scoped here.
