#!/usr/bin/env bash
PASS=0; FAIL=0; SKIP=0; CURRENT_TEST=""; CURRENT_STACK=""
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
describe() { CURRENT_STACK="$1"; echo -e "\n${BOLD}${CYAN}--- $1 ---${RESET}"; }
it() { CURRENT_TEST="$1"; echo -n "  $1... "; }
pass() { ((PASS++)); echo -e "${GREEN}PASS${RESET}"; }
fail() { ((FAIL++)); echo -e "${RED}FAIL${RESET}${1:+ - $1}"; }
skip() { ((SKIP++)); echo -e "${YELLOW}SKIP${RESET}"; }
assert_eq() { [ "$1" = "$2" ] && pass || fail "expected '$2' got '$1'"; }
assert_http() { local r=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$1" 2>/dev/null||echo 000); [ "$r" = "$2" ] && pass || fail "HTTP $r"; }
assert_http_200() { assert_http "$1" 200; }
assert_container_running() { local s=$(docker inspect -f '{{.State.Status}}' "$1" 2>/dev/null||echo gone); [ "$s" = "running" ] && pass || fail "$1: $s"; }
assert_container_healthy() { local h=$(docker inspect -f '{{.State.Health.Status}}' "$1" 2>/dev/null||echo none); [ "$h" = "healthy" ] && pass || fail "$1: $h"; }
assert_file_exists() { [ -f "$1" ] && pass || fail "missing: $1"; }
assert_file_contains() { [ -f "$1" ] && grep -qF "$2" "$1" && pass || fail "'$2' not in $1"; }
assert_true() { eval "$1" &>/dev/null && pass || fail "${2:-command false}"; }
print_summary() { local t=$((PASS+FAIL+SKIP)); echo -e "\n${BOLD}Results: ${GREEN}$PASS pass${RESET} ${RED}$FAIL fail${RESET} ${YELLOW}$SKIP skip${RESET}"; [ $FAIL -gt 0 ] && return 1 || return 0; }