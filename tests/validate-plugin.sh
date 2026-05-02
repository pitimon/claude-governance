#!/usr/bin/env bash
# validate-plugin.sh — Structural integrity tests for claude-governance plugin
# Usage: bash tests/validate-plugin.sh [--skip-install-check]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/.claude-plugin"
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

for f in "$PLUGIN_DIR/plugin.json" "$PLUGIN_DIR/marketplace.json" "$HOOKS_DIR/hooks.json"; do
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

# Marketplace name
mkt_name=$(json_field "$PLUGIN_DIR/marketplace.json" "name")
if [[ "$mkt_name" == "$EXPECTED_NAME" ]]; then
  pass "marketplace.json name = '$EXPECTED_NAME'"
else
  fail "marketplace.json name = '$mkt_name' (expected '$EXPECTED_NAME')"
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

# Version sync between plugin.json and marketplace.json
ver_plugin=$(json_field "$PLUGIN_DIR/plugin.json" "version")
ver_mkt=$(python3 -c "
import json
d = json.load(open('$PLUGIN_DIR/marketplace.json'))
print(d['plugins'][0].get('version', ''))
" 2>/dev/null || true)
if [[ "$ver_plugin" == "$ver_mkt" ]]; then
  pass "Version sync: plugin.json ($ver_plugin) = marketplace.json ($ver_mkt)"
else
  fail "Version mismatch: plugin.json ($ver_plugin) != marketplace.json ($ver_mkt)"
fi

# ============================================================
# 3. File Integrity
# ============================================================
section "3. File Integrity"

# 3.1 Required SKILL.md files
EXPECTED_SKILLS=("spec-driven-dev" "governance-check" "create-adr" "governance-setup" "eu-ai-act-check")

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

# 3.3 Required example files
EXPECTED_EXAMPLES=("DOMAIN.md.example" "adr-template.md" "project-claude-md.example")
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
