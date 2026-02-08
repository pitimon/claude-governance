#!/usr/bin/env bash

# Install governance rules to ~/.claude/rules/
# Usage: bash install-rules.sh [--all|--governance-only]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_SRC="$SCRIPT_DIR/../examples/rules"
RULES_DEST="$HOME/.claude/rules"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "claude-governance — Rule Installer"
echo "==================================="
echo ""

# Check source exists
if [ ! -d "$RULES_SRC" ]; then
  echo "Error: Rules directory not found at $RULES_SRC"
  exit 1
fi

# Create destination
mkdir -p "$RULES_DEST"

# Determine which rules to install
MODE="${1:---all}"

RULES=()
case "$MODE" in
  --governance-only)
    RULES=("governance.md")
    ;;
  --all|*)
    RULES=("governance.md" "coding-style.md" "git-workflow.md" "testing.md" "security.md")
    ;;
esac

# Install with backup
INSTALLED=0
BACKED_UP=0

for RULE in "${RULES[@]}"; do
  SRC="$RULES_SRC/$RULE"
  DEST="$RULES_DEST/$RULE"

  if [ ! -f "$SRC" ]; then
    echo "  Skip: $RULE (not found in source)"
    continue
  fi

  # Backup existing
  if [ -f "$DEST" ]; then
    BACKUP="$DEST.backup.$(date +%Y%m%d%H%M%S)"
    cp "$DEST" "$BACKUP"
    echo -e "  ${YELLOW}Backup${NC}: $RULE -> $(basename "$BACKUP")"
    BACKED_UP=$((BACKED_UP + 1))
  fi

  cp "$SRC" "$DEST"
  echo -e "  ${GREEN}Installed${NC}: $RULE"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Done: $INSTALLED rules installed, $BACKED_UP backups created"
echo "Location: $RULES_DEST"
