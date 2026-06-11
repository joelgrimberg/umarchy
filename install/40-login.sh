#!/usr/bin/env bash
# Set up SDDM as the display manager and register a Hyprland Wayland session.
#
# We don't auto-login: the user reboots and picks Hyprland from the SDDM
# session menu. This matches the user's intended workflow (try Hyprland from
# a fresh login, fall back to GNOME if anything breaks).

set -eEo pipefail
source "$REPO_ROOT/lib/helpers.sh"

SESSION_FILE="/usr/local/share/wayland-sessions/hyprland.desktop"

install_hyprland_session() {
  # Launch Hyprland directly (not via uwsm). Omarchy assumes uwsm but in our
  # Ubuntu setup uwsm sessions hang during init; our overlay/autostart.conf
  # supplies bare-command versions of waybar/mako/swaybg so the bar still
  # appears.
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

switch_to_sddm() {
  # If GDM (Ubuntu's default) is the active display manager, switch to SDDM.
  local current_dm=""
  if [ -L /etc/systemd/system/display-manager.service ]; then
    current_dm="$(basename "$(readlink /etc/systemd/system/display-manager.service)")"
  fi

  case "$current_dm" in
    sddm.service)
      info "SDDM is already the active display manager"
      ;;
    "")
      info "No active display manager detected; enabling SDDM"
      sudo systemctl enable sddm.service
      ;;
    *)
      info "Switching display manager from $current_dm to sddm"
      sudo systemctl disable "$current_dm" || true
      sudo systemctl enable sddm.service
      ;;
  esac
}

install_hyprland_session
switch_to_sddm

ok "Login configured. After reboot, choose 'Hyprland' at the SDDM screen."
