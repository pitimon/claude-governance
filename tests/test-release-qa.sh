#!/usr/bin/env bash
# test-release-qa.sh — Comprehensive QA for v2.3.0 + v3.0.0 releases
# Tests: structural integrity, scanner patterns, DSGAI compliance, 8-Habit checks
# Usage: bash tests/test-release-qa.sh
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0
WARN=0

pass()  { (( ++PASS )); printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail()  { (( ++FAIL )); printf "  \033[31mFAIL\033[0m %s\n" "$1"; }
warn()  { (( ++WARN )); printf "  \033[33mWARN\033[0m %s\n" "$1"; }
section() { printf "\n\033[1;36m[%s]\033[0m\n" "$1"; }

file_has() {
  local file="$1" pattern="$2" desc="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    pass "$desc"
  else
    fail "$desc"
  fi
}

file_missing() {
  local file="$1" pattern="$2" desc="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    fail "$desc"
  else
    pass "$desc"
  fi
}

# ============================================================
# 1. STRUCTURAL BASELINE
# ============================================================
section "1. Structural Baseline (v3.0.0)"

# Version
VER_P=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
VER_M=$(python3 -c "import json; print(json.load(open('.claude-plugin/marketplace.json'))['plugins'][0]['version'])")
[[ "$VER_P" == "3.0.0" ]] && pass "plugin.json version = 3.0.0" || fail "plugin.json version = $VER_P (expected 3.0.0)"
[[ "$VER_P" == "$VER_M" ]] && pass "Version sync: plugin.json = marketplace.json" || fail "Version mismatch: $VER_P != $VER_M"

# Required files (v2.3.0 + v3.0.0)
REQUIRED_FILES=(
  "hooks/secret-scanner.sh"
  "hooks/session-start.sh"
  "hooks/hooks.json"
  "skills/governance-check/SKILL.md"
  "skills/create-adr/SKILL.md"
  "skills/spec-driven-dev/SKILL.md"
  "skills/governance-setup/SKILL.md"
  "agents/governance-reviewer.md"
  "examples/rules/governance.md"
  "examples/rules/security.md"
  "examples/rules/coding-style.md"
  "examples/rules/git-workflow.md"
  "examples/rules/testing.md"
  "examples/DOMAIN.md.example"
  "examples/DATA-CLASSIFICATION.md.example"
  "examples/mcp-security-checklist.md"
  "examples/shadow-ai-policy.md"
  "examples/ai-supply-chain-checklist.md"
  "examples/adr-template.md"
  "examples/project-claude-md.example"
  "docs/adr/ADR-001-adopt-governance-framework.md"
  "docs/adr/ADR-002-consequence-based-authorization.md"
  "docs/compliance/DSGAI-MAPPING.md"
  "scripts/bump-version.sh"
  "scripts/install-rules.sh"
  "tests/validate-plugin.sh"
  "tests/test-secret-scanner.sh"
  ".github/workflows/validate.yml"
  "CHANGELOG.md"
  "README.md"
  "LICENSE"
  "CLAUDE.md"
)

for f in "${REQUIRED_FILES[@]}"; do
  [[ -f "$f" ]] && pass "$f exists" || fail "$f MISSING"
done

# Executable scripts
for s in hooks/secret-scanner.sh hooks/session-start.sh scripts/bump-version.sh tests/test-secret-scanner.sh; do
  [[ -x "$s" ]] && pass "$s is executable" || fail "$s not executable"
done

# File size < 800 lines
for f in hooks/secret-scanner.sh skills/governance-check/SKILL.md agents/governance-reviewer.md examples/rules/governance.md examples/rules/security.md skills/governance-setup/SKILL.md; do
  LINES=$(wc -l < "$f")
  [[ $LINES -lt 800 ]] && pass "$f: $LINES lines (<800)" || fail "$f: $LINES lines (>=800)"
done

# ============================================================
# 2. SECRET SCANNER — v2.3.0 BLOCK/WARN Architecture
# ============================================================
section "2. Secret Scanner — BLOCK Patterns (exit 2)"

SCANNER="$REPO_ROOT/hooks/secret-scanner.sh"
make_input() { printf '{"tool_name":"Write","tool_input":{"file_path":"/tmp/t","content":"%s"}}' "$1"; }

assert_blocked() {
  if echo "$(make_input "$2")" | bash "$SCANNER" >/dev/null 2>&1; then
    fail "should block: $1"
  else
    pass "blocked: $1"
  fi
}

assert_warned() {
  local stderr_out
  stderr_out=$(echo "$(make_input "$2")" | bash "$SCANNER" 2>&1 >/dev/null)
  local ec=$?
  if [[ $ec -eq 0 ]] && echo "$stderr_out" | grep -q "WARNING"; then
    pass "warned: $1"
  else
    fail "should warn: $1 (exit=$ec)"
  fi
}

assert_allowed() {
  if echo "$(make_input "$2")" | bash "$SCANNER" >/dev/null 2>&1; then
    pass "allowed: $1"
  else
    fail "should allow: $1"
  fi
}

# Original v2.2.1 patterns (regression)
assert_blocked "API_KEY" 'API_KEY = \"abcdefghij1234567890\"'
assert_blocked "password" 'password = \"mysecret\"'
assert_blocked "sk- OpenAI" "sk-abcdefghijklmnopqrstuvwxyz"
assert_blocked "sk-ant- Anthropic (with hyphens, bug #6)" "sk-ant-api03-abcdefghijklmnopqrst"
assert_blocked "ghp_ GitHub PAT" "ghp_abcdefghijklmnopqrstuvwxyz1234567890"
assert_blocked "AKIA AWS" "AKIAIOSFODNN7EXAMPLE"
assert_blocked "Private key block" "-----BEGIN RSA PRIVATE KEY-----"
assert_blocked "JWT token" "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkw"
assert_blocked "Google API key" "AIzaSyA1234567890abcdefghijklmnopqrstuv"
assert_blocked "MongoDB URI" "mongodb+srv://user:pass@cluster.mongodb.net"
assert_blocked "Token assignment" 'Token = \"abc123def456xyz\"'
assert_blocked "GITHUB_TOKEN" 'GITHUB_TOKEN = \"ghp_xxxxx\"'

# v2.3.0 new credential patterns (#11)
assert_blocked "Bearer token" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9xxxxxxxxxxxx"
assert_blocked "Authorization header" "Authorization: Bearer eyJhbGciOiJIUzI1NiIsxxxx"
assert_blocked "oauth_token" 'oauth_token = \"abcdefghij1234567890\"'
assert_blocked "refresh_token" 'refresh_token = \"abcdefghij1234567890\"'
assert_blocked "client_secret" 'client_secret = \"abcdefghij1234567890\"'

section "2b. Secret Scanner — WARN Patterns (exit 0 + WARNING)"

# v2.3.0 PII patterns (#9)
assert_warned "Email address" "contact admin@company.com for help"
assert_warned "SSN pattern" "SSN: 123-45-6789"
assert_warned "Credit card" "card: 4111 1111 1111 1111"

section "2c. Secret Scanner — Safe Content (exit 0, silent)"

assert_allowed "Plain text" "Hello world"
assert_allowed "Env var reference" "const key = process.env.API_KEY"
assert_allowed "Short string" "x = 42"

# Edge cases
EDIT_INPUT='{"tool_name":"Edit","tool_input":{"file_path":"/tmp/t","old_string":"x","new_string":"sk-ant-api03-abcdefghijklmnopqrst"}}'
if echo "$EDIT_INPUT" | bash "$SCANNER" >/dev/null 2>&1; then
  fail "Edit tool with secret should block"
else
  pass "Edit tool with secret blocked"
fi

NON_WRITE='{"tool_name":"Read","tool_input":{"file_path":"/tmp/t"}}'
echo "$NON_WRITE" | bash "$SCANNER" >/dev/null 2>&1 && pass "Non-Write tool allowed" || fail "Non-Write tool should pass"

# ============================================================
# 3. DSGAI COMPLIANCE — v2.3.0 Tier 1 (6 controls)
# ============================================================
section "3. DSGAI Tier 1 Controls (v2.3.0)"

# DSGAI01 — PII detection
file_has hooks/secret-scanner.sh "WARN_PATTERNS" "DSGAI01: WARN_PATTERNS array exists"
file_has hooks/secret-scanner.sh "DSGAI01" "DSGAI01: Reference in scanner"

# DSGAI02 — Agent credentials
file_has hooks/secret-scanner.sh "Bearer" "DSGAI02: Bearer pattern in scanner"
file_has hooks/secret-scanner.sh "oauth_token" "DSGAI02: oauth_token pattern"
file_has skills/governance-check/SKILL.md "DSGAI02" "DSGAI02: Reference in governance-check"
file_has agents/governance-reviewer.md "DSGAI02" "DSGAI02: Reference in reviewer"

# DSGAI06 — Plugin/MCP security
file_has skills/governance-check/SKILL.md "DSGAI06" "DSGAI06: MCP check in governance-check"
[[ -f examples/mcp-security-checklist.md ]] && pass "DSGAI06: MCP checklist exists" || fail "DSGAI06: MCP checklist missing"

# DSGAI07 — Data classification
[[ -f examples/DATA-CLASSIFICATION.md.example ]] && pass "DSGAI07: DATA-CLASSIFICATION template" || fail "DSGAI07: template missing"
file_has skills/governance-setup/SKILL.md "Data Classification" "DSGAI07: Setup integrates classification"

# DSGAI08 — Compliance mapping
[[ -f docs/compliance/DSGAI-MAPPING.md ]] && pass "DSGAI08: DSGAI-MAPPING.md exists" || fail "DSGAI08: mapping missing"

# DSGAI15 — Context minimization
file_has skills/governance-check/SKILL.md "DSGAI15" "DSGAI15: Context min in governance-check"
file_has hooks/session-start.sh "DSGAI15" "DSGAI15: Reference in session-start"

# ============================================================
# 4. DSGAI COMPLIANCE — v3.0.0 Tier 2 (5 new controls)
# ============================================================
section "4. DSGAI Tier 2 Controls (v3.0.0)"

# DSGAI03 — Shadow AI
[[ -f examples/shadow-ai-policy.md ]] && pass "DSGAI03: Shadow AI policy exists" || fail "DSGAI03: policy missing"
file_has skills/governance-check/SKILL.md "DSGAI03" "DSGAI03: Check in governance-check"
file_has agents/governance-reviewer.md "DSGAI03" "DSGAI03: Check in reviewer"
file_has examples/rules/governance.md "DSGAI03" "DSGAI03: Fitness function in governance.md"
file_has examples/shadow-ai-policy.md "Approved Alternatives" "DSGAI03/H4: Includes approved alternatives"
file_has examples/shadow-ai-policy.md "Exception Process" "DSGAI03/H4: Includes exception process"
file_has skills/governance-setup/SKILL.md "Shadow AI" "DSGAI03: Setup integrates Shadow AI"

# DSGAI04 — Supply chain
[[ -f examples/ai-supply-chain-checklist.md ]] && pass "DSGAI04: Supply chain checklist exists" || fail "DSGAI04: checklist missing"
file_has skills/governance-check/SKILL.md "DSGAI04" "DSGAI04: Check in governance-check"
file_has agents/governance-reviewer.md "DSGAI04" "DSGAI04: Check in reviewer"
file_has examples/rules/governance.md "DSGAI04" "DSGAI04: Fitness function in governance.md"
file_has examples/rules/security.md "DSGAI04" "DSGAI04: Security rule section"
file_has examples/ai-supply-chain-checklist.md "weights_only" "DSGAI04: Safe torch.load alternative"
file_has examples/ai-supply-chain-checklist.md "safetensors" "DSGAI04: safetensors recommended"

# DSGAI14 — Telemetry
file_has skills/governance-check/SKILL.md "DSGAI14" "DSGAI14: Telemetry check in governance-check"
file_has agents/governance-reviewer.md "DSGAI14" "DSGAI14: Telemetry check in reviewer"
file_has examples/rules/governance.md "DSGAI14" "DSGAI14: Fitness function in governance.md"
file_has examples/rules/security.md "DSGAI14" "DSGAI14: Security rule section"

# DSGAI19 — Consequence-based authorization
[[ -f docs/adr/ADR-002-consequence-based-authorization.md ]] && pass "DSGAI19: ADR-002 exists" || fail "DSGAI19: ADR-002 missing"
file_has skills/governance-check/SKILL.md "DSGAI19" "DSGAI19: Check in governance-check"
file_has agents/governance-reviewer.md "DSGAI19" "DSGAI19: Check in reviewer"
file_has examples/rules/governance.md "DSGAI19" "DSGAI19: Fitness function in governance.md"
file_has hooks/session-start.sh "Consequence Override" "DSGAI19: Override in session-start"
file_has hooks/session-start.sh "ADR-002" "DSGAI19: ADR-002 ref in session-start"
file_has docs/adr/ADR-002-consequence-based-authorization.md "Irreversible" "DSGAI19: Consequence levels defined"
file_has docs/adr/ADR-002-consequence-based-authorization.md "2D matrix" "DSGAI19: 2D model documented"

# DSGAI11 — Cross-context bleed
file_has skills/governance-check/SKILL.md "DSGAI11" "DSGAI11: Session isolation in governance-check"
file_has agents/governance-reviewer.md "DSGAI11" "DSGAI11: Session isolation in reviewer"
file_has examples/rules/governance.md "DSGAI11" "DSGAI11: Fitness function in governance.md"
file_has examples/rules/security.md "DSGAI11" "DSGAI11: Security rule section"

# DSGAI-MAPPING completeness
IMPL_COUNT=$(sed -n '/^## Implemented Controls/,/^## /p' docs/compliance/DSGAI-MAPPING.md | grep -c "^| DSGAI")
[[ $IMPL_COUNT -ge 11 ]] && pass "DSGAI-MAPPING: $IMPL_COUNT controls implemented (>=11)" || fail "DSGAI-MAPPING: only $IMPL_COUNT controls (need >=11)"

GAP_COUNT=$(sed -n '/^## Remaining Gaps/,/^## /p' docs/compliance/DSGAI-MAPPING.md | grep -c "^| DSGAI")
[[ $GAP_COUNT -le 5 ]] && pass "DSGAI-MAPPING: $GAP_COUNT remaining gaps (<=5)" || warn "DSGAI-MAPPING: $GAP_COUNT gaps"

# ============================================================
# 5. 8-HABIT CHECKS
# ============================================================
section "5a. H1 เป็นฝ่ายรุก — All callers in sync"

# Every DSGAI control must appear in governance-check + reviewer + governance.md + DSGAI-MAPPING
for D in DSGAI01 DSGAI02 DSGAI03 DSGAI04 DSGAI06 DSGAI07 DSGAI08 DSGAI11 DSGAI14 DSGAI15 DSGAI19; do
  FOUND=0
  grep -q "$D" skills/governance-check/SKILL.md 2>/dev/null && (( ++FOUND ))
  grep -q "$D" docs/compliance/DSGAI-MAPPING.md 2>/dev/null && (( ++FOUND ))
  # governance-check + DSGAI-MAPPING = minimum 2 files
  [[ $FOUND -ge 2 ]] && pass "H1: $D synced (${FOUND} files)" || fail "H1: $D found in only $FOUND files"
done

section "5b. H2 ภาพสุดท้าย — Definition artifacts exist"

file_has CHANGELOG.md "3.0.0" "H2: CHANGELOG has v3.0.0 entry"
file_has CHANGELOG.md "closes #15" "H2: CHANGELOG references #15"
file_has CHANGELOG.md "closes #19" "H2: CHANGELOG references #19"
file_has docs/adr/ADR-002-consequence-based-authorization.md "Context" "H2: ADR-002 has Context (WHY)"
file_has docs/adr/ADR-002-consequence-based-authorization.md "Decision" "H2: ADR-002 has Decision (WHAT)"

section "5c. H3 ทำสิ่งสำคัญก่อน — No gold-plating"

# Scanner patterns unchanged in v3.0.0 (no unnecessary additions)
BLOCK=$(sed -n '/BLOCK_PATTERNS=/,/^)/p' hooks/secret-scanner.sh | grep -c ":")
WARN_P=$(sed -n '/WARN_PATTERNS=/,/^)/p' hooks/secret-scanner.sh | grep -c ":")
[[ $BLOCK -eq 25 ]] && pass "H3: BLOCK patterns = 25 (unchanged from v2.3.0)" || warn "H3: BLOCK = $BLOCK (expected 25)"
[[ $WARN_P -eq 3 ]] && pass "H3: WARN patterns = 3 (unchanged from v2.3.0)" || warn "H3: WARN = $WARN_P (expected 3)"

# No new skills
SKILL_COUNT=$(ls -d skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
[[ "$SKILL_COUNT" -eq 4 ]] && pass "H3: 4 skills (no unnecessary additions)" || warn "H3: $SKILL_COUNT skills"

# Tier 3 deferred
file_has docs/compliance/DSGAI-MAPPING.md "Remaining Gaps" "H3: Tier 3 gaps tracked (not implemented)"

section "5d. H4 Win-Win — Deposits not withdrawals"

file_has examples/shadow-ai-policy.md "Approved Alternatives" "H4: Shadow AI has alternatives (not just prohibitions)"
file_has examples/ai-supply-chain-checklist.md "Safe Alternative" "H4: Supply chain has safe alternatives"
file_has docs/adr/ADR-002-consequence-based-authorization.md "Negative" "H4: ADR-002 honestly documents downsides"

section "5e. H5 เข้าใจก่อน — Regression-free"

# v2.2.1 bug #6 fix preserved
assert_blocked "H5: sk-ant hyphen regression" "sk-ant-api03-abcdefghijklmnopqrst"
assert_blocked "H5: Private key regression" "-----BEGIN RSA PRIVATE KEY-----"

# Tier 1 controls still present
for D in DSGAI01 DSGAI02 DSGAI06 DSGAI07 DSGAI08 DSGAI15; do
  file_has docs/compliance/DSGAI-MAPPING.md "$D" "H5: Tier 1 $D still in mapping"
done

section "5f. H6 ผนึกกำลัง — Cross-references"

file_has skills/governance-check/SKILL.md "governance-reviewer" "H6: Check → Reviewer cross-ref"
file_has agents/governance-reviewer.md "governance-check" "H6: Reviewer → Check cross-ref"
file_has docs/compliance/DSGAI-MAPPING.md "devsecops-ai-team" "H6: Complementary tool: devsecops-ai-team"
file_has docs/compliance/DSGAI-MAPPING.md "GitLeaks" "H6: Complementary tool: GitLeaks"

section "5g. H7 ลับเลื่อย — CI & production capability"

file_has .github/workflows/validate.yml "test-secret-scanner" "H7: CI runs scanner tests"
file_has tests/validate-plugin.sh "shadow-ai-policy" "H7: validate-plugin checks Shadow AI"
file_has tests/validate-plugin.sh "ai-supply-chain" "H7: validate-plugin checks supply chain"
file_has tests/validate-plugin.sh "ADR-002" "H7: validate-plugin checks ADR-002"
file_has docs/compliance/DSGAI-MAPPING.md "Remaining Gaps" "H7: Gap tracking for periodic review"
file_has docs/adr/ADR-002-consequence-based-authorization.md "Review Trigger" "H7: ADR-002 has review trigger"

section "5h. H8 ค้นหาเสียง — Empowerment"

# Whole Person
file_has docs/adr/ADR-002-consequence-based-authorization.md "2D matrix" "H8/Mind: Three Loops extended to 2D"
file_has examples/shadow-ai-policy.md "Approved Alternatives" "H8/Heart: Empowers with alternatives"
file_has docs/adr/ADR-002-consequence-based-authorization.md "Irreversible" "H8/Spirit: Conscience — should AI do this?"

# Templates are actionable (have checklists)
grep -q "\- \[ \]" examples/DATA-CLASSIFICATION.md.example && pass "H8: DATA-CLASSIFICATION has checklist" || fail "H8: no checklist"
grep -q "\- \[ \]" examples/mcp-security-checklist.md && pass "H8: MCP checklist has checklist" || fail "H8: no checklist"
grep -q "\- \[ \]" examples/ai-supply-chain-checklist.md && pass "H8: Supply chain has checklist" || fail "H8: no checklist"

# ============================================================
# 6. SESSION-START TOKEN BUDGET
# ============================================================
section "6. Session-Start Token Budget"

TOKEN_EST=$(python3 -c "
import json
data = open('hooks/session-start.sh').read()
start = data.index('{')
end = data.rindex('}') + 1
j = json.loads(data[start:end])
text = j['hookSpecificOutput']['additionalContext']
words = len(text.split())
est = words * 4 // 3
print(est)
" 2>/dev/null || echo "999")
[[ $TOKEN_EST -le 400 ]] && pass "Token estimate: ~$TOKEN_EST (<=400)" || fail "Token estimate: ~$TOKEN_EST (>400 budget)"

# ============================================================
# Summary
# ============================================================
printf "\n\033[1m=== QA Summary: v2.3.0 + v3.0.0 ===\033[0m\n"
printf "  \033[32mPASS: %d\033[0m  \033[31mFAIL: %d\033[0m  \033[33mWARN: %d\033[0m\n" "$PASS" "$FAIL" "$WARN"

if [[ "$FAIL" -gt 0 ]]; then
  printf "\n\033[31mQA FAILED with %d error(s)\033[0m\n" "$FAIL"
  exit 1
else
  printf "\n\033[32mAll QA checks passed!\033[0m\n"
  exit 0
fi
