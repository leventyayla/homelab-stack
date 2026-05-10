#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")
[ -f "$ROOT_DIR/.env" ] && { set -a; source "$ROOT_DIR/.env"; set +a; }
MODE="all"
while [[ $# -gt 0 ]]; do case "$1" in --stack) STACK_FILTER="$2"; MODE="stack"; shift 2;; *) shift;; esac; done
source "${SCRIPT_DIR}/lib/assert.sh"
describe "Environment"
it "Docker running"; assert_true "docker info &>/dev/null"
it "jq installed"; assert_true "command -v jq &>/dev/null"
for f in "$SCRIPT_DIR"/stacks/*.test.sh; do
  [ -f "$f" ] || continue
  s=$(basename "$f" .test.sh)
  [ "$MODE" = "stack" ] && ! echo ",${STACK_FILTER:-}," | grep -q ",$s," && continue
  bash "$f" 2>&1 || true
done
print_summary