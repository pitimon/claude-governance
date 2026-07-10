#!/usr/bin/env bash

# Secret scanner hook — blocks file writes containing hardcoded secrets
# Runs as PreToolUse hook on Edit|Write|MultiEdit
# Exit 0 = allow (or warn for PII), Exit 2 = block (secrets/credentials)

# Require python3 for JSON parsing
if ! command -v python3 &>/dev/null; then
  echo "Governance: WARNING — python3 not found, secret scanning disabled" >&2
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)

# Extract the tool name. Parse with python3 (a hard requirement, checked above)
# instead of a whitespace-sensitive grep: a grep like '"tool_name":"[^"]*"' only
# matches compact JSON and returns empty on a payload with a space after the
# colon, which used to fall through to a silent `exit 0` — a fail-open in the
# security control. python3's json.load is whitespace-agnostic.
TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c "import sys,json
try:
    print(json.load(sys.stdin).get('tool_name',''))
except Exception:
    pass" 2>/dev/null)

CONTENT=""
RECOGNIZED=true
case "$TOOL_NAME" in
  Write)
    CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('content',''))" 2>/dev/null)
    ;;
  Edit)
    CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('new_string',''))" 2>/dev/null)
    ;;
  MultiEdit)
    CONTENT=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
edits=d.get('tool_input',{}).get('edits',[])
print(' '.join(e.get('new_string','') for e in edits))
" 2>/dev/null)
    ;;
  *)
    RECOGNIZED=false
    ;;
esac

# Fail-safe: never silently allow. If content extraction produced nothing —
# whether tool_name was unparseable/unexpected, or the tool_input shape changed
# so extraction returned empty — fall back to scanning the RAW hook payload so a
# secret cannot slip through on a payload we failed to parse. (Claude Code
# currently emits compact JSON that parses cleanly, so this is defense-in-depth,
# not the hot path.) A recognized tool with genuinely empty content scans the
# raw payload too, but stays silent — only an unrecognized/unparseable tool
# warns, so a legitimate empty-file write is not noisy.
if [ -z "$CONTENT" ]; then
  CONTENT="$INPUT"
  [ "$RECOGNIZED" = false ] && FELL_BACK=true
fi

# === BLOCK PATTERNS (exit 2) — secrets and credentials ===
BLOCK_PATTERNS=(
  'API_KEY\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded API key'
  'api_key\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded API key'
  'password\s*=\s*["\x27][^\x27"]{4,}["\x27]:Hardcoded password'
  'PASSWORD\s*=\s*["\x27][^\x27"]{4,}["\x27]:Hardcoded password'
  'ghp_[A-Za-z0-9]{36,}:GitHub personal access token'
  'gho_[A-Za-z0-9]{36,}:GitHub OAuth token'
  'ghs_[A-Za-z0-9]{36,}:GitHub server token'
  'AKIA[A-Z0-9]{16}:AWS access key ID'
  'xox[bpsar]-[A-Za-z0-9\-]{10,}:Slack token'
  '-----BEGIN[A-Z ]*PRIVATE KEY-----:Private key block'
  'eyJ[A-Za-z0-9_-]{15,}\.[A-Za-z0-9_-]{15,}:JWT token'
  'AIza[0-9A-Za-z_-]{35}:Google API key'
  'DefaultEndpointsProtocol=https;AccountName=:Azure connection string'
  'mongodb(\+srv)?://[^\s]+:MongoDB connection string'
  '[Tt]oken\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded token'
  'GITHUB_TOKEN\s*=\s*["\x27][^\x27"]{4,}["\x27]:GitHub token assignment'
  'GH_TOKEN\s*=\s*["\x27][^\x27"]{4,}["\x27]:GitHub token assignment'
  'Bearer\s+[A-Za-z0-9_\-\.]{20,}:Bearer token in code'
  'Authorization:\s*Bearer\s+[A-Za-z0-9_\-\.]{20,}:Hardcoded Authorization header'
  'oauth_token\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded OAuth token'
  'refresh_token\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded refresh token'
  'client_secret\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded client secret'
)

