# Shared helpers sourced by install.sh and step scripts.
# Not meant to be executed directly.

# Colors (disabled if not a tty).
if [ -t 1 ]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_BLUE=$'\033[34m'
else
  C_RESET=""; C_BOLD=""; C_DIM=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_BLUE=""
fi

log()  { printf "%s\n" "$*"; }
info() { printf "%s==>%s %s\n" "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf "%s✓%s %s\n"   "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf "%s!%s %s\n"   "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf "%s✗%s %s\n"   "$C_RED" "$C_RESET" "$*" >&2; }

die() { err "$*"; exit 1; }

run_step() {
  local step="$1"
  local script="$REPO_ROOT/install/${step}.sh"
  [ -x "$script" ] || die "Missing install step: $script"

  printf "\n%s== %s ==%s\n" "$C_BOLD" "$step" "$C_RESET"
  "$script"
}

# Cache sudo credentials up-front so the install doesn't pause mid-way.
# If sudo is already passwordless (NOPASSWD) we skip the refresh entirely —
# `sudo -v` requires a TTY even with NOPASSWD, which breaks non-interactive runs.
sudo_keepalive() {
  if sudo -n true 2>/dev/null; then
    return 0
  fi
  sudo -v
  ( while true; do sudo -n true; sleep 60; kill -0 $$ 2>/dev/null || exit; done ) &
}

# Install apt packages, skipping ones already installed. Quiet on success.
apt_install() {
  local missing=()
  for pkg in "$@"; do
    if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"; then
      missing+=("$pkg")
    fi
  done
  if [ ${#missing[@]} -eq 0 ]; then
    return 0
  fi
  info "Installing: ${missing[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${missing[@]}"
}

# Test whether a binary is on PATH.
has() { command -v "$1" >/dev/null 2>&1; }

# Copy a directory tree into ~/.config without clobbering existing files.
# Usage: copy_config_dir <src> <dest>
copy_config_dir() {
  local src="$1" dest="$2"
  [ -d "$src" ] || { warn "skip copy: $src does not exist"; return 0; }
  mkdir -p "$dest"
  # --update=none preserves the user's existing files (no-clobber).
  # Older `cp -n` warns about non-portable behavior on coreutils 9.5+.
  cp -a --update=none "$src/." "$dest/"
}
