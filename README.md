# NixOS Desktop Configuration

A comprehensive NixOS configuration featuring dual desktop environments with modern development tools, aesthetic theming, and productivity-focused applications. Choose between GNOME (default) or Sway (specialisation) at boot or switch dynamically.

## 📸 Screenshots

See the visual result of this configuration:

### Desktop Environment
![Desktop Environment](dotfiles/screenshot_20250621_233833.png)

### Workspace Overview  
![Workspace Overview](dotfiles/screenshot_20250621_234152.png)

## 🌟 Features

### 🖥️ Desktop Environments
- **GNOME (Default)** - Full GNOME desktop environment with GDM
  - Traditional desktop experience
  - Complete GNOME ecosystem
  - Wayland compositor
- **Sway (Specialisation)** - SwayFX Wayland compositor with eye-candy effects
  - Tiling window manager
  - Autotiling and workspace management (9 workspaces)
  - Corner radius and shadows for modern aesthetics
  - Floating window rules for dialogs and utilities
  - TUI greeter (greetd) for minimal login

### 🎨 Visual & Theming
- **Catppuccin Theme** - Mocha flavor across all applications
- **Waybar** - Highly customized status bar with system monitoring
- **SwayNC** - Notification center with action buttons
- **Custom fonts** - Cascadia Code, Fira Code, Font Awesome, Nerd Fonts
- **Dynamic wallpaper** - Auto-downloaded Catppuccin wallpapers
- **Visual Examples** - See screenshots in `dotfiles/` folder showcasing the complete desktop environment

### 🛠️ Development Environment
- **Multiple editors**:
  - Zed Editor (primary) with Nix support
  - Helix with language servers
  - Neovim and Vim
- **Language servers**: nil, nixd, clang-tools
- **Development tools**: Git with Delta, Fish shell with plugins
- **Package management**: Nix with direnv integration

### 📱 Applications & Utilities
- **Browser**: Firefox with Wayland support
- **Terminal**: Foot terminal with custom styling
- **File manager**: Thunar with archive support
- **Media**: MPV, VLC, Obsidian, XournalPP
- **Productivity**: Pomodoro timer, Papers, Bottom (system monitor)
- **Communication**: Telegram Desktop
- **System tools**: Android tools, Heimdall, GNOME Boxes

### 🔧 System Services
- **Audio**: PipeWire with ALSA/PulseAudio compatibility
- **Bluetooth**: Full Bluetooth stack with Blueman
- **Networking**: NetworkManager
- **Security**: Polkit, GNOME Keyring integration
- **Virtualization**: libvirtd support
- **Printing**: CUPS with HP driver support

## 📁 Project Structure

The configuration uses NixOS specialisations to provide two distinct desktop environments:

```
nixos/
├── default.nix              # Main NixOS configuration with specialisations
│                            # ├── Default: GNOME + GDM
│                            # └── Specialisation "sway": Sway + greetd
├── home-manager.nix         # Base user environment (shared by both)
├── home-sway.nix            # Sway-specific user configuration
├── sway.nix                 # Sway window manager config
├── waybar.nix               # Status bar configuration (Sway only)
├── hardware-configuration.nix # Hardware-specific settings
├── shell.nix                # Development shell
├── npins/                   # Pinned dependencies
├── dotfiles/                # Configuration files
│   ├── screenshot_20250621_233833.png # Desktop environment showcase
│   ├── screenshot_20250621_234152.png # Workspace overview
│   ├── swaync-config.json   # Notification center config (Sway)
│   ├── sworkstyle-config.toml # Workspace styling (Sway)
│   ├── waybar.css           # Status bar styling (Sway)
│   └── uair.toml            # Pomodoro timer config
└── pkgs/                    # Custom package definitions
    ├── bilal.nix            # Prayer times utility
    ├── find_unicode.nix     # Unicode search tool
    └── zed-editor-bin.nix   # Zed editor binary
```

### Configuration Architecture
- **`default.nix`**: Main system configuration defining both GNOME (default) and Sway (specialisation)
- **`home-manager.nix`**: Base home-manager configuration shared by both environments
- **`home-sway.nix`**: Extends base config with Sway-specific packages and services
- **Specialisation system**: Allows switching between desktop environments without rebuilding

### Home-Manager Configuration Inheritance
```
GNOME Environment (Default):
└── home-manager.nix (base configuration)
    ├── Common applications (Zed, Firefox, development tools)
    ├── Shared services (direnv, git configuration)
    └── Base system packages

Sway Environment (Specialisation):
└── home-sway.nix
    ├── imports = [ ./home-manager.nix ./sway.nix ]
    ├── Inherits ALL base configuration
    ├── Adds Sway-specific packages (grim, slurp, wl-clipboard)
    ├── Sway window manager configuration
    ├── Waybar status bar
    └── Additional Wayland utilities
```

This inheritance model ensures:
- **No duplication**: Common configs are shared between environments
- **Clean separation**: Environment-specific configs are isolated
- **Easy maintenance**: Update base config once, affects both environments

## 🚀 Installation

### Prerequisites
- NixOS system with Git installed
- Internet connection for downloading packages

### Quick Start
1. **Clone the repository**:
   ```bash
   git clone <repository-url> ~/nixos
   cd ~/nixos
   ```

