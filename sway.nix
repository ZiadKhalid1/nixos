{
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./waybar.nix
  ];

  wayland.windowManager.sway =
    let
      pactl = lib.getExe' pkgs.pulseaudio "pactl";
    in
    {

      enable = true;
      systemd.enable = true;
      checkConfig = false;
      package = with pkgs; sway.override { sway-unwrapped = swayfx; };
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
        input * {
            xkb_layout "us,ara"
            xkb_options "caps:shift_modifier,grp:ctrl_space_toggle"
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
      focus_follows_mouse yes
    # switch to workspace with urgent window automatically
        for_window [urgent=latest] focus
        #hide_edge_borders vertical
        #mouse_warping none
        # set $ii inhibit_idle focus
        # set $game inhibit_idle focus; floating enable; border none; fullscreen enable; shadows disable
        # set $popup floating enable; border pixel 1; sticky enable; shadows enable
        # set $float floating enable; border pixel 1; shadows enable
        # set $video inhibit_idle fullscreen; border none; max_render_time off
        # set $important inhibit_idle open; floating enable; border pixel 1
        # set $max inhibit_idle visible; floating enable; sticky enable; border pixel 1

         for_window [app_id="firefox" title="^Picture-in-Picture$"] sticky enable
        #  	[app_id="galculator"] $popup
             for_window [app_id="pavucontrol"] {
                sticky enable
                resize set width 50ppt height 50ppt
                 move position 50ppt 0
                 }
        #    [app_id="org.telegram.desktop"] $float; blur off; shadows disable;
        #    [app_id="teams-for-linux"] $float
        #    [class="teams-for-linux"] $float
        #    [instance="teams-for-linux"] $float

      '';
      systemd.xdgAutostart = true;
      wrapperFeatures.gtk = true;
      # package = pkgs.swayfx;
      config = rec {
        modifier = "Mod4";
        defaultWorkspace = "workspace number 1";
        keybindings = lib.mkOptionDefault {
          "${modifier}+q" = "kill";
          "${modifier}+w" = "exec ${pkgs.firefox}/bin/firefox";
          "${modifier}+e" = "exec ${pkgs.xfce.thunar}/bin/thunar";
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+Ctrl+1" = "move container to workspace number 1; workspace number 1";
          "${modifier}+Ctrl+2" = "move container to workspace number 2; workspace number 2";
          "${modifier}+Ctrl+3" = "move container to workspace number 3; workspace number 3";
          "${modifier}+Ctrl+4" = "move container to workspace number 4; workspace number 4";
          "${modifier}+Ctrl+5" = "move container to workspace number 5; workspace number 5";
          "${modifier}+Ctrl+6" = "move container to workspace number 6; workspace number 6";
          "${modifier}+Ctrl+7" = "move container to workspace number 7; workspace number 7";
          "${modifier}+Ctrl+8" = "move container to workspace number 8; workspace number 8";
          "${modifier}+Ctrl+9" = "move container to workspace number 9; workspace number 9";
        };
        bars = [ ];
        floating = {
          criteria = [
              {window_type="dialog"        ;}
              {window_type="utility"       ;}
              {window_type="toolbar"       ;}
              {window_type="splash"        ;}
              {window_type="menu"          ;}
              {window_type="dropdown_menu" ;}
              {window_type="popup_menu"    ;}
              {window_type="tooltip"       ;}
              {window_type="notification"  ;}
              {title="(?:Open|Save) (?:File|Folder|As)";}
              {app_id="^firefox$"; title="^Extension: .*Bitwarden.*Firefox$";}
              {app_id="pavucontrol";}
              {app_id="firefox"; title="^Picture-in-Picture$";}
          ];

        };
        workspaceAutoBackAndForth = true;
        menu = "rofi -show-icons -show drun";
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
          {
            command = "${pkgs.autotiling}/bin/autotiling";
            always = true;
          }
          { command = "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store"; }
          { command = " systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP &"; }
          {
            command = " dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
          }
          {
            command = "${lib.getExe pkgs.swaybg} -i ${builtins.fetchurl "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/refs/heads/main/os/nix-black-4k.png"} -m fill";
            always = true;
          }
          {
            command = "${pkgs.brightnessctl}/bin/brightnessctl set 45%";
            always = true;
          }
          { command = "${pkgs.swayest-workstyle}/bin/sworkstyle &> /tmp/sworkstyle.log"; }
          { command = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";}
        ];
      };
    };
  services.swaync = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./swaync-config.json);
  };

  services.swayidle = {
    enable = true;
    extraArgs = [ ];
    timeouts = [
      {
        timeout = 300;
        command = "${lib.getExe pkgs.gtklock} -S -T 10";
      }
      {
        timeout = 900;
        command = "${lib.getExe' pkgs.systemd "systemctl"} suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${lib.getExe pkgs.gtklock}";
      }
    ];
  };
  # services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;
  home.packages = [
    # pkgs.sway
    (pkgs.writeShellScriptBin "lock" ''
      ${lib.getExe pkgs.gtklock} -m ${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so -m ${pkgs.gtklock-playerctl-module}/lib/gtklock/playerctl-module.so "$@"
    '')
  ];

  xdg.configFile."uwsm/env-sway".text = "
  export SDL_VIDEODRIVER=wayland
  export QT_QPA_PLATFORM=wayland
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  export _JAVA_AWT_WM_NONREPARENTING=1
  export MOZ_ENABLE_WAYLAND=1
  ";
  home.file.Sworkstyle = {
    enable = true;
    source = ./sworkstyle-config.toml;
    target = ".config/sworkstyle/config.toml";
  };
  home.file.gtklock-config = {
    enable = true;
    source = ./gtklock-config;
    target = ".config/gtklock/config.ini";
  };
}
