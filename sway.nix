{ lib, pkgs, config, ... }:
let
  stylixColors = config.lib.stylix.colors.withHashtag;
  pactl = lib.getExe' pkgs.pulseaudio "pactl";
  grim = lib.getExe pkgs.grim;
  slurp = lib.getExe pkgs.slurp;
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  notify-send = lib.getExe pkgs.libnotify;
in
{
  imports = [ ./waybar.nix ];
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    checkConfig = false;
    package = with pkgs; sway.override { sway-unwrapped = swayfx; };
    extraConfig = ''
      workspace_auto_back_and_forth yes
      corner_radius 10
      smart_corner_radius enable
      blur disable
      blur_passes 5
      blur_xray disable
      shadows on
      shadow_blur_radius 10
      default_dim_inactive 0.1
      gaps inner 5
      gaps outer 5
      default_border pixel 1
      default_floating_border pixel 1
      for_window [tiling] border pixel 1
      for_window [floating] border pixel 1
      hide_edge_borders smart
      focus_follows_mouse yes
      focus_on_window_activation focus
      no_focus [app_id="telegram-desktop"]
      no_focus [window_role="pop-up"]
      no_focus [title="Picture-in-Picture"]
      no_focus [title="Update Available"]
      for_window [app_id="firefox" title="^Picture-in-Picture$"] sticky enable
      bindgesture swipe:3:right workspace prev_on_output
      bindgesture swipe:3:left workspace next_on_output
      for_window [app_id="pavucontrol"] {
        sticky enable
        resize set width 50ppt height 50ppt
        move position 50ppt 0
      }
    '';
    systemd.xdgAutostart = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      defaultWorkspace = "workspace number 1";
      bindkeysToCode = true;
      keybindings = lib.mkOptionDefault {
        XF86MonBrightnessDown = "exec light -U 10";
        XF86MonBrightnessUp = "exec light -A 10";
        XF86AudioRaiseVolume = "exec '${pactl} set-sink-volume @DEFAULT_SINK@ +5%'";
        XF86AudioLowerVolume = "exec '${pactl} set-sink-volume @DEFAULT_SINK@ -5%'";
        XF86AudioMute = "exec '${pactl} set-sink-mute @DEFAULT_SINK@ toggle'";
        "Alt+Tab" = "workspace back_and_forth";
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
        "${modifier}+s" =
          ''exec ${grim} -g "$(${slurp})" - | ${wl-copy} && ${notify-send} "Screenshot copied" && $?'';
        "${modifier}+print" =
          ''exec IMG=~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && ${grim} $IMG && ${wl-copy} < $IMG && ${notify-send} "Screenshot saved"'';
        "${modifier}+g" =
          ''exec IMG=~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && ${grim} -g "$(slurp)" $IMG && ${wl-copy} < $IMG && ${notify-send} "Screenshot saved"'';
        "${modifier}+o" =
          ''exec ${grim} -g "$(${slurp})" - | ${pkgs.tesseract}/bin/tesseract - - | ${wl-copy} && ${notify-send} -- "$(${pkgs.wl-clipboard}/bin/wl-paste)"'';
        "${modifier}+n" = "${pkgs.wayscriber}/bin/wayscriber --active";
        "${modifier}+v" = "exec cliphist list | rofi -dmenu -p '  Clipboard' | cliphist decode | ${wl-copy}";
      };
      input = {
        "*" = {
          xkb_layout = "us,ara";
          xkb_options = "grp:win_space_toggle";
        };
        "type:touchpad" = {
          tap = "enabled";
          scroll_method = "two_finger edge";
          drag = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
        };
      };
      bars = [ ];
      floating.criteria = [
        { window_type = "dialog"; }
        { window_type = "utility"; }
        { window_type = "toolbar"; }
        { window_type = "splash"; }
        { window_type = "menu"; }
        { window_type = "dropdown_menu"; }
        { window_type = "popup_menu"; }
        { window_type = "tooltip"; }
        { window_type = "notification"; }
        { title = "(?:Open|Save) (?:File|Folder|As)"; }
        {
          app_id = "^firefox$";
          title = "^Extension: .*Bitwarden.*Firefox$";
        }
        { app_id = "pavucontrol"; }
        {
          app_id = "firefox";
          title = "^Picture-in-Picture$";
        }
        {
          app_id = "^thunar$";
          title = "^Rename .*";
        }
      ];
      workspaceAutoBackAndForth = true;
      menu = "rofi -show drun";
      colors = {
        background = lib.mkForce stylixColors.base00;
        focused = {
          childBorder = lib.mkForce stylixColors.base07;
          background = lib.mkForce stylixColors.base00;
          text = lib.mkForce stylixColors.base05;
          indicator = lib.mkForce stylixColors.base06;
          border = lib.mkForce stylixColors.base07;
        };
        focusedInactive = {
          childBorder = lib.mkForce stylixColors.base04;
          background = lib.mkForce stylixColors.base00;
          text = lib.mkForce stylixColors.base05;
          indicator = lib.mkForce stylixColors.base06;
          border = lib.mkForce stylixColors.base04;
        };
        unfocused = {
          childBorder = lib.mkForce stylixColors.base04;
          background = lib.mkForce stylixColors.base00;
          text = lib.mkForce stylixColors.base05;
          indicator = lib.mkForce stylixColors.base06;
          border = lib.mkForce stylixColors.base04;
        };
        placeholder = {
          childBorder = lib.mkForce stylixColors.base04;
          background = lib.mkForce stylixColors.base00;
          text = lib.mkForce stylixColors.base05;
          indicator = lib.mkForce stylixColors.base04;
          border = lib.mkForce stylixColors.base04;
        };
        urgent = {
          childBorder = lib.mkForce stylixColors.base09;
          background = lib.mkForce stylixColors.base00;
          text = lib.mkForce stylixColors.base09;
          indicator = lib.mkForce stylixColors.base04;
          border = lib.mkForce stylixColors.base09;
        };
      };
      startup = [
        {
          command = "${pkgs.autotiling-rs}/bin/autotiling-rs";
          always = true;
        }
        { command = "${pkgs.wl-clipboard}/bin/wl-paste --watch cliphist store"; }
        { command = "systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP &"; }
        {
          command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
        }
        {
          command = "${pkgs.brightnessctl}/bin/brightnessctl set 45%";
          always = true;
        }
        { command = "${pkgs.swayest-workstyle}/bin/sworkstyle &> /tmp/sworkstyle.log"; }
        {
          command = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
          always = true;
        }
      ];
    };
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  services.swaync = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./dotfiles/swaync-config.json);
    style = builtins.readFile ./dotfiles/swaync-style.css;
  };

  services.swayidle = {
    enable = true;
    extraArgs = [ ];
    timeouts = [
      {
        timeout = 300;
        command = "${lib.getExe pkgs.gtklock}";

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

  xdg.configFile."uwsm/env-sway".text = ''
    export SDL_VIDEODRIVER=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=qt5ct
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export _JAVA_AWT_WM_NONREPARENTING=1
    export MOZ_ENABLE_WAYLAND=1
  '';

  home.file.Sworkstyle = {
    enable = true;
    source = ./dotfiles/sworkstyle-config.toml;
    target = ".config/sworkstyle/config.toml";
  };
}
