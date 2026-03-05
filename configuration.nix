{ lib, pkgs, ... }:

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                           NixOS Configuration                             ║
# ║                                                                           ║
# ║  Desktop Environments:                                                    ║
# ║  - Default: GNOME (GDM + GNOME Desktop)                                   ║
# ║  - Specialisation: Sway (greetd + SwayFX)                                 ║
# ║                                                                           ║
# ║  Usage:                                                                   ║
# ║  - Boot into GNOME: Default boot option                                   ║
# ║  - Boot into Sway: Select "sway" from systemd-boot menu                   ║
# ║  - Switch to Sway: sudo nixos-rebuild switch --specialisation sway        ║
# ║  - Switch to GNOME: sudo nixos-rebuild switch                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

let
  # Pin to master branches to match nixpkgs-unstable
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  stylix = builtins.fetchTarball "https://github.com/nix-community/stylix/archive/master.tar.gz";

  # Packages shared between GNOME and Sway
  commonPackages = with pkgs; [
    # System utilities
    freerdp
    xarchiver
    ntfs3g
    bottom
    file
    qemu
    fzf
    file-roller
    papirus-icon-theme

    # Development
    android-tools
    heimdall
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    "${home-manager}/nixos"
    <nixos-hardware/asus/battery.nix>
    (import stylix).nixosModules.stylix
  ];

  # ═══════════════════════════════════════════════════════════════════════════
  # Nixpkgs Configuration
  # ═══════════════════════════════════════════════════════════════════════════
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import ./pkgs) ];

  # ═══════════════════════════════════════════════════════════════════════════
  # Stylix Theming
  # ═══════════════════════════════════════════════════════════════════════════
  stylix = {
    enable = true;
    polarity = "dark";
    image = ./wallpaper.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    override = {
      base00 = "1e1e2e";
      base01 = "181825";
      base02 = "313244";
      base03 = "45475a";
      base04 = "585b70";
      base05 = "cdd6f4";
      base06 = "f5e0dc";
      base07 = "b4befe";
      base08 = "f38ba8";
      base09 = "fab387";
      base0A = "f9e2af";
      base0B = "a6e3a1";
      base0C = "94e2d5";
      base0D = "89b4fa";
      base0E = "cba6f7";
      base0F = "f2cdcd";
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      sansSerif = {
        package = pkgs.cantarell-fonts;
        name = "Cantarell";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 16;
        applications = 12;
      };
    };
    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Boot Configuration
  # ═══════════════════════════════════════════════════════════════════════════
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ═══════════════════════════════════════════════════════════════════════════
  # Network Configuration
  # ═══════════════════════════════════════════════════════════════════════════
  networking.hostName = "ziad-nixos";
  networking.networkmanager.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════
  # Locale Settings
  # ═══════════════════════════════════════════════════════════════════════════
  time.timeZone = "Africa/Cairo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Hardware
  # ═══════════════════════════════════════════════════════════════════════════
  hardware.i2c.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
  hardware.asus.battery = {
    chargeUpto = 85;
    enableChargeUptoScript = true;
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Security
  # ═══════════════════════════════════════════════════════════════════════════
  security.polkit.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.passwd.enableGnomeKeyring = true;
  security.rtkit.enable = true;
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  # ═══════════════════════════════════════════════════════════════════════════
  # Services
  # ═══════════════════════════════════════════════════════════════════════════
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Printing
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Snapper for BTRFS snapshots
  services.snapper.configs = {
    root = {
      SUBVOLUME = "/";
      ALLOW_USERS = [ "ziad" ];
      TIMELINE_CREATE = true;
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Virtualisation
  # ═══════════════════════════════════════════════════════════════════════════
  virtualisation.docker.enable = true;
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "ziad" ];
  virtualisation.libvirtd = {
    enable = true;
    extraConfig = ''
      display = "gtk,gl=on"
    '';
  };
  virtualisation.spiceUSBRedirection.enable = true;
  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
  ];

  # ═══════════════════════════════════════════════════════════════════════════
  # GNOME Desktop (Default)
  # ═══════════════════════════════════════════════════════════════════════════
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Disable unnecessary GNOME components
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    nautilus
    gnome-text-editor
    gnome-maps
    gnome-contacts
    gnome-calendar
    gnome-software
  ];

  # XDG Portal configuration for GNOME
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [
        "gnome"
        "gtk"
      ];
      gnome = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # User Configuration
  # ═══════════════════════════════════════════════════════════════════════════
  users.users.ziad = {
    isNormalUser = true;
    shell = pkgs.bash;
    description = "ziad";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "kvm"
      "i2c"
      "docker"
    ];
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Sway Specialisation
  # ═══════════════════════════════════════════════════════════════════════════
  specialisation.sway.configuration = {
    imports = [ ./sway-system.nix ];
    home-manager.users.ziad = lib.mkForce ./sway.nix;
    environment.systemPackages = commonPackages ++ [ pkgs.polkit_gnome ];
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Home Manager
  # ═══════════════════════════════════════════════════════════════════════════
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.ziad = ./home.nix;
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # System Packages
  # ═══════════════════════════════════════════════════════════════════════════
  environment.systemPackages =
    commonPackages
    ++ (with pkgs; [
      gnomeExtensions.athantimes
      gnomeExtensions.user-themes
      gnome-tweaks
    ]);

  # ═══════════════════════════════════════════════════════════════════════════
  # Fonts
  # ═══════════════════════════════════════════════════════════════════════════
  fonts.packages = with pkgs; [
    inter
    cascadia-code
    font-awesome
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    dejavu_fonts
  ];

  # ═══════════════════════════════════════════════════════════════════════════
  # Programs
  # ═══════════════════════════════════════════════════════════════════════════
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
      thunar-vcs-plugin
    ];
  };

  programs = {
    light.enable = true;
    dconf.enable = true;
    xfconf.enable = true;
    droidcam.enable = true;
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Nix Settings
  # ═══════════════════════════════════════════════════════════════════════════
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    # settings = {
    #   trusted-users = [ "root" "ziad" ];
    #   # Binary caches - add your cachix cache name here
    #   substituters = [
    #     "https://cache.nixos.org"
    #     "https://ziad-nixos.cachix.org"  # Replace with your cache name
    #   ];
    #   trusted-public-keys = [
    #     "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    #     # Add your cachix public key here after running: cachix use ziad-nixos
    #   ];
    # };
    nixPath = [ "nixos-config=/home/ziad/nixos/configuration.nix" ];
  };

  system.stateVersion = "25.11";
}
