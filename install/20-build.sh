#!/usr/bin/env bash
# Build from source the pieces that aren't packaged for Ubuntu.
#
# Currently:
#   - walker: Omarchy's app launcher (Rust + GTK4).
#
# Built artifacts are installed to /usr/local/bin and stay out of apt's way.

set -eEo pipefail
source "$REPO_ROOT/lib/helpers.sh"

BUILD_DIR="${TMPDIR:-/tmp}/ubuntu-hyprland-build"
mkdir -p "$BUILD_DIR"

install_go() {
  if has go; then
    return 0
  fi
  apt_install golang-go
}

install_rust() {
  # Walker uses Rust edition 2024 which requires a recent toolchain. Use
  # Ubuntu's rustup package to get the current stable channel; this respects
  # walker's rust-toolchain.toml.
  apt_install rustup
  if ! has cargo; then
    info "Installing Rust stable toolchain via rustup"
    rustup default stable
  fi
}

install_walker_build_deps() {
  apt_install \
    pkg-config \
    libgtk-4-dev \
    libgtk4-layer-shell-dev \
    libwayland-dev \
    wayland-scanner++ \
    protobuf-compiler \
    libpoppler-glib-dev \
    libcairo2-dev \
    libgdk-pixbuf-2.0-dev \
    libssl-dev
}

build_walker() {
  if has walker; then
    info "walker already installed; skipping"
    return 0
  fi

  install_walker_build_deps
  install_rust

  info "Cloning walker"
  rm -rf "$BUILD_DIR/walker"
  git clone --depth 1 https://github.com/abenz1267/walker "$BUILD_DIR/walker"

  info "Building walker (Rust release build, ~5-10 min)"
  pushd "$BUILD_DIR/walker" >/dev/null
  make
  sudo make install
  popd >/dev/null

  ok "walker installed to /usr/local/bin/walker"
}

build_elephant() {
  # elephant is Walker's backend daemon. Without it, Walker shows
  # "Waiting for elephant..." forever. Walker auto-spawns it on demand,
  # so we just need the binary on PATH.
  if has elephant; then
    info "elephant already installed; skipping"
    return 0
  fi

  install_go

  info "Cloning elephant"
  rm -rf "$BUILD_DIR/elephant"
  git clone --depth 1 https://github.com/abenz1267/elephant "$BUILD_DIR/elephant"

  info "Building elephant"
  pushd "$BUILD_DIR/elephant" >/dev/null
  make
  sudo make install
  popd >/dev/null

  ok "elephant installed to /usr/local/bin/elephant"
}

build_walker
build_elephant

ok "Build step complete."
