# ubuntu-hyprland

An automated installer that turns a fresh Ubuntu 26.04 desktop into a Hyprland
environment styled and configured like [Omarchy](https://github.com/basecamp/omarchy).

Omarchy targets Arch Linux. This project ports the desktop layer (Hyprland,
Waybar, Walker, Mako, themes, keybindings, look-and-feel) to Ubuntu by replacing
`pacman`/`yay`/AUR with `apt` + build-from-source, while reusing Omarchy's
upstream configuration files verbatim.

## How it works

1. You run `install.sh` on a fresh Ubuntu 26.04 install (default GNOME session).
2. The script:
   - Verifies preconditions (Ubuntu version, sudo, non-root user).
   - Installs everything available from `apt` (Hyprland, Waybar, Mako, SDDM,
     terminals, fonts, portals, etc.).
   - Builds the few tools not in Ubuntu repos (Walker launcher, elephant).
   - Clones `basecamp/omarchy` to `~/.local/share/omarchy/` for its
     configs, themes, defaults, and `bin/` scripts.
   - Copies Omarchy's `config/` to `~/.config/` so Hyprland sources the same
     files it does on Arch.
   - Registers a Hyprland Wayland session entry (your existing display
     manager — GDM on a standard Ubuntu install — picks it up automatically).
3. You log out of GNOME, click the **session selector** at the GDM login
   screen, pick **Hyprland**, and log back in.

## Usage

On a fresh Ubuntu 26.04 install, with internet access:

```sh
git clone https://github.com/<you>/ubuntu-hyprland.git
cd ubuntu-hyprland
./install.sh
```

When it finishes:

```sh
sudo systemctl reboot
```

At the SDDM login screen, click the session selector (usually top-right) and
choose **Hyprland**, then log in.

## What's included

- **Window manager**: Hyprland (from apt) with Omarchy's `hyprland.conf`,
  bindings, looknfeel, autostart, monitors.
- **Bar**: Waybar with Omarchy's `config.jsonc` and `style.css`.
- **Launcher**: Walker (built from source).
- **Notifications**: Mako.
- **Lock / idle**: hyprlock, hypridle.
- **Terminals**: kitty (default), alacritty.
- **Screenshot / picker**: grim, slurp, hyprpicker.
- **Portal**: xdg-desktop-portal-hyprland.
- **Login**: SDDM with Hyprland session entry.
- **Themes**: all Omarchy themes (catppuccin, tokyo-night, gruvbox, etc.).

## What's NOT included (deliberately)

These are easy to add later but kept out of the base install to keep it fast
and predictable:

- App bundle: 1Password, Signal, Spotify, Obsidian, Chromium, LibreOffice.
- Dev tooling: Docker, mise, asdcontrol, lazygit, nvim setup.
- Hardware-specific tweaks (Intel/AMD/NVIDIA quirks, Framework/Apple/Asus
  fix-ups). Omarchy ships many of these — port the ones you need from
  `~/.local/share/omarchy/install/config/hardware/` after install.

## Directory layout

```
ubuntu-hyprland/
├── install.sh                # entry point
├── install/
│   ├── 00-preflight.sh       # OS + sudo checks, apt update
│   ├── 10-apt.sh             # everything from apt
│   ├── 20-build.sh           # walker + other build-from-source pieces
│   ├── 30-configs.sh         # clone omarchy, copy ~/.config
│   ├── 40-login.sh           # SDDM + Hyprland session file
│   └── 50-post.sh            # services, file watchers, bashrc
├── lib/
│   └── helpers.sh            # logging, error handling, sudo helpers
└── overlay/
    └── config/               # Ubuntu-specific config overrides applied
                              # AFTER copying omarchy's configs
```

## Re-running

The script is idempotent: it skips already-installed packages and won't
overwrite existing user config files. To force-refresh configs, delete the
relevant `~/.config/<app>` directory first.

## After install

Most everyday tweaks live in:

- `~/.config/hypr/` — monitors, bindings, look-and-feel overrides.
- `~/.config/waybar/` — bar config and styles.
- `~/.config/omarchy/` — theme selection.
- `~/.local/share/omarchy/bin/` — Omarchy CLI helpers (`omarchy-theme-set`,
  etc.) — these are on `$PATH` via the installed `bashrc`.

To switch themes, use the `omarchy-theme-menu` command (if you installed
Omarchy's `bin/`).
