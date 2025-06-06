{ config, lib, pkgs, ... }: {

  imports = [
    ./waybar.nix
  ];

  wayland.windowManager.sway =
  let
    pactl = lib.getExe' pkgs.pulseaudio "pactl";
  in
  {
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
       # needs qt5.qtwayland in systemPackages
       export QT_QPA_PLATFORM=wayland
       export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
       # Fix for some Java AWT applications (e.g. Android Studio),
       # use this if they aren't displayed properly:
       export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
    enable = true;
    systemd.enable = true;
    checkConfig = false;
    extraConfig = ''
    # Brightness
    bindsym XF86MonBrightnessDown exec light -U 10
    bindsym XF86MonBrightnessUp exec light -A 10

    # Volume
    bindsym XF86AudioRaiseVolume exec '${pactl} set-sink-volume @DEFAULT_SINK@ +5%'
    bindsym XF86AudioLowerVolume exec '${pactl} set-sink-volume @DEFAULT_SINK@ -5%'
    bindsym XF86AudioMute exec '${pactl} set-sink-mute @DEFAULT_SINK@ toggle'
    workspace_auto_back_and_forth yes
    bindsym Alt+Tab workspace back_and_forth
    input type:touchpad {
        tap enabled
        scroll_method two_finger edge
        drag enabled
        natural_scroll enabled
        dwt enabled
    }
    # CORNER
      corner_radius 10
      smart_corner_radius enable
    # SHADOWS
      shadows on
      shadows_on_csd on
      shadow_blur_radius 10
      layer_effects "waybar" {
          blur enable;
          blur_xray enable;
          blur_ignore_transparent enable;
          shadows enable;
          corner_radius 20;
      }
    # DARKENING INACTIVE WINDOWS
    default_dim_inactive 0.1
    dim_inactive_colors.unfocused #000000FF
    dim_inactive_colors.urgent #900000FF
    # gaps
    gaps inner 5
    gaps outer 5
    smart_gaps off

    # DISABLING WINDOW TITLES
    default_border pixel 1
    default_floating_border none

    #--- FRAME SIZE
    for_window [tiling] border pixel 1
    for_window [floating] border none

    # DISABLING THE FRAME WHEN ONE WINDOW IS OPEN
    smart_borders on
    '';
    wrapperFeatures.gtk = true;
    # package = pkgs.swayfx;
    config = rec {
    	modifier = "Mod4";
     defaultWorkspace = "workspace number 1";
      keybindings =  lib.mkOptionDefault {
        "${modifier}+q" = "kill";
        "${modifier}+w" = "exec ${pkgs.firefox}/bin/firefox";
      };
      bars = [];
      colors = {
        background = "$base";
        focused = {
          childBorder = "#b4befe";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f5e0dc";
          border = "#b4befe";
        };
        focusedInactive = {
          childBorder = "#6c7086";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f5e0dc";
          border = "#6c7086";
        };
        unfocused = {
          childBorder = "#6c7086";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#f5e0dc";
          border = "#6c7086";
        };
        placeholder = {
          childBorder = "#6c7086";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#6c7086";
          border = "#6c7086";
        };
        urgent = {
          #$peach    $base $peach $overlay0  $peach
          childBorder = "#fab387";
          background = "#1e1e2e";
          text = "#fab387";
          indicator = "#6c7086";
          border = "#fab387";
        };
      };
      startup = [
       	{ command = "${pkgs.autotiling}/bin/autotiling"; always = true; }
       	{ command = "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store"; }
        { command = " systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP &";}
        { command = " dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";}
        { command = "${lib.getExe pkgs.swaybg} -i ${builtins.fetchurl "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/refs/heads/main/os/nix-black-4k.png"} -m fill"; always = true; }
      ];
    };
  };
  home.packages = [
     # pkgs.sway
    (pkgs.writeShellScriptBin "lock" ''
      ${lib.getExe pkgs.gtklock} -m ${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so -m ${pkgs.gtklock-playerctl-module}/lib/gtklock/playerctl-module.so "$@"
    '')
  ];
  home.file.gtklock-config = {
    enable = true;
    source = ./gtklock-config;
    target = ".config/gtklock/config.ini";
  };
}