2. **Backup existing configuration** (if any):
   ```bash
   sudo cp -r /etc/nixos /etc/nixos.backup
   ```

3. **Copy your hardware configuration**:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

4. **Build and switch**:
   ```bash
   # Using the provided build script
   nix-shell --run "bs"
   # OR manually
   sudo nixos-rebuild switch -I nixos-config=./default.nix
   ```

5. **Reboot** to ensure all services start correctly

### Desktop Environment Options

After installation, you have two options:

#### Option 1: Boot Menu Selection
At boot, systemd-boot will show:
- **Default**: GNOME desktop environment
- **sway**: Sway window manager environment

#### Option 2: Dynamic Switching (without reboot)
```bash
# Switch to Sway environment
sudo nixos-rebuild switch --specialisation sway

# Switch back to GNOME (default)
sudo nixos-rebuild switch
```

After switching to Sway, your desktop should look similar to the screenshots in the `dotfiles/` folder, featuring the modern Catppuccin-themed Sway environment with Waybar status bar.

### Development Environment
For development and testing:
```bash
nix-shell  # Enters development shell with npins and build tools
```

## ⌨️ Key Bindings

### GNOME Desktop
Standard GNOME keyboard shortcuts apply when using the default environment.

### Sway Window Manager (Specialisation)
| Key Combination | Action |
|----------------|---------|
| `Super + q` | Kill focused window |
| `Super + w` | Launch Firefox |
| `Super + e` | Launch file manager (Thunar) |
| `Super + d` | Application launcher (Rofi) |
| `Super + Return` | Open terminal |
| `Super + 1-9` | Switch to workspace |
| `Super + Ctrl + 1-9` | Move window to workspace and follow |
| `Alt + Tab` | Switch to previous workspace |
| `Super + s` | Screenshot selection to clipboard |
| `Super + g` | Screenshot selection to file |
| `Super + Print` | Screenshot entire screen |
| `Super + o` | OCR screenshot (text extraction) |

### Media Controls
| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp/Down` | Adjust brightness |

## 🎛️ Configuration

### Customizing Themes
The Catppuccin theme is configured in `home-manager.nix`:
```nix
catppuccin = {
  flavor = "mocha";  # Options: latte, frappe, macchiato, mocha
  enable = true;
  # ... additional theme settings
};
```

### Adding Packages
- **For both environments**: Add packages to `home-manager.nix`
- **For Sway only**: Add packages to `home-sway.nix`
- **System-wide**: Add packages to `default.nix`

```nix
# In home-manager.nix (shared)
home.packages = with pkgs; [
  example-package-for-both
];

# In home-sway.nix (Sway only)
home.packages = with pkgs; [
  sway-specific-package
];
```

### Modifying Keybindings
Edit keybindings in `sway.nix`:
```nix
keybindings = lib.mkOptionDefault {
  "${modifier}+your_key" = "your_command";
};
```

### Waybar Customization
- Modify modules in `waybar.nix`
- Adjust styling in `dotfiles/waybar.css`

## 🔧 Maintenance

### Updating Dependencies
```bash
cd nixos
npins update  # Update all pinned sources
nix-shell --run "bs"  # Rebuild system
```

### Cleaning Up
```bash
# Clean old generations
sudo nix-collect-garbage -d
# Clean boot entries
sudo /run/current-system/bin/switch-to-configuration boot
```

### Troubleshooting
- Check system logs: `journalctl -xeu <service-name>`
- Test configuration: `sudo nixos-rebuild test`
- Rollback: `sudo nixos-rebuild switch --rollback`

## 🔒 Security Features

- **Polkit** for privilege escalation
- **GNOME Keyring** for credential storage
- **GtkLock** screen locker with idle timeout (5 minutes)
- **Automatic suspend** after 15 minutes of inactivity
- **Secure boot** compatible (systemd-boot)

## 🎯 Productivity Features

### Workspace Management
- **Sworkstyle** - Dynamic workspace icons based on applications
- **Auto back-and-forth** - Quick workspace switching
- **Floating rules** - Smart window management for dialogs

### Development Workflow
- **Direnv** integration for project-specific environments
- **Multiple language servers** pre-configured
- **Git with Delta** for enhanced diffs
- **Fish shell** with useful plugins (fzf, done, hydro)

### System Monitoring
- **Waybar modules** - CPU, memory, disk, network, battery
- **Bottom** - Advanced system monitor
- **Notification center** - System alerts and controls

## 📝 Notes

- **Dual environment support**: Switch between GNOME and Sway without rebuilding
- **Specialisation system**: Uses NixOS specialisations for clean environment separation
- **Shared base configuration**: Common packages and settings in `home-manager.nix`
- **Environment-specific configs**: Sway extensions in `home-sway.nix`
- **Unfree packages** are enabled (for proprietary software)
- **Wayland-first** configuration with X11 fallback where needed
- **Home Manager** manages user-level configurations
- **Systemd integration** for proper session management
- **ASUS laptop optimization** with battery charge limiting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes with `nixos-rebuild test`
4. Submit a pull request

## 📄 License

This configuration is provided as-is for educational and personal use. Individual components may have their own licenses.

---

**Maintained by**: Ziad Khaled
**NixOS Version**: 25.11
**Last Updated**: 2025-01-11
