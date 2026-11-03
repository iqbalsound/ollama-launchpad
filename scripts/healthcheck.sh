#!/usr/bin/env bash
# Quick diagnostic of the whole stack.
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

FAIL=0
check() { # check "label" command...
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then ok "$label"; else err "$label"; FAIL=1; fi
}

check "Docker installed"            have docker
check "Docker daemon running"       systemctl is-active --quiet docker
check "Ollama installed"            have ollama
check "Ollama API responds"         curl -fsS http://127.0.0.1:11434/api/version
check "At least one model pulled"   bash -c 'curl -fsS http://127.0.0.1:11434/api/tags | grep -q "\"name\""'
D="$(docker_cmd)"
check "open-webui container running" bash -c "$D ps --format '{{.Names}}' | grep -qx open-webui"
if curl -fsS -o /dev/null http://127.0.0.1:8080 2>/dev/null; then
  ok "Open WebUI answers on :8080"
elif curl -fsS -o /dev/null http://127.0.0.1:3000 2>/dev/null; then
  ok "Open WebUI answers on :3000"
else
  err "Open WebUI does not answer on :8080 or :3000"; FAIL=1
fi

echo
if [ "$FAIL" -eq 0 ]; then ok "Everything looks good."; else warn "Some checks failed. See docs/TROUBLESHOOTING.md"; fi
exit "$FAIL"
