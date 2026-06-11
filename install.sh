#!/usr/bin/env bash
# Entry point. Run on a fresh Ubuntu 26.04 desktop:
#   ./install.sh
#
# Each step is idempotent. Re-running is safe.

set -eEo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT

# shellcheck source=lib/helpers.sh
source "$REPO_ROOT/lib/helpers.sh"

banner() {
  cat <<'EOF'

 ┓ ┓     ┓                ┓        ┓
 ┓┏┓┓┏┳┓╋┓┏  ┣┓┓┏┏┓┏┓┏┓┏┓┏┃ ┏┓┏┓┏┳┓┓┓┏┏┳┓
 ┗┻┗┛┗┛┗┗┗┻  ┛┗┗┫┣┛┛ ┗┻┛┗┗┗ ┛┗┛┛┗┛┛┗┻┛ ┗

EOF
  echo "  Hyprland for Ubuntu 26.04, configured like Omarchy."
  echo
}

main() {
  banner
  run_step "00-preflight"
  run_step "10-apt"
  run_step "20-build"
  run_step "30-configs"
  run_step "40-login"
  run_step "50-post"

  ok ""
  ok "Install complete."
  ok ""
  ok "Next steps:"
  ok "  1. Reboot:  sudo systemctl reboot"
  ok "  2. At the SDDM login screen, pick the 'Hyprland' session."
  ok "  3. Log in and verify Hyprland starts."
}

main "$@"
