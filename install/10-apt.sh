#!/usr/bin/env bash
# Install everything available from Ubuntu repos.
#
# On Ubuntu 26.04, Hyprland and its ecosystem are packaged. Anything not
# available here is handled in 20-build.sh.

set -eEo pipefail
source "$REPO_ROOT/lib/helpers.sh"

# --- Hyprland + Wayland desktop core ---
HYPRLAND_PKGS=(
  hyprland
  hyprland-protocols
  hyprlock
  hypridle
  hyprpicker
  hyprpaper
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk
  qt6-wayland
  qtwayland5
)

# --- Bar, launcher, notifications ---
DESKTOP_PKGS=(
  waybar
  mako-notifier
  swaybg
  swayidle
  swaylock
  wofi             # fallback launcher; walker is built from source in 20-build.sh
  wl-clipboard
  cliphist
  brightnessctl
  playerctl
  pamixer
  # Hyprland-native polkit agent. Omarchy's default autostart hard-codes
  # /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1; on Ubuntu
  # we use hyprpolkitagent + an autostart override in overlay/.
  hyprpolkitagent
  # OSD popups for volume / brightness key events.
  swayosd
  # Input method (Omarchy autostarts fcitx5 — without it, session prints
  # "Command not found: fcitx5" notifications on every login).
  fcitx5
  fcitx5-frontend-gtk4
  fcitx5-frontend-qt6
)

# --- Login manager ---
# SDDM's default greeter is X11. On a minimal Ubuntu cloud image, Xorg isn't
# installed, so the greeter fails with "Failed to start display server".
# We install just the X server core (~4MB) so the greeter works; Hyprland
# itself still runs as a Wayland session.
#
# uwsm = Universal Wayland Session Manager. Omarchy's autostart wraps every
# entry with `uwsm-app`; without uwsm installed, none of them launch
# (no waybar, no wallpaper, no notifications).
LOGIN_PKGS=(
  sddm
  uwsm
  xserver-xorg-core
  xinit
  xauth
)

# --- Terminals ---
TERMINAL_PKGS=(
  kitty
  alacritty
  # Omarchy launches the default terminal via `xdg-terminal-exec` (XDG spec
  # helper); without it the session prints "Command not found" on startup.
  xdg-terminal-exec
)

# --- Screenshot / utilities ---
UTIL_PKGS=(
  grim
  slurp
  jq
  bc
  socat
  imagemagick
  network-manager
  blueman
  bluez
  pipewire
  pipewire-pulse
  pipewire-alsa
  wireplumber
  pavucontrol
  gnome-keyring
  libsecret-1-0
  libsecret-tools
  xdg-user-dirs
  xdg-utils
  # Power profiles (battery / performance / balanced); Omarchy reads from this.
  power-profiles-daemon
  # Bound to the Calculator key by Omarchy's utilities.conf.
  gnome-calculator
)

# --- Fonts ---
FONT_PKGS=(
  fonts-firacode
  fonts-jetbrains-mono
  fonts-noto
  fonts-noto-cjk
  fonts-noto-color-emoji
  fonts-font-awesome
)

# --- CLI tools Omarchy assumes are present ---
CLI_PKGS=(
  bat
  eza
  fd-find
  fzf
  ripgrep
  zoxide
  starship
  tmux
  btop
  fastfetch
  less
)

info "Installing Hyprland packages"
apt_install "${HYPRLAND_PKGS[@]}"

info "Installing desktop tools (bar, launcher, notifications)"
apt_install "${DESKTOP_PKGS[@]}"

info "Installing login manager"
apt_install "${LOGIN_PKGS[@]}"

info "Installing terminals"
apt_install "${TERMINAL_PKGS[@]}"

info "Installing utilities"
apt_install "${UTIL_PKGS[@]}"

info "Installing fonts"
apt_install "${FONT_PKGS[@]}"

info "Installing CLI tools"
apt_install "${CLI_PKGS[@]}"

ok "All apt packages installed."
