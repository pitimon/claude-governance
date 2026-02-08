#!/usr/bin/env bash

# Secret scanner hook — blocks file writes containing hardcoded secrets
# Runs as PreToolUse hook on Edit|Write|MultiEdit
# Exit 0 = allow, Exit 2 = block

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

# Scan for secret patterns
# Each pattern: regex + description
PATTERNS=(
  'API_KEY\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded API key'
  'api_key\s*=\s*["\x27][A-Za-z0-9_\-]{10,}["\x27]:Hardcoded API key'
  'password\s*=\s*["\x27][^\x27"]{4,}["\x27]:Hardcoded password'
  'PASSWORD\s*=\s*["\x27][^\x27"]{4,}["\x27]:Hardcoded password'
  'sk-[A-Za-z0-9]{20,}:OpenAI/Stripe secret key'
  'sk-proj-[A-Za-z0-9]{20,}:OpenAI project key'
  'ghp_[A-Za-z0-9]{36,}:GitHub personal access token'
  'gho_[A-Za-z0-9]{36,}:GitHub OAuth token'
  'ghs_[A-Za-z0-9]{36,}:GitHub server token'
  'AKIA[A-Z0-9]{16}:AWS access key ID'
  'xox[bpsar]-[A-Za-z0-9\-]{10,}:Slack token'
)

for ENTRY in "${PATTERNS[@]}"; do
  PATTERN="${ENTRY%%:*}"
  DESC="${ENTRY##*:}"

  if echo "$CONTENT" | grep -qE "$PATTERN"; then
    echo "Governance: Blocked — $DESC detected in file content." >&2
    echo "" >&2
    echo "Use environment variables instead of hardcoding secrets:" >&2
    echo "  const value = process.env.YOUR_SECRET" >&2
    echo "" >&2
    echo "To fix: replace the hardcoded value with an environment variable reference." >&2
    exit 2
  fi
done

exit 0
