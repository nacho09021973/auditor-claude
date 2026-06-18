#!/usr/bin/env bash
# Auditor Claude — heuristic integrity audit for AI-assisted projects.
#
# Flags the patterns that AI coding tools use to fake success:
#   - CI steps that swallow failures (|| true, || echo, continue-on-error)
#   - committed result/data files that no script generates
#   - a repo with no real tests
#
# Usage:  bash audit.sh [path-to-repo]      (defaults to the current repo)
#
# Exit codes: 0 = clean, 1 = errors found, 2 = bad invocation.
# Errors are high-confidence and gate CI. "Data file without generator" is a
# heuristic warning (may have false positives) and does not fail the run.
set -uo pipefail

target="${1:-.}"
root="$(git -C "$target" rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$root" ]; then
  echo "Auditor Claude: '$target' is not inside a git repository." >&2
  exit 2
fi
cd "$root" || exit 2

echo "Auditor Claude — auditing: $root"
echo "----------------------------------------"

errors=0
warnings=0

# 1. CI that swallows failures ------------------------------------------------
if ls .github/workflows/*.y*ml >/dev/null 2>&1; then
  hits="$(grep -nE '\|\|[[:space:]]*(true|echo)|continue-on-error:[[:space:]]*true' \
           .github/workflows/*.y*ml 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    echo "ERROR: CI may be swallowing failures (|| true / || echo / continue-on-error):"
    echo "$hits" | sed 's/^/    /'
    errors=$((errors + 1))
  fi
fi

# 2. Are there any real test files? ------------------------------------------
# Only relevant if the repo actually contains application code. Static sites
# (html/css/md/xml) and shell-only tool repos legitimately have no unit tests,
# so we skip the check for them instead of raising a false positive.
appcode="$(git ls-files '*.py' '*.js' '*.jsx' '*.ts' '*.tsx' '*.go' '*.rs' \
            '*.rb' '*.java' '*.c' '*.cc' '*.cpp' '*.kt' '*.scala' 2>/dev/null | head -1)"
if [ -n "$appcode" ]; then
  testcount="$(git ls-files '*test_*.py' '*_test.py' 'tests/**' '*.test.*' '*_test.go' 2>/dev/null \
               | grep -cE '\.(py|js|ts|go|rs)$' || true)"
  if [ "${testcount:-0}" -eq 0 ]; then
    echo "ERROR: application code present but no test files found (e.g. tests/ or test_*.py)."
    errors=$((errors + 1))
  fi
else
  echo "note: no application code detected; skipping test-presence check."
fi

# 3. Committed result/data files with no generator reference -----------------
datafiles="$( { git ls-files '*.csv' '*.tsv' '*.out' '*.parquet' 2>/dev/null;
                git ls-files 'data/*' 'results/*' 'outputs/*' 2>/dev/null; } \
              | sort -u | grep -vE '\.(md|py|txt|gitkeep|json)$' || true)"
for f in $datafiles; do
  [ -z "$f" ] && continue
  base="$(basename "$f")"
  if ! git grep -q -- "$base" -- '*.py' '*.sh' '*.js' '*.ts' '*.ipynb' '*.go' '*.rs' 'Makefile' 2>/dev/null; then
    echo "WARN: committed data file with no generator reference: $f"
    warnings=$((warnings + 1))
  fi
done

echo "----------------------------------------"
echo "Auditor Claude: ${errors} error(s), ${warnings} warning(s)"
[ "$errors" -gt 0 ] && exit 1
exit 0
