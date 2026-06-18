#!/usr/bin/env bash
# Auditor Claude — install the integrity guardrails into a target project.
#
# Usage:  bash install.sh /path/to/your/repo
#
# Copies (without overwriting existing files):
#   - CLAUDE.md                      (integrity rules)
#   - Makefile                       (test / smoke / data / check-reproducible / audit)
#   - .github/workflows/ci.yml       (honest CI)
#   - scripts/audit.sh               (the auditor itself)
#
# Existing files are never clobbered; you get a ".auditor-claude" copy beside
# them to merge by hand.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:-}"

if [ -z "$target" ] || [ ! -d "$target" ]; then
  echo "Usage: bash install.sh /path/to/your/repo" >&2
  exit 2
fi

copy() {  # copy SRC DEST  — never overwrite; write DEST.auditor-claude instead
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    cp "$src" "$dest.auditor-claude"
    echo "  exists: $dest  ->  wrote $dest.auditor-claude (merge by hand)"
  else
    cp "$src" "$dest"
    echo "  added:  $dest"
  fi
}

echo "Installing Auditor Claude guardrails into: $target"
copy "$here/templates/CLAUDE.md" "$target/CLAUDE.md"
copy "$here/templates/Makefile"  "$target/Makefile"
copy "$here/templates/ci.yml"    "$target/.github/workflows/ci.yml"
copy "$here/audit.sh"            "$target/scripts/audit.sh"
chmod +x "$target/scripts/audit.sh" 2>/dev/null || true

echo
echo "Done. Next:"
echo "  1. Edit the '### FILL ME' placeholders in CLAUDE.md and Makefile."
echo "  2. Run: bash $target/scripts/audit.sh"
echo "  3. Commit."
