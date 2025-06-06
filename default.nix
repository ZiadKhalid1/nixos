# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz"}/nixos"
  ];
  boot.supportedFilesystems = [ "ntfs" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableFishIntegration = true;
    };
  };

  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  networking.hostName = "nixos"; # Define your hostname.
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
  services.xserver.xkb = {
    layout = "us,ara";
    model = "asus_laptop";
    variant = "";
    options = "caps:shift_modifier,grp:ctrl_space_toggle";
  };

  programs.regreet.enable = false;
  services.displayManager.defaultSession = "Sway (UWSM)";
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
        user = "greeter";
      };
    };
  };
  services.dbus.implementation = "broker";
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  programs.dconf.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ziad = {
    isNormalUser = true;
    description = "ziad";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    packages = with pkgs; [ ];
  };
  programs.light.enable = true;
  home-manager.users.ziad = ./home-manager.nix;
  programs.uwsm.enable = true;
  programs.uwsm.waylandCompositors = {
    sway = {
      prettyName = "Sway";
      comment = "Sway compositor managed by UWSM";
      binPath = "${pkgs.swayfx}/bin/sway";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  programs.fish.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    pavucontrol
    ntfs3g
    file-roller
    sway-audio-idle-inhibit
    brightnessctl
    grc
    fzf
    telegram-desktop
    libnotify
    pomodoro-gtk
  ];

  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  security.pam.services.gtklock = { };
  services.blueman.enable = true;

  fonts.packages = with pkgs; [
    cascadia-code
    font-awesome
    fira-code
    fira-mono
  ];

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
  system.stateVersion = "24.11"; # Did you read the comment?

}
