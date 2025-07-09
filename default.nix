let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {
    config.allowUnfree = true;
    overlays = [
      (import ./pkgs/overlay.nix)
    ];
  };
  catppuccin = sources.catppuccin;
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

  # services.snapper.configs = {
  #   home = {
  #     SUBVOLUME = "/home";
  #     ALLOW_USERS = [ "ziad" ];
  #     TIMELINE_CREATE = true;
  #     TIMELINE_CLEANUP = true;
  #   };
  #   snapshotinterval =
  # };
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
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
        user = "greeter";
      };
    };
  };

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
    shell = pkgs.zsh;
    description = "ziad";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "kvm"
    ];
  };

  #  _
  # | |__   ___  _ __ ___   ___   _ __ ___   __ _ _ __   __ _  __ _  ___ _ __
  # | '_ \ / _ \| '_ ` _ \ / _ \ | '_ ` _ \ / _` | '_ \ / _` |/ _` |/ _ \ '__|
  # | | | | (_) | | | | | |  __/ | | | | | | (_| | | | | (_| | (_| |  __/ |
  # |_| |_|\___/|_| |_| |_|\___| |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|
  #                                                           |___/
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ziad = ./home-manager.nix;
  home-manager.extraSpecialArgs = {
    inherit catppuccin;
    next-prayer = pkgs.next-prayer;
  };

  #  ____  _                ___     _____           _
  # |  _ \| | ____ _ ___   ( _ )   |  ___|__  _ __ | |_ ___
  # | |_) | |/ / _` / __|  / _ \/\ | |_ / _ \| '_ \| __/ __|
  # |  __/|   < (_| \__ \ | (_>  < |  _| (_) | | | | |_\__ \
  # |_|   |_|\_\__, |___/  \___/\/ |_|  \___/|_| |_|\__|___/
  #            |___/
  environment.systemPackages = with pkgs; [
    pavucontrol
    ntfs3g
    file-roller
    brightnessctl
    grc
    fzf
    telegram-desktop
    obsidian
    bottom
    xournalpp
    android-tools
    heimdall-gui
    tesseract
    bilal
    next-prayer
    (callPackage ./pkgs/quran-companion.nix { })
    evince
    git-helper
    libreoffice-fresh
    jetbrains.clion
    qemu
    virtiofsd
    file
  ];

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

  programs.zsh.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  programs = {
    fish.enable = true;
    light.enable = true;
    dconf.enable = true;
    regreet.enable = false;
    xfconf.enable = true;
  };
  programs.gtklock = {
    enable = true;
    modules = with pkgs; [
      gtklock-playerctl-module
      gtklock-powerbar-module
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
      #runshell {
      font-family: FiraMono;
      text-shadow: 1px 1px 2px black;
      border: 2px solid white;
      border-radius: 5px;
      padding-top: 30px;
      padding-right: 20px;
      padding-bottom: 10px;
      padding-left: 20px;
      }
    '';
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

  nix.nixPath = [
    "nixos=${sources.nixpkgs}"
    "nixpkgs=${sources.nixpkgs}"
    "home-manager=${sources.home-manager}"
    "nixos-hardware=${sources.nixos-hardware}"
    "nixos-config=/home/ziad/nixos/default.nix"
  ];
  system.stateVersion = "25.11";
}
