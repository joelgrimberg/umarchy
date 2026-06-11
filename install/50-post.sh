#!/usr/bin/env bash
# Post-install: enable runtime services, raise common limits, put Omarchy's
# helper scripts on PATH.

set -eEo pipefail
source "$REPO_ROOT/lib/helpers.sh"

OMARCHY_PATH="$HOME/.local/share/omarchy"

enable_user_services() {
  # Notifications, etc. should start with the Hyprland session via exec-once
  # in the Omarchy hypr config, so we don't enable them as systemd user units.
  # System-level networking + audio:
  sudo systemctl enable --now NetworkManager 2>/dev/null || true
  sudo systemctl enable --now bluetooth 2>/dev/null || true
}

raise_file_watchers() {
  local f=/etc/sysctl.d/99-ubuntu-hyprland-watchers.conf
  if [ ! -f "$f" ]; then
    info "Raising fs.inotify.max_user_watches"
    sudo tee "$f" >/dev/null <<'EOF'
fs.inotify.max_user_watches=524288
EOF
    sudo sysctl --system >/dev/null
  fi
}

add_omarchy_bin_to_path() {
  # Omarchy ships helper scripts in ~/.local/share/omarchy/bin (omarchy-theme-set,
  # omarchy-menu, etc.). Add them to PATH via ~/.bashrc if not already present.
  local rc="$HOME/.bashrc"
  local marker="# ubuntu-hyprland: omarchy bin"
  if [ -d "$OMARCHY_PATH/bin" ] && ! grep -qF "$marker" "$rc" 2>/dev/null; then
    info "Adding Omarchy bin/ to PATH in ~/.bashrc"
    {
      echo
      echo "$marker"
      echo 'export PATH="$HOME/.local/share/omarchy/bin:$PATH"'
    } >> "$rc"
  fi
}

generate_user_dirs() {
  if has xdg-user-dirs-update; then
    xdg-user-dirs-update
  fi
}

enable_user_services
raise_file_watchers
add_omarchy_bin_to_path
generate_user_dirs

ok "Post-install steps complete."