# Convention: DESC must not contain a colon — splitter uses last-colon delimiter
# so regexes containing colons (URI schemes, header names) reconstruct correctly.
for ENTRY in "${BLOCK_PATTERNS[@]}"; do
  PATTERN="${ENTRY%:*}"
  DESC="${ENTRY##*:}"

  if echo "$CONTENT" | grep -qE -- "$PATTERN"; then
    echo "Governance: Blocked — $DESC detected in file content." >&2
    echo "" >&2
    echo "Use environment variables instead of hardcoding secrets:" >&2
    echo "  JS/TS:  const value = process.env.YOUR_SECRET" >&2
    echo "  Python: value = os.environ['YOUR_SECRET']" >&2
    echo "  Go:     value := os.Getenv(\"YOUR_SECRET\")" >&2
    echo "" >&2
    echo "To fix: replace the hardcoded value with an environment variable reference." >&2
    exit 2
  fi
done

# === DIGIT-REQUIRED BLOCK PATTERNS (exit 2) — sk-shaped keys (issue #29) ===
# These patterns use a two-stage check:
#   (1) base regex must match — with left word boundary that rejects matches
#       preceded by a letter (avoids the canonical NIST AI {ri}{sk}-management URL slug)
#   (2) the matched text must contain at least one digit (real OpenAI/Stripe/Anthropic
#       keys are alphanumeric with digits; English compounds are letters-only)
# Convention: DESC must not contain a colon (same as BLOCK_PATTERNS — see below).
DIGIT_REQUIRED_BLOCK_PATTERNS=(
  '(^|[^A-Za-z])sk-[A-Za-z0-9_-]{20,}:OpenAI/Stripe secret key'
  '(^|[^A-Za-z])sk-proj-[A-Za-z0-9_-]{20,}:OpenAI project key'
  '(^|[^A-Za-z])sk-ant-[A-Za-z0-9_-]{20,}:Anthropic API key'
)

for ENTRY in "${DIGIT_REQUIRED_BLOCK_PATTERNS[@]}"; do
  PATTERN="${ENTRY%:*}"
  DESC="${ENTRY##*:}"

  # Stage 1: extract all matches of the base pattern
  MATCHES=$(echo "$CONTENT" | grep -oE -- "$PATTERN" 2>/dev/null)

  # Stage 2: only block if at least one match contains a digit
  if [[ -n "$MATCHES" ]] && echo "$MATCHES" | grep -qE '[0-9]'; then
    echo "Governance: Blocked — $DESC detected in file content." >&2
    echo "" >&2
    echo "Use environment variables instead of hardcoding secrets:" >&2
    echo "  JS/TS:  const value = process.env.YOUR_SECRET" >&2
    echo "  Python: value = os.environ['YOUR_SECRET']" >&2
    echo "  Go:     value := os.Getenv(\"YOUR_SECRET\")" >&2
    echo "" >&2
    echo "To fix: replace the hardcoded value with an environment variable reference." >&2
    exit 2
  fi
done

# === WARN PATTERNS (exit 0 + stderr) — PII detection [DSGAI01] ===
WARN_PATTERNS=(
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}:Possible email address (PII)'
  '\b[0-9]{3}-[0-9]{2}-[0-9]{4}\b:Possible SSN (PII)'
  '\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\b:Possible credit card number (PII)'
)

PII_WARNED=false

for ENTRY in "${WARN_PATTERNS[@]}"; do
  PATTERN="${ENTRY%:*}"
  DESC="${ENTRY##*:}"

  if echo "$CONTENT" | grep -qE -- "$PATTERN"; then
    echo "Governance: WARNING — $DESC. Review before committing." >&2
    PII_WARNED=true
  fi
done

if [ "$PII_WARNED" = true ]; then
  echo "" >&2
  echo "PII detected. Ensure data handling complies with your data classification policy." >&2
  echo "See: examples/DATA-CLASSIFICATION.md.example for guidance. [DSGAI01]" >&2
fi

# Surface a parse-failure fallback (never silent). We reached here without
# blocking, so no secret was found in the raw payload — but the operator should
# know the structured path failed so a recurring failure can be investigated.
if [ "${FELL_BACK:-false}" = true ]; then
  echo "Governance: WARNING — could not parse tool payload (tool_name='${TOOL_NAME:-<empty>}'); scanned raw input as a fallback, no secret found. If this recurs, the hook's JSON parsing may need updating." >&2
fi

exit 0
