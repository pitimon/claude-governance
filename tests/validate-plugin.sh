#!/usr/bin/env bash
# validate-plugin.sh — Structural integrity tests for claude-governance plugin
# Usage: bash tests/validate-plugin.sh [--skip-install-check]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/.claude-plugin"
CODEX_PLUGIN_DIR="$REPO_ROOT/.codex-plugin"
CODEX_MARKETPLACE="$REPO_ROOT/.agents/plugins/marketplace.json"
CODEX_CHILD_DIR="$REPO_ROOT/plugin"
SKILLS_DIR="$REPO_ROOT/skills"
HOOKS_DIR="$REPO_ROOT/hooks"
CLAUDE_HOME="${HOME}/.claude"

PASS=0
FAIL=0
SKIP=0
SKIP_INSTALL=false

[[ "${1:-}" == "--skip-install-check" ]] && SKIP_INSTALL=true

# --- Helpers ---

pass() { (( ++PASS )); printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { (( ++FAIL )); printf "  \033[31mFAIL\033[0m %s\n" "$1"; }
skip() { (( ++SKIP )); printf "  \033[33mSKIP\033[0m %s\n" "$1"; }
section() { printf "\n\033[1;36m[%s]\033[0m\n" "$1"; }

json_field() {
  python3 -c "import json,sys; d=json.load(open('$1')); print(d.get('$2',''))" 2>/dev/null
}

json_valid() {
  python3 -c "import json; json.load(open('$1'))" 2>/dev/null
}

# ============================================================
# 1. JSON Validation
# ============================================================
section "1. JSON Validation"

for f in "$PLUGIN_DIR/plugin.json" "$PLUGIN_DIR/marketplace.json" "$CODEX_PLUGIN_DIR/plugin.json" "$CODEX_CHILD_DIR/.codex-plugin/plugin.json" "$CODEX_MARKETPLACE" "$HOOKS_DIR/hooks.json"; do
  fname="${f#$REPO_ROOT/}"
  if [[ -f "$f" ]]; then
    if json_valid "$f"; then
      pass "$fname is valid JSON"
    else
      fail "$fname has JSON syntax errors"
    fi
  else
    fail "$fname not found"
  fi
done

# Required fields in plugin.json
for field in name version description author skills keywords; do
  val=$(python3 -c "
import json, sys
d = json.load(open('$PLUGIN_DIR/plugin.json'))
v = d.get('$field')
if v is None: sys.exit(1)
if isinstance(v, str) and not v.strip(): sys.exit(1)
print('ok')
" 2>/dev/null || true)
  if [[ "$val" == "ok" ]]; then
    pass "plugin.json has required field '$field'"
  else
    fail "plugin.json missing or empty field '$field'"
  fi
done

# Required fields in Codex plugin.json
for field in name version description author skills keywords interface; do
  val=$(python3 -c "
import json, sys
d = json.load(open('$CODEX_PLUGIN_DIR/plugin.json'))
v = d.get('$field')
if v is None: sys.exit(1)
if isinstance(v, str) and not v.strip(): sys.exit(1)
print('ok')
" 2>/dev/null || true)
  if [[ "$val" == "ok" ]]; then
    pass ".codex-plugin/plugin.json has required field '$field'"
  else
    fail ".codex-plugin/plugin.json missing or empty field '$field'"
  fi
done

# Required fields in marketplace.json
for field in name description plugins; do
  val=$(python3 -c "
import json, sys
d = json.load(open('$PLUGIN_DIR/marketplace.json'))
v = d.get('$field')
if v is None: sys.exit(1)
if isinstance(v, str) and not v.strip(): sys.exit(1)
if isinstance(v, list) and len(v) == 0: sys.exit(1)
print('ok')
" 2>/dev/null || true)
  if [[ "$val" == "ok" ]]; then
    pass "marketplace.json has required field '$field'"
  else
    fail "marketplace.json missing or empty field '$field'"
  fi
done

# Required fields in Codex marketplace.json
for field in name plugins; do
  val=$(python3 -c "
import json, sys
d = json.load(open('$CODEX_MARKETPLACE'))
v = d.get('$field')
if v is None: sys.exit(1)
if isinstance(v, str) and not v.strip(): sys.exit(1)
if isinstance(v, list) and len(v) == 0: sys.exit(1)
print('ok')
" 2>/dev/null || true)
  if [[ "$val" == "ok" ]]; then
    pass ".agents/plugins/marketplace.json has required field '$field'"
  else
    fail ".agents/plugins/marketplace.json missing or empty field '$field'"
  fi
done

# ============================================================
# 2. Cross-File Naming Consistency
# ============================================================
section "2. Cross-File Naming Consistency"

EXPECTED_NAME="claude-governance"

# Plugin name in plugin.json
plugin_name=$(json_field "$PLUGIN_DIR/plugin.json" "name")
if [[ "$plugin_name" == "$EXPECTED_NAME" ]]; then
  pass "plugin.json name = '$EXPECTED_NAME'"
else
  fail "plugin.json name = '$plugin_name' (expected '$EXPECTED_NAME')"
fi

# Codex plugin name
codex_plugin_name=$(json_field "$CODEX_PLUGIN_DIR/plugin.json" "name")
if [[ "$codex_plugin_name" == "$EXPECTED_NAME" ]]; then
  pass ".codex-plugin/plugin.json name = '$EXPECTED_NAME'"
else
  fail ".codex-plugin/plugin.json name = '$codex_plugin_name' (expected '$EXPECTED_NAME')"
fi

# Marketplace name
mkt_name=$(json_field "$PLUGIN_DIR/marketplace.json" "name")
if [[ "$mkt_name" == "$EXPECTED_NAME" ]]; then
  pass "marketplace.json name = '$EXPECTED_NAME'"
else
  fail "marketplace.json name = '$mkt_name' (expected '$EXPECTED_NAME')"
fi

# Codex marketplace name
codex_mkt_name=$(json_field "$CODEX_MARKETPLACE" "name")
if [[ "$codex_mkt_name" == "pitimon-claude-governance" ]]; then
  pass ".agents/plugins/marketplace.json name = 'pitimon-claude-governance'"
else
  fail ".agents/plugins/marketplace.json name = '$codex_mkt_name' (expected 'pitimon-claude-governance')"
fi

# Plugin name inside marketplace plugins array
mkt_plugin_name=$(python3 -c "
import json
d = json.load(open('$PLUGIN_DIR/marketplace.json'))
print(d['plugins'][0].get('name', ''))
" 2>/dev/null || true)
if [[ "$mkt_plugin_name" == "$EXPECTED_NAME" ]]; then
  pass "marketplace.json plugins[0].name = '$EXPECTED_NAME'"
else
  fail "marketplace.json plugins[0].name = '$mkt_plugin_name' (expected '$EXPECTED_NAME')"
fi

# Plugin name inside Codex marketplace plugins array
codex_mkt_plugin_name=$(python3 -c "
import json
d = json.load(open('$CODEX_MARKETPLACE'))
print(d['plugins'][0].get('name', ''))
" 2>/dev/null || true)
if [[ "$codex_mkt_plugin_name" == "$EXPECTED_NAME" ]]; then
  pass ".agents/plugins/marketplace.json plugins[0].name = '$EXPECTED_NAME'"
else
  fail ".agents/plugins/marketplace.json plugins[0].name = '$codex_mkt_plugin_name' (expected '$EXPECTED_NAME')"
fi

# Version sync between plugin.json and marketplace.json
ver_plugin=$(json_field "$PLUGIN_DIR/plugin.json" "version")
ver_mkt=$(python3 -c "
import json
d = json.load(open('$PLUGIN_DIR/marketplace.json'))
print(d['plugins'][0].get('version', ''))
" 2>/dev/null || true)
ver_codex=$(json_field "$CODEX_PLUGIN_DIR/plugin.json" "version")
ver_codex_child=$(json_field "$CODEX_CHILD_DIR/.codex-plugin/plugin.json" "version")
if [[ "$ver_plugin" == "$ver_mkt" && "$ver_plugin" == "$ver_codex" && "$ver_plugin" == "$ver_codex_child" ]]; then
  pass "Version sync: Claude plugin ($ver_plugin) = Claude marketplace ($ver_mkt) = Codex plugin ($ver_codex) = Codex child plugin ($ver_codex_child)"
else
  fail "Version mismatch: Claude plugin ($ver_plugin), Claude marketplace ($ver_mkt), Codex plugin ($ver_codex), Codex child plugin ($ver_codex_child)"
fi

# ============================================================
# 3. File Integrity
# ============================================================
section "3. File Integrity"

# 3.1 Required SKILL.md files
EXPECTED_SKILLS=("spec-driven-dev" "governance-check" "create-adr" "governance-setup" "eu-ai-act-check" "iso-42001-check")

for skill in "${EXPECTED_SKILLS[@]}"; do
  skill_file="$SKILLS_DIR/$skill/SKILL.md"
  if [[ -f "$skill_file" ]]; then
    pass "skills/$skill/SKILL.md exists"

    # Check required frontmatter fields
    for fm_field in name description; do
      if grep -q "^${fm_field}:" "$skill_file" 2>/dev/null; then
        pass "  skills/$skill has frontmatter '$fm_field'"
      else
        fail "  skills/$skill missing frontmatter '$fm_field'"
      fi
    done
  else
    fail "skills/$skill/SKILL.md not found"
  fi
done

# 3.1b Skill allowlist completeness (catch additions AND deletions)
# EXPECTED_SKILLS is a positive allowlist — a skill directory added without
# updating it would silently skip frontmatter + discovery-surface validation.
# Assert the on-disk skill set matches the allowlist exactly.
disk_skills=()
for d in "$SKILLS_DIR"/*/; do
  [[ -d "$d" ]] || continue
  disk_skills+=("$(basename "$d")")
done
if [[ "${#disk_skills[@]}" -eq "${#EXPECTED_SKILLS[@]}" ]]; then
  pass "skill directory count (${#disk_skills[@]}) matches EXPECTED_SKILLS"
else
  fail "skill directory count (${#disk_skills[@]}) != EXPECTED_SKILLS (${#EXPECTED_SKILLS[@]}) — update the allowlist + discovery surfaces"
fi
for ds in "${disk_skills[@]}"; do
  ds_found=false
  for es in "${EXPECTED_SKILLS[@]}"; do
    [[ "$ds" == "$es" ]] && ds_found=true && break
  done
  if [[ "$ds_found" == true ]]; then
    pass "  on-disk skill '$ds' is covered by EXPECTED_SKILLS"
  else
    fail "  on-disk skill '$ds' NOT in EXPECTED_SKILLS (unvalidated — add it)"
  fi
done

# 3.1c Skill discovery-surface freshness (drift guard, cross-platform)
# Every skill must be advertised in ALL consumer-facing discovery surfaces so
# neither Claude Code nor Codex users are taught a stale command list. This is
# the durable fix for the v3.1/v3.2 drift where eu-ai-act-check / iso-42001-check
# shipped without being swept into these surfaces. session-start.sh + README +
# CLAUDE.md are Claude-facing; AGENTS.md is the Codex entry point.
DISCOVERY_SURFACES=(
  "$HOOKS_DIR/session-start.sh"
  "$REPO_ROOT/README.md"
  "$REPO_ROOT/CLAUDE.md"
  "$REPO_ROOT/AGENTS.md"
)
for skill in "${EXPECTED_SKILLS[@]}"; do
  for surface in "${DISCOVERY_SURFACES[@]}"; do
    surface_name="${surface#$REPO_ROOT/}"
    if grep -q -- "$skill" "$surface" 2>/dev/null; then
      pass "  '$skill' advertised in $surface_name"
    else
      fail "  '$skill' MISSING from $surface_name (skill-discovery drift)"
    fi
  done
done

# 3.2 Hook scripts are executable
for hook_script in "$HOOKS_DIR/session-start.sh" "$HOOKS_DIR/secret-scanner.sh"; do
  script_name="${hook_script#$REPO_ROOT/}"
  if [[ -f "$hook_script" ]]; then
    if [[ -x "$hook_script" ]]; then
      pass "$script_name is executable"
    else
      fail "$script_name exists but is not executable"
    fi
  else
    fail "$script_name not found"
  fi
done

# 3.2b hooks/hooks.json top-level schema purity (Codex compat, issue #51)
# Codex auto-discovers and parses hooks/hooks.json at install with a strict
# schema that accepts ONLY a top-level "hooks" key. Any sibling key (e.g. a
# "description") makes Codex reject the config: "unknown field `description`,
# expected `hooks`". Claude Code tolerates it; Codex does not. Keep the top
# level schema-pure so the same file installs cleanly in both runtimes.
for hookcfg in "$HOOKS_DIR/hooks.json" "$CODEX_CHILD_DIR/hooks/hooks.json"; do
  [[ -f "$hookcfg" ]] || continue
  cfg_name="${hookcfg#$REPO_ROOT/}"
  extra_keys=$(python3 -c "import json; d=json.load(open('$hookcfg')); print(' '.join(k for k in d if k != 'hooks'))" 2>/dev/null)
  has_hooks=$(python3 -c "import json; print('yes' if 'hooks' in json.load(open('$hookcfg')) else 'no')" 2>/dev/null)
  if [[ -n "$extra_keys" ]]; then
    fail "$cfg_name has non-'hooks' top-level key(s); Codex rejects unknown fields (#51): $extra_keys"
  elif [[ "$has_hooks" == "yes" ]]; then
    pass "$cfg_name top level is schema-pure (only 'hooks')"
  else
    fail "$cfg_name missing top-level 'hooks' key"
  fi
done

# 3.3 Required example files
EXPECTED_EXAMPLES=("DOMAIN.md.example" "adr-template.md" "project-claude-md.example" "DATA-CLASSIFICATION.md.example" "mcp-security-checklist.md" "ai-supply-chain-checklist.md" "shadow-ai-policy.md")
for ex in "${EXPECTED_EXAMPLES[@]}"; do
  if [[ -f "$REPO_ROOT/examples/$ex" ]]; then
    pass "examples/$ex exists"
  else
    fail "examples/$ex not found"
  fi
done

# 3.4 Rules templates
EXPECTED_RULES=("governance.md" "coding-style.md" "git-workflow.md" "testing.md" "security.md")
for rule in "${EXPECTED_RULES[@]}"; do
  if [[ -f "$REPO_ROOT/examples/rules/$rule" ]]; then
    pass "examples/rules/$rule exists"
  else
    fail "examples/rules/$rule not found"
  fi
done

# 3.5 Agent file
if [[ -f "$REPO_ROOT/agents/governance-reviewer.md" ]]; then
  pass "agents/governance-reviewer.md exists"
else
  fail "agents/governance-reviewer.md not found"
fi

# 3.7 Version bump script
bump_script="$REPO_ROOT/scripts/bump-version.sh"
if [[ -f "$bump_script" ]]; then
  pass "scripts/bump-version.sh exists"
  if [[ -x "$bump_script" ]]; then
    pass "scripts/bump-version.sh is executable"
  else
    fail "scripts/bump-version.sh exists but is not executable"
  fi
else
  fail "scripts/bump-version.sh not found"
fi

# 3.7b Codex plugin packaging
if [[ -f "$CODEX_PLUGIN_DIR/plugin.json" ]]; then
  pass ".codex-plugin/plugin.json exists"
else
  fail ".codex-plugin/plugin.json not found"
fi

codex_skills=$(json_field "$CODEX_PLUGIN_DIR/plugin.json" "skills")
if [[ "$codex_skills" == "./skills/" ]]; then
  pass ".codex-plugin/plugin.json skills path = './skills/'"
else
  fail ".codex-plugin/plugin.json skills path = '$codex_skills' (expected './skills/')"
fi

if [[ -f "$CODEX_MARKETPLACE" ]]; then
  pass ".agents/plugins/marketplace.json exists"
else
  fail ".agents/plugins/marketplace.json not found"
fi

codex_source_path=$(python3 -c "
import json
d = json.load(open('$CODEX_MARKETPLACE'))
print(d['plugins'][0].get('source', {}).get('path', ''))
" 2>/dev/null || true)
if [[ "$codex_source_path" == "./plugin" ]]; then
  pass ".agents/plugins/marketplace.json source.path = './plugin'"
else
  fail ".agents/plugins/marketplace.json source.path = '$codex_source_path' (expected './plugin')"
fi

codex_installation=$(python3 -c "
import json
d = json.load(open('$CODEX_MARKETPLACE'))
print(d['plugins'][0].get('policy', {}).get('installation', ''))
" 2>/dev/null || true)
codex_authentication=$(python3 -c "
import json
d = json.load(open('$CODEX_MARKETPLACE'))
print(d['plugins'][0].get('policy', {}).get('authentication', ''))
" 2>/dev/null || true)
if [[ "$codex_installation" == "AVAILABLE" && "$codex_authentication" == "ON_INSTALL" ]]; then
  pass ".agents/plugins/marketplace.json policy is installable"
else
  fail ".agents/plugins/marketplace.json policy unexpected (installation='$codex_installation', authentication='$codex_authentication')"
fi

if [[ -d "$CODEX_CHILD_DIR" && ! -L "$CODEX_CHILD_DIR" ]]; then
  pass "plugin is a real Codex child source directory"
else
  fail "plugin must be a real directory, not a symlink"
fi

if [[ -f "$CODEX_CHILD_DIR/.codex-plugin/plugin.json" ]]; then
  pass "plugin/.codex-plugin/plugin.json exists"
else
  fail "plugin/.codex-plugin/plugin.json not found"
fi

child_codex_skills=$(json_field "$CODEX_CHILD_DIR/.codex-plugin/plugin.json" "skills")
if [[ "$child_codex_skills" == "./skills/" ]]; then
  pass "plugin/.codex-plugin/plugin.json skills path = './skills/'"
else
  fail "plugin/.codex-plugin/plugin.json skills path = '$child_codex_skills' (expected './skills/')"
fi

for mirror_dir in skills docs hooks agents examples scripts; do
  if diff -qr "$REPO_ROOT/$mirror_dir" "$CODEX_CHILD_DIR/$mirror_dir" >/dev/null; then
    pass "plugin/$mirror_dir is in sync with $mirror_dir"
  else
    fail "plugin/$mirror_dir is not in sync with $mirror_dir"
  fi
done

for mirror_file in AGENTS.md CHANGELOG.md CLAUDE.md LICENSE README.md; do
  if cmp -s "$REPO_ROOT/$mirror_file" "$CODEX_CHILD_DIR/$mirror_file"; then
    pass "plugin/$mirror_file is in sync with $mirror_file"
  else
    fail "plugin/$mirror_file is not in sync with $mirror_file"
  fi
done

# 3.8 Additional example templates
for ex_extra in "shadow-ai-policy.md" "ai-supply-chain-checklist.md"; do
  if [[ -f "$REPO_ROOT/examples/$ex_extra" ]]; then
    pass "examples/$ex_extra exists"
  else
    fail "examples/$ex_extra not found"
  fi
done

# 3.9 ADR-002
if [[ -f "$REPO_ROOT/docs/adr/ADR-002-consequence-based-authorization.md" ]]; then
  pass "docs/adr/ADR-002 exists"
else
  fail "docs/adr/ADR-002 not found"
fi

# 3.10 Secret scanner test suite
test_suite="$REPO_ROOT/tests/test-secret-scanner.sh"
if [[ -f "$test_suite" ]]; then
  pass "tests/test-secret-scanner.sh exists"
  if [[ -x "$test_suite" ]]; then
    pass "tests/test-secret-scanner.sh is executable"
  else
    fail "tests/test-secret-scanner.sh exists but is not executable"
  fi
else
  fail "tests/test-secret-scanner.sh not found"
fi

# 3.6 No duplicate hooks.json in .claude-plugin/
if [[ -f "$PLUGIN_DIR/hooks/hooks.json" ]]; then
  fail ".claude-plugin/hooks/hooks.json exists (should only be in hooks/)"
else
  pass "No duplicate hooks.json in .claude-plugin/"
fi

# ============================================================
# 3.11 EU AI Act Compliance Toolkit (v3.1.0 migration from 8-habit-ai-dev)
# ============================================================
section "3.11 EU AI Act Compliance Toolkit"

# Skill files (SKILL.md is checked above via EXPECTED_SKILLS)
if [[ -f "$SKILLS_DIR/eu-ai-act-check/reference.md" ]]; then
  pass "skills/eu-ai-act-check/reference.md exists"
else
  fail "skills/eu-ai-act-check/reference.md not found"
fi

# Research file (primary-source verified quotes)
if [[ -f "$REPO_ROOT/docs/research/eu-ai-act-obligations.md" ]]; then
  pass "docs/research/eu-ai-act-obligations.md exists"
else
  fail "docs/research/eu-ai-act-obligations.md not found"
fi

# Compliance mapping
if [[ -f "$REPO_ROOT/docs/compliance/EU-AI-ACT-MAPPING.md" ]]; then
  pass "docs/compliance/EU-AI-ACT-MAPPING.md exists"
else
  fail "docs/compliance/EU-AI-ACT-MAPPING.md not found"
fi

# Migration ADR
if [[ -f "$REPO_ROOT/docs/adr/ADR-003-eu-ai-act-compliance-toolkit.md" ]]; then
  pass "docs/adr/ADR-003 exists"
else
  fail "docs/adr/ADR-003 not found"
fi

# Tier integrity — must have ≥25 MUST items in reference.md (per regulation derivation)
must_count=$(grep -c '^- \[ \] \*\*\[MUST\]\*\*' "$SKILLS_DIR/eu-ai-act-check/reference.md" 2>/dev/null || echo "0")
if [[ "$must_count" -ge 25 ]]; then
  pass "reference.md has $must_count MUST items (>= 25)"
else
  fail "reference.md has $must_count MUST items (expected >= 25)"
fi

# NOT LEGAL ADVICE disclaimer present in SKILL.md
if grep -qi "NOT LEGAL ADVICE" "$SKILLS_DIR/eu-ai-act-check/SKILL.md"; then
  pass "SKILL.md contains NOT LEGAL ADVICE disclaimer"
else
  fail "SKILL.md missing NOT LEGAL ADVICE disclaimer"
fi

# All 9 obligations present in reference.md
obligation_count=$(grep -c '^## Obligation' "$SKILLS_DIR/eu-ai-act-check/reference.md" 2>/dev/null || echo "0")
if [[ "$obligation_count" -eq 9 ]]; then
  pass "reference.md has all 9 obligation sections"
else
  fail "reference.md has $obligation_count obligation sections (expected 9)"
fi

# DSGAI-MAPPING.md has the EU AI Act cross-reference section (bidirectional traceability)
if grep -q "EU AI Act Cross-References" "$REPO_ROOT/docs/compliance/DSGAI-MAPPING.md"; then
  pass "DSGAI-MAPPING.md has EU AI Act cross-reference section"
else
  fail "DSGAI-MAPPING.md missing EU AI Act cross-reference section"
fi

# ============================================================
# 3.12 ISO/IEC 42001:2023 AIMS Compliance Toolkit (v3.2.0, issue #27)
# ============================================================
section "3.12 ISO/IEC 42001 AIMS Compliance Toolkit"

# Skill files (SKILL.md is checked above via EXPECTED_SKILLS)
if [[ -f "$SKILLS_DIR/iso-42001-check/reference.md" ]]; then
  pass "skills/iso-42001-check/reference.md exists"
else
  fail "skills/iso-42001-check/reference.md not found"
fi

# Compliance mapping
if [[ -f "$REPO_ROOT/docs/compliance/ISO-42001-MAPPING.md" ]]; then
  pass "docs/compliance/ISO-42001-MAPPING.md exists"
else
  fail "docs/compliance/ISO-42001-MAPPING.md not found"
fi

# Framework selection ADR
if [[ -f "$REPO_ROOT/docs/adr/ADR-004-iso-42001-framework-selection.md" ]]; then
  pass "docs/adr/ADR-004 exists"
else
  fail "docs/adr/ADR-004 not found"
fi

# Structural gate 1: all 9 Annex A clause headings present (A.2 through A.10)
clause_count=$(grep -c '^## Clause A\.' "$SKILLS_DIR/iso-42001-check/reference.md" 2>/dev/null || echo "0")
if [[ "$clause_count" -eq 9 ]]; then
  pass "reference.md has all 9 Annex A clause headings (A.2-A.10)"
else
  fail "reference.md has $clause_count clause headings (expected 9)"
fi

# Structural gate 2: every clause has at least one MUST item (no clause is all-SHOULD/COULD)
# Extract clause sections, check each for at least one MUST. Uses awk to process per-clause blocks.
clauses_without_must=$(awk '
  /^## Clause A\./ { if (current && !has_must) print current; current=$0; has_must=0; next }
  /^- \[ \] \*\*\[MUST\]\*\*/ { has_must=1 }
  END { if (current && !has_must) print current }
' "$SKILLS_DIR/iso-42001-check/reference.md")
if [[ -z "$clauses_without_must" ]]; then
  pass "every clause (A.2-A.10) has >=1 MUST item"
else
  fail "clauses missing MUST items: $clauses_without_must"
fi

# Structural gate 3: MUST items collectively cite >=5 distinct existing skills/checks
# Scope the search to MUST item lines + the "Mapped skills" line preceding each clause section.
# We grep for known skill/anchor names that should appear in MUST contexts.
skill_anchors=("spec-driven-dev" "governance-check" "governance-reviewer" "create-adr" "ADR-001" "ADR-002")
distinct_skills_found=0
for anchor in "${skill_anchors[@]}"; do
  if grep -q "$anchor" "$SKILLS_DIR/iso-42001-check/reference.md"; then
    distinct_skills_found=$((distinct_skills_found + 1))
  fi
done
if [[ "$distinct_skills_found" -ge 5 ]]; then
  pass "reference.md cites $distinct_skills_found distinct existing skills/checks (>=5 required)"
else
  fail "reference.md cites only $distinct_skills_found distinct skills/checks (expected >=5)"
fi

# Disclaimer present in SKILL.md, reference.md, and mapping doc
disclaimer_files=("$SKILLS_DIR/iso-42001-check/SKILL.md" "$SKILLS_DIR/iso-42001-check/reference.md" "$REPO_ROOT/docs/compliance/ISO-42001-MAPPING.md")
disclaimer_missing=()
for f in "${disclaimer_files[@]}"; do
  if ! grep -q "NOT A CERTIFICATION GUARANTEE" "$f" 2>/dev/null; then
    disclaimer_missing+=("$(basename "$f")")
  fi
done
if [[ ${#disclaimer_missing[@]} -eq 0 ]]; then
  pass "NOT A CERTIFICATION GUARANTEE disclaimer present in SKILL.md, reference.md, mapping doc"
else
  fail "NOT A CERTIFICATION GUARANTEE missing in: ${disclaimer_missing[*]}"
fi

# DSGAI-MAPPING.md has the ISO 42001 cross-reference section (bidirectional traceability)
if grep -q "ISO 42001 Cross-References" "$REPO_ROOT/docs/compliance/DSGAI-MAPPING.md"; then
  pass "DSGAI-MAPPING.md has ISO 42001 cross-reference section"
else
  fail "DSGAI-MAPPING.md missing ISO 42001 cross-reference section"
fi

# ============================================================
# 3.13 NIST AI RMF Cross-Reference Toolkit (v3.3.0, issue #29)
# ============================================================
section "3.13 NIST AI RMF Cross-Reference Toolkit"

# Gate 1: NIST mapping doc exists
if [[ -f "$REPO_ROOT/docs/compliance/NIST-AI-RMF-MAPPING.md" ]]; then
  pass "docs/compliance/NIST-AI-RMF-MAPPING.md exists"
else
  fail "docs/compliance/NIST-AI-RMF-MAPPING.md not found"
fi

# Gate 2: ADR-005 exists
if [[ -f "$REPO_ROOT/docs/adr/ADR-005-nist-ai-rmf-cross-reference-doc.md" ]]; then
  pass "docs/adr/ADR-005 exists"
else
  fail "docs/adr/ADR-005 not found"
fi

# Gate 3: ISO 42001 mapping cites NIST mapping by path (bidirectional cross-ref)
if grep -q "NIST-AI-RMF-MAPPING.md" "$REPO_ROOT/docs/compliance/ISO-42001-MAPPING.md" 2>/dev/null; then
  pass "ISO-42001-MAPPING.md cites NIST-AI-RMF-MAPPING.md by path"
else
  fail "ISO-42001-MAPPING.md missing back-reference to NIST-AI-RMF-MAPPING.md"
fi

# Gate 4: EU AI Act mapping cites NIST mapping by path (bidirectional cross-ref)
if grep -q "NIST-AI-RMF-MAPPING.md" "$REPO_ROOT/docs/compliance/EU-AI-ACT-MAPPING.md" 2>/dev/null; then
  pass "EU-AI-ACT-MAPPING.md cites NIST-AI-RMF-MAPPING.md by path"
else
  fail "EU-AI-ACT-MAPPING.md missing back-reference to NIST-AI-RMF-MAPPING.md"
fi

# ============================================================
# 4. Keyword & Description Coverage
# ============================================================
section "4. Keyword & Description Coverage"

# Check that each skill name appears in plugin description
plugin_desc=$(json_field "$PLUGIN_DIR/plugin.json" "description")
plugin_desc_lower=$(echo "$plugin_desc" | tr '[:upper:]' '[:lower:]')

for keyword in "governance" "fitness" "secret" "spec" "adr"; do
  if echo "$plugin_desc_lower" | grep -q "$keyword"; then
    pass "Plugin description mentions '$keyword'"
  else
    fail "Plugin description missing keyword '$keyword'"
  fi
done

# Minimum keyword count
kw_count=$(python3 -c "
import json
d = json.load(open('$PLUGIN_DIR/plugin.json'))
print(len(d.get('keywords', [])))
" 2>/dev/null || echo "0")
if [[ "$kw_count" -ge 10 ]]; then
  pass "Keywords count = $kw_count (>= 10)"
else
  fail "Keywords count = $kw_count (expected >= 10)"
fi

# ============================================================
# 5. Install Check (optional)
# ============================================================
section "5. Install Check"

if [[ "$SKIP_INSTALL" == true ]]; then
  skip "Install check skipped (--skip-install-check)"
else
  INSTALLED_DIR="$CLAUDE_HOME/plugins/marketplaces/claude-governance"
  if [[ -d "$INSTALLED_DIR" ]]; then
    pass "Plugin installed at $INSTALLED_DIR"

    # Check hooks.json is loadable
    if [[ -f "$INSTALLED_DIR/hooks/hooks.json" ]]; then
      if json_valid "$INSTALLED_DIR/hooks/hooks.json"; then
        pass "Installed hooks/hooks.json is valid JSON"
      else
        fail "Installed hooks/hooks.json has JSON errors"
      fi
    else
      fail "Installed hooks/hooks.json not found"
    fi
  else
    skip "Plugin not installed locally"
  fi
fi

# ============================================================
# Summary
# ============================================================
printf "\n\033[1m=== Summary ===\033[0m\n"
printf "  \033[32mPASS: %d\033[0m  \033[31mFAIL: %d\033[0m  \033[33mSKIP: %d\033[0m\n" "$PASS" "$FAIL" "$SKIP"

if [[ "$FAIL" -gt 0 ]]; then
  printf "\n\033[31mValidation FAILED with %d error(s)\033[0m\n" "$FAIL"
  exit 1
else
  printf "\n\033[32mAll checks passed!\033[0m\n"
  exit 0
fi
