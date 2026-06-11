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

# --- Login manager support ---
# We deliberately DO NOT install SDDM or swap your display manager.
# Whatever you log in with today (GDM on a standard Ubuntu install) will
# discover the Hyprland Wayland session entry from 40-login.sh and let you
# pick "Hyprland" at the login screen.
#
# Rationale: on real Ubuntu hardware (especially newer Intel iGPUs using the
# `xe` kernel driver), SDDM's X11 greeter often fails to initialize, leaving
# the system hanging at the Plymouth boot splash. GDM works out of the box,
# supports launching Wayland sessions, and is already installed — there's no
# user-visible benefit to switching for a Hyprland-focused setup.
#
# uwsm = Universal Wayland Session Manager. Omarchy's autostart wraps every
# entry with `uwsm-app`; without uwsm installed, none of them launch
# (no waybar, no wallpaper, no notifications).
LOGIN_PKGS=(
  uwsm
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
