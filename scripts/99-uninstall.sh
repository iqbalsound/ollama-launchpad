#!/usr/bin/env bash
# Remove the Open WebUI container (and optionally its data, Ollama and models).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

D="$(docker_cmd)"
if have docker && $D ps -a --format '{{.Names}}' | grep -qx open-webui; then
  $D rm -f open-webui && ok "Removed open-webui container."
fi

if confirm "Also delete the Open WebUI data volume (chats, users)?" n; then
  $D volume rm open-webui && ok "Volume removed."
fi

if confirm "Uninstall Ollama and delete ALL downloaded models?" n; then
  $SUDO systemctl disable --now ollama 2>/dev/null || true
  $SUDO rm -f /etc/systemd/system/ollama.service /usr/local/bin/ollama
  $SUDO rm -rf /etc/systemd/system/ollama.service.d /usr/share/ollama
  $SUDO userdel ollama 2>/dev/null || true
  $SUDO groupdel ollama 2>/dev/null || true
  $SUDO systemctl daemon-reload
  ok "Ollama removed."
fi
