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

# Extract content to scan based on tool type
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name":"[^"]*"' | head -1 | cut -d'"' -f4)

CONTENT=""
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
    exit 0
    ;;
esac

# If no content extracted, allow
if [ -z "$CONTENT" ]; then
  exit 0
fi

# === BLOCK PATTERNS (exit 2) — secrets and credentials ===
BLOCK_PATTERNS=(
  'API_KEY\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded API key'
  'api_key\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded API key'
  'password\s*=\s*["\x27][^\x27"]{4,}["\x27]:Hardcoded password'
  'PASSWORD\s*=\s*["\x27][^\x27"]{4,}["\x27]:Hardcoded password'
  'sk-[A-Za-z0-9_-]{20,}:OpenAI/Stripe secret key'
  'sk-proj-[A-Za-z0-9_-]{20,}:OpenAI project key'
  'sk-ant-[A-Za-z0-9_-]{20,}:Anthropic API key'
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

exit 0
