#!/usr/bin/env bash
# Install Docker Engine + Compose plugin on RHEL-family distros.
# Usage: ./scripts/01-install-docker.sh [--insecure-socket]
#   --insecure-socket  replicate the original notes (chmod 666 /var/run/docker.sock).
#                      NOT recommended: any local user gets root-equivalent access.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

INSECURE=0
[ "${1:-}" = "--insecure-socket" ] && INSECURE=1

detect_os

if have docker; then
  ok "Docker already installed: $(docker --version)"
else
  info "Installing Docker Engine..."
  $SUDO dnf install -y dnf-plugins-core
  if [ "${OS_ID}" = "fedora" ]; then
    REPO_URL="https://download.docker.com/linux/fedora/docker-ce.repo"
  else
    REPO_URL="https://download.docker.com/linux/rhel/docker-ce.repo"
  fi
  if dnf --version 2>/dev/null | grep -qi dnf5; then
    $SUDO dnf config-manager addrepo --from-repofile="$REPO_URL"
  else
    $SUDO dnf config-manager --add-repo "$REPO_URL"
  fi
  $SUDO dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ok "Docker installed."
fi

info "Enabling and starting the Docker daemon..."
$SUDO systemctl enable --now docker
ok "Docker daemon is running."

if [ "$INSECURE" -eq 1 ]; then
  warn "Applying chmod 666 to /var/run/docker.sock (insecure, resets on restart)."
  $SUDO chmod 666 /var/run/docker.sock
else
  TARGET_USER="${SUDO_USER:-$USER}"
  if [ "$TARGET_USER" != "root" ]; then
    $SUDO usermod -aG docker "$TARGET_USER"
    ok "Added '$TARGET_USER' to the docker group."
    warn "Log out and back in (or run: newgrp docker) for the group change to apply."
  fi
fi
