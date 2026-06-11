#!/usr/bin/env bash
# Preflight: verify we're on Ubuntu 26.04, running as a normal user with sudo,
# with internet access. Refresh apt and install base build tools.

set -eEo pipefail
source "$REPO_ROOT/lib/helpers.sh"

require_ubuntu() {
  if [ ! -r /etc/os-release ]; then
    die "Cannot read /etc/os-release. Is this Ubuntu?"
  fi
  # shellcheck disable=SC1091
  . /etc/os-release
  if [ "${ID:-}" != "ubuntu" ]; then
    die "This installer targets Ubuntu. Detected ID=${ID:-unknown}."
  fi
  case "${VERSION_ID:-}" in
    26.04|26.10)
      info "Detected Ubuntu ${VERSION_ID}"
      ;;
    *)
      warn "This installer targets Ubuntu 26.04. Detected ${VERSION_ID:-unknown}."
      warn "Continuing, but expect rough edges."
      ;;
  esac
}

require_non_root() {
  if [ "$(id -u)" = "0" ]; then
    die "Run as your normal user, not root. The script uses sudo when needed."
  fi
}

require_sudo() {
  if sudo -n true 2>/dev/null; then
    info "Passwordless sudo detected"
  else
    info "This installer needs sudo. You'll be prompted once."
  fi
  sudo_keepalive
}

require_internet() {
  if ! curl -fsSI --max-time 5 https://github.com >/dev/null 2>&1; then
    die "No internet access (couldn't reach https://github.com)."
  fi
}

apt_refresh() {
  info "Refreshing apt indexes"
  sudo apt-get update -y
}

install_base_tools() {
  apt_install \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    cmake \
    meson \
    ninja-build \
    pkg-config \
    unzip
}

require_non_root
require_sudo
require_ubuntu
require_internet
apt_refresh
install_base_tools

ok "Preflight checks passed."
