#!/usr/bin/env bash
# Register a Hyprland Wayland session entry. The existing display manager
# (GDM on standard Ubuntu) will discover it and offer Hyprland at the
# session picker on the login screen.
#
# We deliberately do NOT touch the active display manager. Earlier versions
# of this script switched GDM → SDDM, but SDDM's X11 greeter can fail to
# initialize on real Ubuntu hardware (especially newer Intel iGPUs on the
# `xe` driver), leaving the system stuck at the Plymouth boot splash with
# no way to log in. GDM works out of the box and supports Wayland sessions,
# so there's no benefit to swapping for a Hyprland-focused setup.

set -eEo pipefail
source "$REPO_ROOT/lib/helpers.sh"

SESSION_FILE="/usr/local/share/wayland-sessions/hyprland.desktop"

install_hyprland_session() {
  info "Registering Hyprland Wayland session"
  sudo mkdir -p /usr/local/share/wayland-sessions

  sudo tee "$SESSION_FILE" >/dev/null <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
TryExec=Hyprland
Type=Application
EOF
}

install_hyprland_session

ok "Hyprland session registered."
ok "At your login screen, pick 'Hyprland' from the session selector."
