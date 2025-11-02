{
  pkgs,
  ...
}:
{
  imports = [
    ./home-manager.nix
    ./sway.nix
  ];

  # Additional Sway-specific packages
  home.packages = with pkgs; [
    sway-audio-idle-inhibit
    nwg-displays
    nwg-clipman
    grim
    slurp
    wl-clipboard
    imv
    thunderbird-bin
  ];

  xdg.mimeApps.defaultApplications."x-scheme-handler/mailto" = "thunderbird.desktop";
  programs.rofi.enable = true;

  services.gnome-keyring.enable = true;
  # Sway-specific services
  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTargets = "sway-session.target";
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrains Mono:size=16";
      };
      colors = {
        alpha = 0.5;
      };
    };
  };

  # Sway-specific catppuccin settings
  catppuccin = {
    swaync.font = "FiraCodeNerd";
  };
}
