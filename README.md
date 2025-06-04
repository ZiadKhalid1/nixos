# NixOS Configuration

A personal NixOS configuration featuring Sway window manager with Catppuccin theming and modern development tools.

## Features

- **Window Manager**: Sway (Wayland compositor)
- **Status Bar**: Waybar with custom styling
- **Terminal**: Foot terminal emulator
- **Theme**: Catppuccin Mocha flavor
- **Display Manager**: greetd with tuigreet
- **Editor**: Multiple options (Zed, Helix, Neovim, Vim)
- **Browser**: Firefox
- **Shell**: Fish (default) with Bash fallback

## Key Components

### Window Management
- Sway with autotiling
- Custom keybindings (Mod4+q to kill, Mod4+w for Firefox)

### Development Environment
- Language servers: nil, nixd
- C/C++ development: clang, clang-tools

### System Services
- Bluetooth enabled
- Network Manager for networking
- GVFS for file operations
- Thumbnail support via tumbler
- Clipboard history with cliphist

## Installation

1. Clone this repository to `/etc/nixos/`
2. Update hardware configuration if needed
3. Run `sudo nixos-rebuild switch`

## Notes

- Home Manager is fetched directly from GitHub (release-24.11)
- Catppuccin theme is fetched from the main branch
- Wallpaper is automatically downloaded from catppuccin-wallpapers repository
- Configuration includes unfree packages support
