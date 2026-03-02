{ pkgs, lib, ... }:

{
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

  # GTKLock configuration
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
      window {
        padding-left: 20px;
      }
    '';
  };

  # UWSM for Sway session management
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

  # XDG Portal for Sway
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
  xdg.portal.config.common.default = lib.mkForce "*";

  # GNOME Keyring for Sway
  services.gnome.gnome-keyring.enable = true;

  # Sway-specific packages
  environment.systemPackages = [ pkgs.polkit_gnome ];
}
