# NotebookLM ↔ Claude Code Workflow

How to use [NotebookLM](https://notebooklm.google.com) (a.k.a. Gemini Notebook) as a
**grounded knowledge base** for this repository, so Claude Code (or Codex) can answer
governance questions from citable sources instead of re-reading every doc each session,
and so the project's own docs can be turned into shareable media.

> **Compositional model:** NotebookLM is the *grounded corpus/source*; Claude Code is the
> *process/orchestrator*. They compose — they do not compete. NotebookLM closes the
> "curated corpus" blind spot; Claude Code drives it with structured, citable queries.

Requires the [`notebooklm-py`](https://pypi.org/project/notebooklm-py/) CLI
(`pip install notebooklm-py`; this doc is written against **v0.4.1**) and a one-time
`notebooklm login` (browser Google OAuth).

## What to push (source corpus)

Only the repo's **narrative markdown** — the prose that explains *what/why/benefits*.
Skip shell/PowerShell hooks, JSON config, tests, `.example` files, and the entire
`plugin/` subtree (it is a byte-identical Codex mirror — pushing it duplicates sources).

Two curated notebooks serve two jobs:

| Notebook | Sources | Purpose |
| --- | --- | --- |
| **corpus** | README, CHANGELOG, all `docs/adr/*`, `docs/compliance/*`, `docs/research/*`, `skills/*/SKILL.md`, `agents/*.md`, `docs/architecture/etclovg-coverage.md` (~29 files) | Grounding — Claude Code queries it during governance/maintenance work |
| **pitch** | README, CHANGELOG, `docs/architecture/etclovg-coverage.md`, `docs/compliance/DSGAI-MAPPING.md`, `docs/INTEGRATION.md` (~5 files) | Promo — leaner set → sharper generated media |

## Build a notebook

```bash
# Create and capture the id — always drive by explicit id, never `notebooklm use`
# (that clobbers your current-context notebook when agents run in parallel).
CORPUS_ID=$(notebooklm create "claude-governance corpus v3.5.0" --json | jq -r .notebook.id)

# Add each markdown file as a titled source (.md is auto-detected as text).
notebooklm source add "./README.md" --title "README.md" -n "$CORPUS_ID" --json
# ...loop over the file list; check each exit code and re-add any failures.

# Confirm every source finished processing.
notebooklm source list -n "$CORPUS_ID" --json | jq -r '.sources[].status' | sort | uniq -c
# want: all "ready", zero "error"
```

## Keeping the corpus fresh (refresh on release)

The corpus does **not** auto-sync — the repo changes, the notebook does not. Refresh it by
hand, not on a schedule; the durable thing is *knowing which files to push*, not a script
(the CLI backend is an unofficial RPC that can break, so a sync script risks becoming dead
code — build one only after a real, repeated refresh need, per friction-first doctrine).

**When to refresh:** on each tagged release, or when any manifest file below materially
changes (a new ADR, a new compliance mapping, a rewritten README). Create a fresh
notebook titled with the new version (e.g. `claude-governance corpus v3.6.0`) rather than
mutating the old one, so each corpus maps to a known repo state.

**Provenance of the current corpus** (update these two lines whenever you rebuild):

- Built from commit **`6cbcae7`** (v3.5.0), 2026-07-19.
- Staleness check: `git log --oneline 6cbcae7..HEAD -- <manifest paths>` — any output means
  the corpus is behind and should be rebuilt.

### Corpus manifest (29 files — the exact set to push)

```
README.md
CHANGELOG.md
CLAUDE.md
docs/INTEGRATION.md
agents/governance-reviewer.md
docs/architecture/etclovg-coverage.md
docs/compliance/DSGAI-MAPPING.md
docs/compliance/EU-AI-ACT-MAPPING.md
docs/compliance/ISO-42001-MAPPING.md
docs/compliance/NIST-AI-RMF-MAPPING.md
docs/research/eu-ai-act-obligations.md
docs/research/nist-ai-rmf-compliance-brief.md
docs/research/nist-ai-rmf-toolkit-prd.md
docs/adr/ADR-001-adopt-governance-framework.md
docs/adr/ADR-002-consequence-based-authorization.md
docs/adr/ADR-003-eu-ai-act-compliance-toolkit.md
docs/adr/ADR-004-iso-42001-framework-selection.md
docs/adr/ADR-005-nist-ai-rmf-cross-reference-doc.md
docs/adr/ADR-006-hook-design-principle-write-vs-edit.md
docs/adr/ADR-007-codex-native-packaging.md
docs/adr/ADR-008-governance-reviewer-model-inherit.md
skills/governance-check/SKILL.md
skills/create-adr/SKILL.md
skills/spec-driven-dev/SKILL.md
skills/governance-setup/SKILL.md
skills/eu-ai-act-check/SKILL.md
skills/iso-42001-check/SKILL.md
skills/eu-ai-act-check/reference.md
skills/iso-42001-check/reference.md
```

**Pitch manifest (5 files — leaner set for promo media):** `README.md`, `CHANGELOG.md`,
`docs/architecture/etclovg-coverage.md`, `docs/compliance/DSGAI-MAPPING.md`,
`docs/INTEGRATION.md`.

Rebuild loop (no script needed — paste the manifest into a file, then loop over it):

```bash
# Save the 29 manifest paths above into files.txt, then:
CORPUS_ID=$(notebooklm create "claude-governance corpus vX.Y.Z" --json | jq -r .notebook.id)
while IFS= read -r f; do
  [ -f "$f" ] || { echo "MISSING: $f"; continue; }
  notebooklm source add "./$f" --title "$f" -n "$CORPUS_ID" --json >/dev/null \
    || echo "FAILED: $f"   # re-add any failures before proceeding
done < files.txt
notebooklm source list -n "$CORPUS_ID" --json | jq -r '.sources[].status' | sort | uniq -c
```

## Objective A — grounded query loop (efficiency)

Use this instead of re-reading docs when you need a cited governance answer:

```bash
# Ask — --json returns the answer plus structured references[] (source_id + cited_text + offsets).
notebooklm ask "What does ADR-002 say about the consequence override?" \
  --json -n "$CORPUS_ID"

# Verify a citation at the page/source level (no external search needed).
notebooklm source fulltext <source_id> -n "$CORPUS_ID"

# Persist the Q&A thread back into the notebook for reproducibility.
notebooklm ask "..." --save-as-note --note-title "research: <topic>" -n "$CORPUS_ID"
# or: notebooklm history --save --note-title "<topic>" -n "$CORPUS_ID"
```

`references[]` gives `{source_id, citation_number, cited_text}` — machine-parseable, so a
verifier step can confirm each claim traces to a real source chunk.

## Objective B — generate promo media (adoption)

Generate from the **pitch** notebook, in your target language, reliable-artifacts first.
All `generate` commands accept `--language <code>` and `--json` (returns a `task_id`).

```bash
PITCH_ID=$(notebooklm list --json | jq -r '.notebooks[] | select(.title=="claude-governance pitch") | .id')

# Reliable (always works): blog post + slide deck
notebooklm generate report --format blog-post --language th -n "$PITCH_ID" --json
notebooklm generate slide-deck --language th -n "$PITCH_ID" --json

# Rate-limit-prone (may need retry after 5-10 min): infographic + video
notebooklm generate infographic --orientation portrait --language th -n "$PITCH_ID" --json
notebooklm generate video --format explainer --language th -n "$PITCH_ID" --json

# Poll, then download to a gitignored dir (promo/ is in .gitignore).
notebooklm artifact list -n "$PITCH_ID"
notebooklm download report      ./promo/pitch-th.md   -n "$PITCH_ID"
notebooklm download slide-deck  ./promo/pitch-th.pptx --format pptx -n "$PITCH_ID"
notebooklm download video       ./promo/pitch-th.mp4  -n "$PITCH_ID"
```

## Reliability & safety notes

- **Reliable:** notebook/source CRUD, `ask`, and `report` / `mind-map` / `data-table`
  generation. **Rate-limit-prone:** `audio`, `video`, `infographic`, `slide-deck` — may
  fail with `GENERATION_FAILED` / `No result found for RPC ID`; wait 5-10 min and retry,
  or fall back to the web UI. Treat media as best-effort, the blog post as the guaranteed
  deliverable.
- **Parallel safety:** always pass explicit `-n <full-uuid>`; never rely on current context.
- **Version lock:** written for CLI v0.4.1. The MCP server / REST server / master-token
  headless auth are upstream-only (0.7.3 / 0.8.0-beta) — upgrade and re-derive flags from
  `notebooklm <cmd> --help` before adopting them.
- **Data governance:** only push already-public repo docs. No secrets, no private data.
