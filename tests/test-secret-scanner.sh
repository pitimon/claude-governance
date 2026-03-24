#!/usr/bin/env bash
# test-secret-scanner.sh — Pattern-by-pattern tests for secret scanner
# Usage: bash tests/test-secret-scanner.sh
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCANNER="$REPO_ROOT/hooks/secret-scanner.sh"

PASS=0
FAIL=0

# --- Helpers ---

pass() { (( ++PASS )); printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail() { (( ++FAIL )); printf "  \033[31mFAIL\033[0m %s\n" "$1"; }

make_input() {
  local content="$1"
  printf '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.txt","content":"%s"}}' "$content"
}

assert_blocked() {
  local desc="$1" content="$2"
  if echo "$(make_input "$content")" | bash "$SCANNER" >/dev/null 2>&1; then
    fail "should block: $desc"
  else
    pass "blocked: $desc"
  fi
}

assert_allowed() {
  local desc="$1" content="$2"
  if echo "$(make_input "$content")" | bash "$SCANNER" >/dev/null 2>&1; then
    pass "allowed: $desc"
  else
    fail "should allow: $desc"
  fi
}

assert_warned() {
  local desc="$1" content="$2"
  local stderr_output
  stderr_output=$(echo "$(make_input "$content")" | bash "$SCANNER" 2>&1 >/dev/null)
  local exit_code=$?
  if [[ $exit_code -eq 0 ]] && echo "$stderr_output" | grep -q "WARNING"; then
    pass "warned: $desc"
  else
    fail "should warn: $desc (exit=$exit_code)"
  fi
}

# ============================================================
# BLOCK tests — secrets and credentials (exit 2)
# ============================================================
printf "\n\033[1;36m[BLOCK patterns — must exit 2]\033[0m\n"

assert_blocked "API_KEY assignment" 'API_KEY = \"abcdefghij1234567890\"'
assert_blocked "password assignment" 'password = \"mysecret\"'
assert_blocked "sk- OpenAI key" "sk-abcdefghijklmnopqrstuvwxyz"
assert_blocked "sk-proj- key" "sk-proj-abcdefghijklmnopqrstuvwx"
assert_blocked "sk-ant- Anthropic key" "sk-ant-api03-abcdefghijklmnopqrst"
assert_blocked "ghp_ GitHub PAT" "ghp_abcdefghijklmnopqrstuvwxyz1234567890"
assert_blocked "gho_ GitHub OAuth" "gho_abcdefghijklmnopqrstuvwxyz1234567890"
assert_blocked "ghs_ GitHub server" "ghs_abcdefghijklmnopqrstuvwxyz1234567890"
assert_blocked "AKIA AWS key" "AKIAIOSFODNN7EXAMPLE"
assert_blocked "xoxb- Slack token" "xoxb-123456789-abcdefghij"
assert_blocked "Private key block" "-----BEGIN RSA PRIVATE KEY-----"
assert_blocked "JWT token" "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkw"
assert_blocked "Google API key" "AIzaSyA1234567890abcdefghijklmnopqrstuv"
assert_blocked "Azure connection" "DefaultEndpointsProtocol=https;AccountName=myaccount"
assert_blocked "MongoDB URI" "mongodb+srv://user:pass@cluster.mongodb.net"
assert_blocked "Token assignment" 'Token = \"abc123def456xyz\"'
assert_blocked "GITHUB_TOKEN" 'GITHUB_TOKEN = \"ghp_xxxxx\"'
assert_blocked "GH_TOKEN" 'GH_TOKEN = \"ghp_xxxxx\"'
assert_blocked "Bearer token" "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9xxxx"
assert_blocked "Authorization header" "Authorization: Bearer eyJhbGciOiJIUzI1NiIsxxxx"
assert_blocked "oauth_token" 'oauth_token = \"abcdefghij1234567890\"'
assert_blocked "refresh_token" 'refresh_token = \"abcdefghij1234567890\"'
assert_blocked "client_secret" 'client_secret = \"abcdefghij1234567890\"'

# ============================================================
# WARN tests — PII patterns (exit 0 + stderr WARNING)
# ============================================================
printf "\n\033[1;36m[WARN patterns — must exit 0 with WARNING]\033[0m\n"

assert_warned "Email address" "contact user at admin@company.com for help"
assert_warned "SSN pattern" "SSN: 123-45-6789"
assert_warned "Credit card" "card: 4111 1111 1111 1111"

# ============================================================
# ALLOW tests — safe content (exit 0, no output)
# ============================================================
printf "\n\033[1;36m[ALLOW patterns — must exit 0 silently]\033[0m\n"

assert_allowed "Plain text" "Hello world"
assert_allowed "Env var reference" "const key = process.env.API_KEY"
assert_allowed "Short string" "x = 42"
assert_allowed "Comment with sk-" "# sk- prefix is used for API keys"
assert_allowed "Empty-ish content" "const x = true"

# ============================================================
# Edge cases
# ============================================================
printf "\n\033[1;36m[Edge cases]\033[0m\n"

# Non-matching tool name should pass
NON_WRITE='{"tool_name":"Read","tool_input":{"file_path":"/tmp/test.txt"}}'
if echo "$NON_WRITE" | bash "$SCANNER" >/dev/null 2>&1; then
  pass "Non-Write tool allowed"
else
  fail "Non-Write tool should be allowed"
fi

# Edit tool format
EDIT_INPUT='{"tool_name":"Edit","tool_input":{"file_path":"/tmp/t","old_string":"x","new_string":"sk-ant-api03-abcdefghijklmnopqrst"}}'
if echo "$EDIT_INPUT" | bash "$SCANNER" >/dev/null 2>&1; then
  fail "Edit with secret should be blocked"
else
  pass "Edit with secret blocked"
fi

# Empty content
EMPTY='{"tool_name":"Write","tool_input":{"file_path":"/tmp/t","content":""}}'
if echo "$EMPTY" | bash "$SCANNER" >/dev/null 2>&1; then
  pass "Empty content allowed"
else
  fail "Empty content should be allowed"
fi

# ============================================================
# Summary
# ============================================================
printf "\n\033[1m=== Summary ===\033[0m\n"
printf "  \033[32mPASS: %d\033[0m  \033[31mFAIL: %d\033[0m\n" "$PASS" "$FAIL"

if [[ "$FAIL" -gt 0 ]]; then
  printf "\n\033[31mTests FAILED with %d error(s)\033[0m\n" "$FAIL"
  exit 1
else
  printf "\n\033[32mAll scanner tests passed!\033[0m\n"
  exit 0
fi
