#!/usr/bin/env bash
# Shared helpers for OllamaLaunchpad scripts. Source this file; do not run it.
# shellcheck disable=SC2034  # variables are consumed by the scripts that source this file

if [ -t 1 ]; then
  RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; BOLD=""; RESET=""
fi

info()  { echo "${BLUE}[INFO]${RESET} $*"; }
ok()    { echo "${GREEN}[ OK ]${RESET} $*"; }
warn()  { echo "${YELLOW}[WARN]${RESET} $*"; }
err()   { echo "${RED}[FAIL]${RESET} $*" >&2; }
die()   { err "$*"; exit 1; }

# Ask a yes/no question. Usage: confirm "Question?" [default y|n]
confirm() {
  local prompt="$1" default="${2:-y}" reply hint="[Y/n]"
  [ "$default" = "n" ] && hint="[y/N]"
  read -r -p "$prompt $hint " reply || true
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

have() { command -v "$1" >/dev/null 2>&1; }

# Use sudo only when we are not root.
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  have sudo || die "This script needs root or sudo."
  SUDO="sudo"
fi

# Detect the distro and make sure it is dnf-based.
detect_os() {
  [ -r /etc/os-release ] || die "Cannot read /etc/os-release."
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_ID="${ID:-unknown}"
  if ! have dnf; then
    die "dnf not found. These scripts target RHEL-family systems (Rocky, Alma, CentOS Stream, RHEL, Fedora). See docs/TROUBLESHOOTING.md for Debian/Ubuntu."
  fi
  ok "Detected OS: ${PRETTY_NAME:-$OS_ID}"
}

# Pick `docker` or `sudo docker` depending on group membership / socket access.
docker_cmd() {
  if docker info >/dev/null 2>&1; then
    echo "docker"
  else
    echo "$SUDO docker"
  fi
}

# Best-effort primary IPv4 address of this machine.
primary_ip() {
  hostname -I 2>/dev/null | awk '{print $1}'
}
