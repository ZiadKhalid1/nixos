{ lib, ... }:

#  ____            _    _                   ____             __ _
# |  _ \  ___  ___| | _| |_ ___  _ __      / ___|___  _ __  / _(_) __ _
# | | | |/ _ \/ __| |/ / __/ _ \| '_ \    | |   / _ \| '_ \| |_| |/ _` |
# | |_| |  __/\__ \   <| || (_) | |_) |   | |__| (_) | | | |  _| | (_| |
# |____/ \___||___/_|\_\\__\___/| .__/     \____\___/|_| |_|_| |_|\__, |
#                               |_|                                |___/
#
# Desktop Environment Setup:
# - Default: GNOME (GDM + GNOME Desktop)
# - Specialization: Sway (greetd + Sway WM)
#
# Usage:
# - Boot into GNOME: Default boot option
# - Boot into Sway: Select "sway" from systemd-boot menu
# - Switch to Sway: sudo nixos-rebuild switch --specialisation sway
# - Switch back to GNOME: sudo nixos-rebuild switch
#

let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {
    config.allowUnfree = true;
    overlays = [
      (import ./pkgs/overlay.nix)
    ];
  };
  catppuccin = sources.catppuccin;
  rolling = import sources.rolling-pkgs { };
  commonPackages = with pkgs; [
    xarchiver
    ntfs3g
    bottom
    android-tools
    heimdall
    git-helper
    libreoffice-fresh
    file
    qemu
    catppuccin-papirus-folders
    magnetic-catppuccin-gtk
    fzf
    file-roller
  ];
  gnomePackages = with pkgs; [
    gnomeExtensions.athantimes
    gnomeExtensions.user-themes
    gnome-tweaks
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    <nixos-hardware/asus/battery.nix>
  ];

  boot.supportedFilesystems = [ "ntfs" ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #  ____                       _ _
  # / ___|  ___  ___ _   _ _ __(_) |_ _   _
  # \___ \ / _ \/ __| | | | '__| | __| | | |
  #  ___) |  __/ (__| |_| | |  | | |_| |_| |
  # |____/ \___|\___|\__,_|_|  |_|\__|\__, |
  #                                   |___/
  security.polkit.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.passwd.enableGnomeKeyring = true;
  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes
  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }
  ];

  #  ____                  _
  # / ___|  ___ _ ____   _(_) ___ ___  ___
  # \___ \ / _ \ '__\ \ / / |/ __/ _ \/ __|
  #  ___) |  __/ |   \ V /| | (_|  __/\__ \
  # |____/ \___|_|    \_/ |_|\___\___||___/

  services.netbird.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  # GNOME as default desktop environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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

  #  _   _               _
  # | | | | __ _ _ __ __| |_      ____ _ _ __ ___
  # | |_| |/ _` | '__/ _` \ \ /\ / / _` | '__/ _ \
  # |  _  | (_| | | | (_| |\ V  V / (_| | | |  __/
  # |_| |_|\__,_|_|  \__,_| \_/\_/ \__,_|_|  \___|

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
  hardware.asus.battery = {
    chargeUpto = 85; # Maximum level of charge for your battery, as a percentage.
    enableChargeUptoScript = true; # Whether to add charge-upto to environment.systemPackages. `charge-upto 85` temporarily sets the charge limit to 85%.
  };

  #  ____       _   _   _
  # / ___|  ___| |_| |_(_)_ __   __ _ ___
  # \___ \ / _ \ __| __| | '_ \ / _` / __|
  #  ___) |  __/ |_| |_| | | | | (_| \__ \
  # |____/ \___|\__|\__|_|_| |_|\__, |___/
  #                             |___/

  networking.hostName = "ziad-nixos";
  networking.networkmanager.enable = true;
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

  users.users.ziad = {
    isNormalUser = true;
    shell = pkgs.bash;
    description = "ziad";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "kvm"
    ];
  };

  specialisation = {
    sway = {
      configuration = {
        # Disable GNOME services for Sway
        services.displayManager.gdm.enable = lib.mkForce false;
        services.desktopManager.gnome.enable = lib.mkForce false;
        programs.seahorse.enable = true;

        # Enable greetd for Sway
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
              user = "greeter";
            };
          };
        };

        programs.gtklock = {
          enable = true;
          modules = with pkgs; [
            gtklock-playerctl-module
            rolling.gtklock-powerbar-module
            gtklock-runshell-module
          ];
          config = {
            main = {
              idle-hide = true;
              idle-timeout = 10;
              start-hidden = true;
              time-format = "%I:%M";
            };
            runshell = {
              command = "${pkgs.next-prayer}/bin/next-prayer";
              refresh = 30;
              runshell-position = "top-center";
              margin-top = 100;
            };
          };
          style = ''
            padding-left: 20px;
            }
          '';
        };

        programs.uwsm = {
          enable = true;
          waylandCompositors = {
            sway = {
              prettyName = "Sway";
              comment = "Sway compositor managed by UWSM";
              binPath = "${pkgs.swayfx}/bin/sway";
            };
          };
        };
        xdg.portal = {
          enable = true;
          wlr.enable = true;
        };
        xdg.portal.config.common.default = "*";

        # environment.systemPackages = with pkgs; [
        #   libgnome-keyring
        # ];
        services.gnome.gnome-keyring = {
          enable = true;
        };
        # Sway-specific home-manager config
        home-manager.users.ziad = lib.mkForce ./home-sway.nix;

        environment.systemPackages = commonPackages;
      };
    };
  };

  #  _
  # | |__   ___  _ __ ___   ___   _ __ ___   __ _ _ __   __ _  __ _  ___ _ __
  # | '_ \ / _ \| '_ ` _ \ / _ \ | '_ ` _ \ / _` | '_ \ / _` |/ _` |/ _ \ '__|
  # | | | | (_) | | | | | |  __/ | | | | | | (_| | | | | (_| | (_| |  __/ |
  # |_| |_|\___/|_| |_| |_|\___| |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|
  #                                                           |___/
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
  home-manager.users.ziad = ./home-manager.nix;
  home-manager.extraSpecialArgs = {
    inherit catppuccin;
    inherit rolling;
    inherit pkgs;
    next-prayer = pkgs.next-prayer;
  };

  #  ____  _                ___     _____           _
  # |  _ \| | ____ _ ___   ( _ )   |  ___|__  _ __ | |_ ___
  # | |_) | |/ / _` / __|  / _ \/\ | |_ / _ \| '_ \| __/ __|
  # |  __/|   < (_| \__ \ | (_>  < |  _| (_) | | | | |_\__ \
  # |_|   |_|\_\__, |___/  \___/\/ |_|  \___/|_| |_|\__|___/
  #            |___/

  environment.systemPackages = commonPackages ++ gnomePackages;

  fonts.packages = with pkgs; [
    cascadia-code
    font-awesome
    fira-code
    fira-mono
    nerd-fonts.fira-code
    jetbrains-mono
  ];

  #  ____
  # |  _ \ _ __ ___   __ _ _ __ __ _ _ __ ___  ___
  # | |_) | '__/ _ \ / _` | '__/ _` | '_ ` _ \/ __|
  # |  __/| | | (_) | (_| | | | (_| | | | | | \__ \
  # |_|   |_|  \___/ \__, |_|  \__,_|_| |_| |_|___/
  #                  |___/

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
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
  };

  # __     ___      _               _ _           _   _
  # \ \   / (_)_ __| |_ _   _  __ _| (_)___  __ _| |_(_) ___  _ __
  #  \ \ / /| | '__| __| | | |/ _` | | / __|/ _` | __| |/ _ \| '_ \
  #   \ V / | | |  | |_| |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
  #    \_/  |_|_|   \__|\__,_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "ziad" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  systemd.tmpfiles.rules = [ "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware" ];

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

  nix.settings.trusted-users = [
    "root"
    "ziad"
  ];

  nix.nixPath = [
    "nixos=${sources.nixpkgs}"
    "nixpkgs=${sources.nixpkgs}"
    "home-manager=${sources.home-manager}"
    "nixos-hardware=${sources.nixos-hardware}"
    "nixos-config=/home/ziad/nixos/default.nix"
  ];
  system.stateVersion = "25.11";
}
