#!/usr/bin/env bash
# OllamaLaunchpad - interactive installer (RHEL-family: Rocky, Alma, CentOS Stream, RHEL, Fedora)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$ROOT/scripts/lib.sh"

banner() {
cat <<'B'
   ___  _ _                          _                           _
  / _ \| | | __ _ _ __ ___   __ _   | |    __ _ _   _ _ __   ___| |__  _ __   __ _  __| |
 | | | | | |/ _` | '_ ` _ \ / _` |  | |   / _` | | | | '_ \ / __| '_ \| '_ \ / _` |/ _` |
 | |_| | | | (_| | | | | | | (_| |  | |__| (_| | |_| | | | | (__| | | | |_) | (_| | (_| |
  \___/|_|_|\__,_|_| |_| |_|\__,_|  |_____\__,_|\__,_|_| |_|\___|_| |_| .__/ \__,_|\__,_|
                                                                      |_|
        Your private AI lab: Docker + Ollama + Open WebUI in minutes
B
}

full_install() {
  echo
  echo "Choose how the web UI should run:"
  echo "  1) host   - network=host, UI on :8080 (simplest, matches the original notes)"
  echo "  2) bridge - published port :3000 (isolated; Ollama must be exposed)"
  read -r -p "Mode [1/2, default 1]: " m || true
  local mode="host" port=8080 expose=""
  if [ "${m:-1}" = "2" ]; then mode="bridge"; port=3000; expose="--expose"; fi

  bash "$ROOT/scripts/01-install-docker.sh"
  # shellcheck disable=SC2086
  bash "$ROOT/scripts/02-install-ollama.sh" $expose
  select_models
  bash "$ROOT/scripts/04-run-open-webui.sh" "$mode"
  if have firewall-cmd && confirm "Open firewall port ${port}?" y; then
    bash "$ROOT/scripts/05-firewall.sh" "$port"
  fi
  bash "$ROOT/scripts/healthcheck.sh" || true
}

select_models() {
  echo
  echo "Pick models to download (space-separated numbers, Enter for starter set):"
  echo "  1) deepseek-r1:1.5b  (~1.1 GB, tiny reasoning model)"
  echo "  2) smollm2:1.7b      (~1.8 GB, fast, light)"
  echo "  3) mistral           (~4.1 GB, solid all-rounder)"
  echo "  4) gemma3:4b         (~3.3 GB, Google, multilingual)"
  echo "  5) llama3.2:3b       (~2.0 GB, Meta, chat)"
  echo "  6) qwen2.5-coder:7b  (~4.7 GB, coding)"
  echo "  7) custom name"
  read -r -p "Selection [default: 1 2 3]: " sel || true
  sel="${sel:-1 2 3}"
  local models=()
  for n in $sel; do
    case "$n" in
      1) models+=("deepseek-r1:1.5b");; 2) models+=("smollm2:1.7b");; 3) models+=("mistral");;
      4) models+=("gemma3:4b");; 5) models+=("llama3.2:3b");; 6) models+=("qwen2.5-coder:7b");;
      7) read -r -p "Model name (e.g. phi3:mini): " c; [ -n "${c:-}" ] && models+=("$c");;
    esac
  done
  bash "$ROOT/scripts/03-pull-models.sh" "${models[@]}"
}

menu() {
  while true; do
    clear 2>/dev/null || true
    banner
    echo
    echo "  1) Full guided install (Docker + Ollama + models + Open WebUI)"
    echo "  2) Install Docker only"
    echo "  3) Install Ollama only"
    echo "  4) Pull / add models"
    echo "  5) Start Open WebUI (host mode, :8080)"
    echo "  6) Start Open WebUI (bridge mode, :3000)"
    echo "  7) Open firewall port"
    echo "  8) Health check"
    echo "  9) Uninstall / clean up"
    echo "  0) Exit"
    echo
    read -r -p "Choose an option: " c || exit 0
    case "$c" in
      1) full_install;;
      2) bash "$ROOT/scripts/01-install-docker.sh";;
      3) bash "$ROOT/scripts/02-install-ollama.sh";;
      4) select_models;;
      5) bash "$ROOT/scripts/04-run-open-webui.sh" host;;
      6) bash "$ROOT/scripts/04-run-open-webui.sh" bridge;;
      7) read -r -p "Port [8080]: " p; bash "$ROOT/scripts/05-firewall.sh" "${p:-8080}";;
      8) bash "$ROOT/scripts/healthcheck.sh" || true;;
      9) bash "$ROOT/scripts/99-uninstall.sh";;
      0) echo "Bye!"; exit 0;;
      *) warn "Invalid option";;
    esac
    echo; read -r -p "Press Enter to return to the menu..." _ || exit 0
  done
}

case "${1:-}" in
  --all) full_install;;
  --help|-h) echo "Usage: ./install.sh [--all]   (no args = interactive menu)";;
  *) menu;;
esac
