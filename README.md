# NixOS Desktop Configuration

A comprehensive, modular NixOS configuration featuring dual desktop environments with modern development tools, aesthetic theming, and productivity-focused applications.

## Features

### Desktop Environments
- **GNOME (Default)** - Full GNOME desktop with GDM
- **Sway (Specialisation)** - SwayFX Wayland compositor with modern aesthetics

### Visual & Theming
- **Catppuccin Mocha** theme via Stylix
- **Waybar** - Customized status bar with system monitoring
- **SwayNC** - Notification center
- **Papirus icons** and Catppuccin cursors

### Development Environment
- **Editors**: Zed, Helix with LSP support
- **Language servers**: nil, nixd, clang-tools
- **Tools**: Git, lazygit, direnv, nix-direnv

## Project Structure

```
nixos/
├── configuration.nix          # Main NixOS configuration
├── hardware-configuration.nix # Auto-generated hardware config
├── wallpaper.jpg              # Desktop wallpaper
│
├── modules/                   # System modules
│   ├── stylix.nix            # Theming configuration
│   ├── services.nix          # Common services (audio, printing)
│   ├── virtualisation.nix    # Docker, libvirt, QEMU
│   ├── hardware.nix          # Hardware settings (bluetooth, tablet)
│   └── desktop/
│       ├── gnome.nix         # GNOME-specific config
│       └── sway.nix          # Sway-specific system config
│
├── home/                      # Home-manager configuration
│   ├── default.nix           # Base user environment
│   ├── sway.nix              # Sway user config (extends default)
│   ├── prayer-notify.nix     # Prayer notification module
│   ├── programs/
│   │   ├── helix.nix         # Helix editor config
│   │   ├── zed.nix           # Zed editor config
│   │   └── rofi.nix          # Rofi launcher config
│   └── desktops/
│       ├── sway.nix          # Sway window manager
│       └── waybar.nix        # Waybar status bar
│
├── pkgs/                      # Custom packages
│   ├── overlay.nix           # Package overlay
│   ├── bilal.nix             # Islamic prayer times CLI
│   ├── find_unicode.nix      # Unicode character search
│   ├── git-helper.nix        # AI git commit messages
│   ├── pomodoro-cli.nix      # Pomodoro timer
│   └── quran-companion.nix   # Quran reader
│
├── dotfiles/                  # Configuration files
│   ├── swaync-config.json    # Notification center
│   ├── swaync-style.css      # Notification styling
│   ├── sworkstyle-config.toml # Workspace icons
│   └── waybar.css            # Waybar styling
│
└── scripts/                   # Helper scripts
    ├── compress.sh           # Video compression
    └── git-helper.sh         # Git helper source
```

## Installation

### Prerequisites
- NixOS with `nixos-unstable` channel
- Home-manager NixOS module

### Setup Channels
```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --update
```

### Build
```bash
# Clone repository
git clone <repository-url> ~/nixos

# Generate hardware config (if needed)
sudo nixos-generate-config --show-hardware-config > ~/nixos/hardware-configuration.nix

# Build GNOME (default)
sudo nixos-rebuild switch -I nixos-config=~/nixos/configuration.nix

# Build Sway
sudo nixos-rebuild switch -I nixos-config=~/nixos/configuration.nix --specialisation sway
```

## Switching Environments

### At Boot
Select environment from systemd-boot menu:
- Default: GNOME
- sway: Sway window manager

### Runtime
```bash
# Switch to Sway
sudo nixos-rebuild switch --specialisation sway

# Switch to GNOME
sudo nixos-rebuild switch
```

## Key Bindings (Sway)

| Key | Action |
|-----|--------|
| `Super + q` | Kill window |
| `Super + w` | Firefox |
| `Super + e` | File manager |
| `Super + d` | Rofi launcher |
| `Super + Return` | Terminal |
| `Super + 1-9` | Switch workspace |
| `Super + Ctrl + 1-9` | Move to workspace |
| `Super + s` | Screenshot to clipboard |
| `Super + v` | Clipboard history |

## Custom Packages

| Package | Description |
|---------|-------------|
| `bilal` | Islamic prayer times CLI |
| `next-prayer` | Prayer time display for waybar |
| `find_unicode` | Unicode character search |
| `git-helper` | AI-powered git commit messages |
| `pomodoro-cli` | Pomodoro timer with waybar support |
| `quran-companion` | Quran reader application |

## Maintenance

```bash
# Update channels
sudo nix-channel --update

# Rebuild
sudo nixos-rebuild switch

# Clean old generations
sudo nix-collect-garbage -d
```

## Screenshots

![Desktop](dotfiles/screenshot_20250621_233833.png)
![Workspaces](dotfiles/screenshot_20250621_234152.png)

---

**Maintained by**: Ziad Khaled  
**NixOS Version**: nixos-unstable (25.11)
