#!/usr/bin/env bash
# Copy workshop implementation specs into a local clone of agent-ready-skill.
# Usage:
#   ./copy-specs-to-skills.sh <path-to-agent-ready-skill-clone>
#   ./copy-specs-to-skills.sh ../agent-ready-skill
#
# Idempotent — safe to re-run. Does not touch git state (no commits, no
# branch creation). Prints the suggested next commands at the end.

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-../agent-ready-skill}"

# ── Validate source ──────────────────────────────────────────────────────
SPECS=(
  "02-competitive-analysis.md"
  "05-implementation-plan.md"
  "06-implementation-plan-rest.md"
  "HANDOFF-PROMPT.md"
)
for spec in "${SPECS[@]}"; do
  if [[ ! -f "${SOURCE_DIR}/${spec}" ]]; then
    echo "✗ Missing source file: ${SOURCE_DIR}/${spec}" >&2
    exit 1
  fi
done

# ── Validate target ──────────────────────────────────────────────────────
if [[ ! -d "${TARGET}" ]]; then
  echo "✗ Target directory does not exist: ${TARGET}" >&2
  echo "  Clone it first: git clone git@github.com:RisorseArtificiali/agent-ready-skill.git" >&2
  exit 1
fi

TARGET="$(cd "${TARGET}" && pwd)"

if [[ ! -d "${TARGET}/.git" ]]; then
  echo "✗ Target is not a git repository: ${TARGET}" >&2
  exit 1
fi

if [[ ! -d "${TARGET}/skills/agent-ready" ]]; then
  echo "✗ Target does not look like agent-ready-skill (no skills/agent-ready/): ${TARGET}" >&2
  echo "  Make sure you pointed at the right clone." >&2
  exit 1
fi

# ── Copy ─────────────────────────────────────────────────────────────────
DEST="${TARGET}/docs/workshop"
mkdir -p "${DEST}"

echo "→ Copying specs into ${DEST}/"
for spec in "${SPECS[@]}"; do
  cp "${SOURCE_DIR}/${spec}" "${DEST}/${spec}"
  size=$(wc -l < "${DEST}/${spec}")
  printf "  ✓ %-40s (%s lines)\n" "${spec}" "${size}"
done

# ── Next steps ───────────────────────────────────────────────────────────
cat <<EOF

Done. Suggested next steps in ${TARGET}:

  cd "${TARGET}"
  git status                              # confirm only docs/workshop/ is new
  git checkout -b workshop/pycon-2026     # if not already on a workshop branch
  git add docs/workshop/
  git commit -m "docs: add workshop implementation specs"

Then start Claude Code (or your agent) inside ${TARGET} and paste the prompt
from docs/workshop/HANDOFF-PROMPT.md (the fenced block under "The prompt").
EOF
