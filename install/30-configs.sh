#!/usr/bin/env bash
# Clone upstream Omarchy and lay its configs down where Hyprland expects them.
#
# Omarchy's hyprland.conf sources files from ~/.local/share/omarchy/default/,
# so we keep the upstream clone there. User-editable starter overrides go to
# ~/.config/hypr/ — and we don't clobber existing user files.

set -eEo pipefail
source "$REPO_ROOT/lib/helpers.sh"

OMARCHY_REPO="${OMARCHY_REPO:-basecamp/omarchy}"
OMARCHY_REF="${OMARCHY_REF:-master}"
OMARCHY_PATH="$HOME/.local/share/omarchy"

clone_omarchy() {
  if [ -d "$OMARCHY_PATH/.git" ]; then
    info "omarchy already cloned at $OMARCHY_PATH; pulling latest"
    git -C "$OMARCHY_PATH" fetch --depth 1 origin "$OMARCHY_REF"
    git -C "$OMARCHY_PATH" checkout "$OMARCHY_REF"
    git -C "$OMARCHY_PATH" reset --hard "origin/$OMARCHY_REF"
    return 0
  fi

  info "Cloning $OMARCHY_REPO ($OMARCHY_REF) → $OMARCHY_PATH"
  mkdir -p "$(dirname "$OMARCHY_PATH")"
  git clone --depth 1 --branch "$OMARCHY_REF" \
    "https://github.com/${OMARCHY_REPO}.git" "$OMARCHY_PATH"
}

copy_configs() {
  info "Copying Omarchy configs to ~/.config"
  mkdir -p "$HOME/.config"

  # Whitelist: only the configs that are relevant on Ubuntu. Skipping things
  # tied to Arch-only tools (limine, pacman, snapper, etc.) avoids dead files.
  local subdirs=(
    hypr
    waybar
    walker
    mako
    alacritty
    kitty
    ghostty
    fastfetch
    btop
    tmux
    starship.toml
    fontconfig
    omarchy
    swayosd
    environment.d
    systemd
    autostart
    xdg-terminals.list
  )

  for item in "${subdirs[@]}"; do
    local src="$OMARCHY_PATH/config/$item"
    local dest="$HOME/.config/$item"
    if [ -e "$src" ]; then
      if [ -d "$src" ]; then
        copy_config_dir "$src" "$dest"
      else
        [ -e "$dest" ] || cp -a "$src" "$dest"
      fi
    fi
  done
}

apply_overlay() {
  local overlay="$REPO_ROOT/overlay/config"
  [ -d "$overlay" ] || return 0
  info "Applying Ubuntu-specific config overlay"
  # Overlay DOES overwrite — it's how we adapt Arch-specific bits.
  cp -aT "$overlay" "$HOME/.config" 2>/dev/null || cp -a "$overlay/." "$HOME/.config/"
}

patch_omarchy_for_hyprland_053() {
  # Ubuntu 26.04 ships Hyprland 0.53.3, which doesn't yet support the scroller
  # layout config block that newer Omarchy ships in looknfeel.conf. Remove it
  # so config parses cleanly. Idempotent: re-running is a no-op once removed.
  local f="$OMARCHY_PATH/default/hypr/looknfeel.conf"
  if [ -f "$f" ] && grep -q '^scrolling {' "$f"; then
    info "Patching out unsupported scroller config (Hyprland 0.53 compat)"
    sed -i '/^scrolling {/,/^}/d' "$f"
  fi
}

initialize_toggles_dir() {
  # Hyprland fails on `source = ...*.conf` if the glob matches nothing.
  # Create the dir Omarchy expects and drop a placeholder so the glob is happy.
  local toggles="$HOME/.local/state/omarchy/toggles/hypr"
  mkdir -p "$toggles"
  # Glob `*.conf` skips dotfiles, so the placeholder must NOT start with `.`.
  local placeholder="$toggles/00-placeholder.conf"
  if [ ! -f "$placeholder" ]; then
    printf '# Placeholder so the glob in hyprland.conf matches.\n' > "$placeholder"
  fi
}

initialize_theme() {
  # Use Omarchy's own theme-set helper. It copies the theme into
  # ~/.config/omarchy/current/theme/ AND runs the template engine that
  # generates per-app theme files (hyprland.conf, alacritty.toml, etc.).
  # Without this step, `source = ~/.config/omarchy/current/theme/hyprland.conf`
  # in Omarchy's hyprland.conf has nothing to source.
  local current="$HOME/.config/omarchy/current"
  mkdir -p "$current"
  if [ -e "$current/theme" ] && [ -f "$current/theme/hyprland.conf" ]; then
    info "Theme already initialized; skipping"
    return 0
  fi

  local default_theme="tokyo-night"
  if [ ! -d "$OMARCHY_PATH/themes/$default_theme" ]; then
    warn "Default theme $default_theme not found in $OMARCHY_PATH/themes/"
    return 0
  fi

  info "Initializing default theme: $default_theme"
  # Omarchy's helpers expect OMARCHY_PATH in the env and themselves on PATH.
  PATH="$OMARCHY_PATH/bin:$PATH" OMARCHY_PATH="$OMARCHY_PATH" \
    "$OMARCHY_PATH/bin/omarchy-theme-set" "$default_theme" \
    >/dev/null 2>&1 || warn "omarchy-theme-set returned non-zero (some restart hooks may have failed; this is expected outside a Hyprland session)"
}

link_elephant_menus() {
  # Omarchy's elephant menu helpers (themes, background selector) live in
  # ~/.local/share/omarchy/default/elephant/. Walker looks for them under
  # ~/.config/elephant/menus/. Match Omarchy's install/config/walker-elephant.sh.
  local menus="$HOME/.config/elephant/menus"
  mkdir -p "$menus"
  for f in omarchy_themes.lua omarchy_background_selector.lua; do
    local src="$OMARCHY_PATH/default/elephant/$f"
    [ -f "$src" ] && ln -snf "$src" "$menus/$f"
  done
}

clone_omarchy
patch_omarchy_for_hyprland_053
copy_configs
apply_overlay
initialize_toggles_dir
initialize_theme
link_elephant_menus

ok "Configs installed."
