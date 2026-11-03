#!/usr/bin/env bash
# Open the firewall for the Open WebUI port (firewalld).
# Usage: ./scripts/05-firewall.sh [8080|3000]
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$DIR/lib.sh"

PORT="${1:-8080}"
have firewall-cmd || die "firewalld is not installed (dnf install firewalld)."
$SUDO systemctl enable --now firewalld

$SUDO firewall-cmd --permanent --add-port="${PORT}/tcp"
$SUDO firewall-cmd --permanent --add-service=http
$SUDO firewall-cmd --reload
ok "Firewall opened for ${PORT}/tcp and http."
