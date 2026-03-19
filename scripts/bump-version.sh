#!/usr/bin/env bash
# bump-version.sh — Update version across plugin.json, marketplace.json, and CHANGELOG.md
# Usage: bash scripts/bump-version.sh <new-version>
# Example: bash scripts/bump-version.sh 2.2.0
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
CHANGELOG="$REPO_ROOT/CHANGELOG.md"

# --- Validate arguments ---
if [[ $# -ne 1 ]]; then
  echo "Usage: bash scripts/bump-version.sh <new-version>"
  echo "Example: bash scripts/bump-version.sh 2.2.0"
  exit 1
fi

NEW_VERSION="$1"

# Validate semver format
if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: '$NEW_VERSION' is not valid semver (expected X.Y.Z)"
  exit 1
fi

# --- Read current version ---
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")

if [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
  echo "Error: version is already $NEW_VERSION"
  exit 1
fi

echo "Bumping version: $CURRENT_VERSION → $NEW_VERSION"

# --- Update plugin.json ---
python3 -c "
import json

with open('$PLUGIN_JSON', 'r') as f:
    d = json.load(f)
d['version'] = '$NEW_VERSION'
with open('$PLUGIN_JSON', 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
echo "  Updated plugin.json"

# --- Update marketplace.json ---
python3 -c "
import json

with open('$MARKETPLACE_JSON', 'r') as f:
    d = json.load(f)
d['plugins'][0]['version'] = '$NEW_VERSION'
with open('$MARKETPLACE_JSON', 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
"
echo "  Updated marketplace.json"

# --- Insert CHANGELOG header ---
TODAY=$(date +%Y-%m-%d)
HEADER="## [$NEW_VERSION] - $TODAY"

python3 -c "
import re

with open('$CHANGELOG', 'r') as f:
    content = f.read()

# Insert new version header before the first existing version entry
insertion = '$HEADER\n\n### Added\n\n### Changed\n\n### Fixed\n\n'
content = re.sub(r'(## \[\d)', insertion + r'\1', content, count=1)

with open('$CHANGELOG', 'w') as f:
    f.write(content)
"
echo "  Updated CHANGELOG.md with $HEADER"

# --- Verify sync ---
VER_PLUGIN=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")
VER_MKT=$(python3 -c "import json; print(json.load(open('$MARKETPLACE_JSON'))['plugins'][0]['version'])")

if [[ "$VER_PLUGIN" == "$NEW_VERSION" && "$VER_MKT" == "$NEW_VERSION" ]]; then
  echo ""
  echo "Version bump complete: $CURRENT_VERSION → $NEW_VERSION"
  echo "  plugin.json:      $VER_PLUGIN"
  echo "  marketplace.json:  $VER_MKT"
  echo "  CHANGELOG.md:     header inserted"
  echo ""
  echo "Next: fill in CHANGELOG.md entries, then commit."
else
  echo "Error: version sync failed"
  echo "  plugin.json:      $VER_PLUGIN"
  echo "  marketplace.json:  $VER_MKT"
  exit 1
fi
