let
  sources = import ./npins;
  next-prayer = pkgs.writeShellScriptBin "next-prayer" ''
    ${pkgs.gnused}/bin/sed -E ':a;N;$!ba;s/\n/ /;s/^([[:alpha:]]+) \((.*)\) [[:alpha:]]+ \((.*)\)/\1: \2 (\3)/' <(${bilal}/bin/bilal next ; ${bilal}/bin/bilal current)
  '';
  bilal = pkgs.callPackage ./pkgs/bilal.nix { };
  pkgs = import sources.nixpkgs {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        gtklock-dpms-module = pkgs.callPackage ./pkgs/gtklock-dpms-module.nix { };
        gtklock-runshell-module = pkgs.callPackage ./pkgs/gtklock-runshell-module.nix { };
        gtklock-powerbar-module = pkgs.gtklock-powerbar-module.overrideAttrs {
          postPatch = ''
            substituteInPlace source.c \
              --replace-fail "systemctl" "${pkgs.systemd}/bin/systemctl"
          '';
        };
        inherit next-prayer bilal;
      };
    };
  };
  catppuccin = sources.catppuccin;

in
{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    <nixos-hardware/asus/battery.nix>
  ];

  networking.hostName = "nixos"; # Define your hostname.

  boot.supportedFilesystems = [ "ntfs" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  services.pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  services.xserver.xkb = {
    layout = "us,ara";
    model = "asus_laptop";
    variant = "";
    options = "caps:shift_modifier,grp:ctrl_space_toggle";
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
  services.gnome.gnome-keyring.enable = true;
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

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Cairo";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  #  xkb_layout "us,ara"
  #xkb_options "caps:shift_modifier,grp:ctrl_space_toggle"

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ziad = {
    isNormalUser = true;
    description = "ziad";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "kvm"
    ];
    #packages = with pkgs; [ ];
  };

  #home manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ziad = ./home-manager.nix;
  home-manager.extraSpecialArgs = { inherit catppuccin next-prayer; };

  environment.systemPackages = with pkgs; [
    pavucontrol
    ntfs3g
    file-roller
    brightnessctl
    grc
    fzf
    telegram-desktop
    kooha
    grim
    slurp
    wl-clipboard
    imv
    obsidian
    bottom
    xournalpp
    android-tools
    heimdall-gui
    gnome-boxes
    tesseract
    bilal
    next-prayer
    (callPackage ./pkgs/quran-companion.nix { })
    evince
  ];
  virtualisation.libvirtd.enable = true;

  fonts.packages = with pkgs; [
    cascadia-code
    font-awesome
    fira-code
    fira-mono
    nerd-fonts.fira-code
    jetbrains-mono
  ];

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
      # gtklock-dpms-module
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };

    };
  };

  # security.pam.services.greetd.enableGnomeKeyring = true;
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

  nix.nixPath = [
    "nixos=${sources.nixpkgs}"
    "nixpkgs=${sources.nixpkgs}"
    "home-manager=${sources.home-manager}"
    "nixos-hardware=${sources.nixos-hardware}"
    "nixos-config=/home/ziad/nixos/default.nix"
  ];

  # programs.nix-ld = {
  #   enable = true;
  # };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
