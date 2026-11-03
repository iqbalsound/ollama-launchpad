#!/usr/bin/env bash
# Start Open WebUI in Docker.
# Usage: ./scripts/04-run-open-webui.sh [host|bridge]
#   host   (default) --network=host, UI on port 8080, talks to Ollama on 127.0.0.1
#   bridge published port 3000 -> 8080, talks to Ollama through host.docker.internal
#          (requires: scripts/02-install-ollama.sh --expose)
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

MODE="${1:-host}"
IMAGE="ghcr.io/open-webui/open-webui:main"
NAME="open-webui"
D="$(docker_cmd)"

have docker || die "Docker is not installed. Run scripts/01-install-docker.sh first."

info "Pulling $IMAGE ..."
$D pull "$IMAGE"

if $D ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  warn "Removing existing '$NAME' container (data volume 'open-webui' is kept)."
  $D rm -f "$NAME" >/dev/null
fi

case "$MODE" in
  host)
    $D run -d --network=host \
      -v open-webui:/app/backend/data \
      -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
      --name "$NAME" --restart always "$IMAGE"
    URL="http://$(primary_ip):8080/"
    ;;
  bridge)
    $D run -d -p 3000:8080 \
      --add-host=host.docker.internal:host-gateway \
      -v open-webui:/app/backend/data \
      -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
      --name "$NAME" --restart always "$IMAGE"
    URL="http://$(primary_ip):3000/"
    ;;
  *) die "Unknown mode '$MODE'. Use 'host' or 'bridge'." ;;
esac

ok "Open WebUI started. Give it ~30-60 seconds on first boot."
echo "  Open: ${BOLD}${URL}${RESET}"
echo "  The first account you create becomes the admin."
