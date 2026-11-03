#!/usr/bin/env bash
# Install Ollama (needs zstd + tar) and optionally expose it to Docker containers.
# Usage: ./scripts/02-install-ollama.sh [--expose]
#   --expose  make Ollama listen on 0.0.0.0:11434 (required for the bridge/port-3000 UI mode).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

EXPOSE=0
[ "${1:-}" = "--expose" ] && EXPOSE=1

detect_os

info "Installing prerequisites (tar, zstd, curl)..."
$SUDO dnf install -y tar zstd curl

if have ollama; then
  ok "Ollama already installed: $(ollama --version 2>&1 | tail -n1)"
else
  info "Downloading and running the official Ollama installer..."
  curl -fsSL https://ollama.com/install.sh | sh
  ok "Ollama installed."
fi

if [ "$EXPOSE" -eq 1 ]; then
  info "Configuring Ollama to listen on all interfaces..."
  $SUDO mkdir -p /etc/systemd/system/ollama.service.d
  printf '[Service]\nEnvironment="OLLAMA_HOST=0.0.0.0:11434"\n' | $SUDO tee /etc/systemd/system/ollama.service.d/override.conf >/dev/null
  $SUDO systemctl daemon-reload
  $SUDO systemctl restart ollama
  ok "Ollama now listens on 0.0.0.0:11434."
  warn "Do not open port 11434 to the internet; the API has no authentication."
else
  $SUDO systemctl enable --now ollama 2>/dev/null || true
fi

sleep 2
if curl -fsS http://127.0.0.1:11434/api/version >/dev/null 2>&1; then
  ok "Ollama API is reachable on 127.0.0.1:11434."
else
  warn "Ollama API did not respond yet. Check: systemctl status ollama"
fi
