{
  pkgs,
  lib,
  config,
  ...
}:

let
  stylixColors = config.lib.stylix.colors.withHashtag;
  pactl = lib.getExe' pkgs.pulseaudio "pactl";
  grimBin = lib.getExe pkgs.grim;
  slurpBin = lib.getExe pkgs.slurp;
  wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
  notify-send = lib.getExe pkgs.libnotify;
in
{
  imports = [ ./home.nix ];

  # ═══════════════════════════════════════════════════════════════════════════
  # Sway-Specific Packages
  # ═══════════════════════════════════════════════════════════════════════════
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

  xdg.mimeApps.defaultApplications."x-scheme-handler/mailto" = lib.mkForce "thunderbird.desktop";

  # ═══════════════════════════════════════════════════════════════════════════
  # Clipboard History
  # ═══════════════════════════════════════════════════════════════════════════
  services.cliphist = {
    enable = true;
    allowImages = true;
    systemdTargets = "sway-session.target";
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Foot Terminal
  # ═══════════════════════════════════════════════════════════════════════════
  programs.foot = {
    enable = true;
    settings.colors = {
      alpha = lib.mkForce 0.5;
      alpha-mode = "matching";
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Sway Window Manager
  # ═══════════════════════════════════════════════════════════════════════════
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    checkConfig = false;
    package = pkgs.sway.override { sway-unwrapped = pkgs.swayfx; };
    extraConfig = ''
      workspace_auto_back_and_forth yes
      corner_radius 10
      smart_corner_radius enable
      blur disable

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
        "${modifier}+e" = "exec ${pkgs.thunar}/bin/thunar";
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
          ''exec ${grimBin} -g "$(${slurpBin})" - | ${wl-copy} && ${notify-send} "Screenshot copied" && $?'';
        "${modifier}+print" =
          ''exec IMG=~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && ${grimBin} $IMG && ${wl-copy} < $IMG && ${notify-send} "Screenshot saved"'';
        "${modifier}+g" =
          ''exec IMG=~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && ${grimBin} -g "$(${slurpBin})" $IMG && ${wl-copy} < $IMG && ${notify-send} "Screenshot saved"'';
        "${modifier}+o" =
          ''exec ${grimBin} -g "$(${slurpBin})" - | ${pkgs.tesseract}/bin/tesseract - - | ${wl-copy} && ${notify-send} -- "$(${pkgs.wl-clipboard}/bin/wl-paste)"'';
        "${modifier}+n" = "exec ${pkgs.wayscriber}/bin/wayscriber --active";
        "${modifier}+v" =
          "exec cliphist list | rofi -dmenu -p '  Clipboard' | cliphist decode | ${wl-copy}";
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

  # ═══════════════════════════════════════════════════════════════════════════
  # Polkit Agent
  # ═══════════════════════════════════════════════════════════════════════════
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # SwayNC Notifications
  # ═══════════════════════════════════════════════════════════════════════════
  services.swaync = {
    enable = true;
    settings = builtins.fromJSON (builtins.readFile ./dotfiles/swaync-config.json);
    style = builtins.readFile ./dotfiles/swaync-style.css;
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Swayidle
  # ═══════════════════════════════════════════════════════════════════════════
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
    events = {
      before-sleep = "${lib.getExe pkgs.gtklock}";
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # UWSM Environment
  # ═══════════════════════════════════════════════════════════════════════════
  xdg.configFile."uwsm/env-sway".text = ''
    export SDL_VIDEODRIVER=wayland
    export QT_QPA_PLATFORM=wayland
    export QT_QPA_PLATFORMTHEME=qt5ct
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export _JAVA_AWT_WM_NONREPARENTING=1
    export MOZ_ENABLE_WAYLAND=1
  '';

  # ═══════════════════════════════════════════════════════════════════════════
  # Sworkstyle Config
  # ═══════════════════════════════════════════════════════════════════════════
  home.file.".config/sworkstyle/config.toml".source = ./dotfiles/sworkstyle-config.toml;

  # ═══════════════════════════════════════════════════════════════════════════
  # Waybar
  # ═══════════════════════════════════════════════════════════════════════════
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 10;
        height = 38;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "cpu"
          "memory"
          "disk#one"
          "network"
          "sway/language"
        ];

        modules-center = [ "custom/prayer" ];

        modules-right = [
          "tray"
          "custom/notification"
          "custom/audio_idle_inhibitor"
          "idle_inhibitor"
          "backlight"
          "custom/hdmi-backlight"
          "custom/pomo"
          "battery"
          "pulseaudio"
          "clock"
        ];

        "sway/workspaces" = {
          format = "{icon}";
        };

        "sway/language" = {
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
          timeout = 30.5;
        };

        "sway/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };
        "cpu" = {
          states = {
            good = 0;
            warning = 70;
            critical = 90;
          };
          interval = 1;
          format = "󰻠 {usage}%";
          on-click = "${pkgs.foot}/bin/foot ${pkgs.bottom}/bin/btm";
        };

        "memory" = {
          states = {
            good = 0;
            warning = 70;
            critical = 85;
          };
          interval = 5;
          format = "󰍛 {}%";
          on-click = "${pkgs.foot}/bin/foot ${pkgs.bottom}/bin/btm";
        };

        "disk#one" = {
          states = {
            good = 0;
            warning = 70;
            critical = 95;
          };
          interval = 5;
          format = "  {percentage_used:2}% ";
          path = "/";
        };

        "network" = {
          format-wifi = "󰖩 {signalStrength}%";
          format-ethernet = "󰈀 {ifname}";
          format-linked = "󰈀 {ifname} (No IP)";
          format-disconnected = "󰖪 Disconnected";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format = "{essid}: {ipaddr}";
        };

        "tray" = {
          spacing = 8;
          icon-size = 16;
        };

        "clock" = {
          format = "  {:%I:%M}";
          format-alt = " {:%A, %B %d, %Y (%R)}";
          tooltip-format = "<span size='9pt' font='FiraCode Nerd Font Mono'>{calendar}</span>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            on-click-right = "mode";
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };

          "actions" = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "battery" = {
          states = {
            good = 60;
            warning = 40;
            critical = 30;
          };
          format = "{icon}  {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-full = " full charged";
          format-warning = " {capacity}%";
          format-critical = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "custom/notification" = {
          tooltip = false;
          format = " {} {icon} ";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        "custom/pomo" = {
          format = "   {}";
          exec = "pomodoro-cli status --format json --time-format digital";
          return-type = "json";
          on-click = "pomodoro-cli start --add 5m --notify";
          on-click-middle = "pomodoro-cli pause";
          on-click-right = "pomodoro-cli stop";
          interval = 1;
        };

        "custom/audio_idle_inhibitor" = {
          format = "{icon}";
          exec = "sway-audio-idle-inhibit --dry-print-both-waybar";
          exec-if = "which sway-audio-idle-inhibit";
          return-type = "json";
          format-icons = {
            output = "";
            input = "";
            output-input = "  ";
            none = "";
          };
        };

        "custom/hdmi-backlight" =
          let
            ddcutil = lib.getExe pkgs.ddcutil;
          in
          {
            format = "󰍹 {}";
            exec = ''${ddcutil} getvcp 10 | sed 's/.*current value = \s\+\([0-9]\+\).*/\1/' '';
            interval = 1;
            on-scroll-down = "${ddcutil} setvcp 10 - 5";
            on-scroll-up = "${ddcutil} setvcp 10 + 5";
          };

        "backlight" = {
          format = "{icon} {percent}%";
          format-icons = [
            "🔅"
            "🔆"
          ];
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 1%-";
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl -c backlight set +1%";
        };

        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{icon} {volume}% {format_source}";
          format-bluetooth-muted = " {format_source}";
          format-muted = "  {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "🎧";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        "custom/prayer" = {
          exec = "${pkgs.next-prayer}/bin/next-prayer";
          interval = 30;
          tooltip = true;
          tooltip-format = "{}";
          format = "🕌 {}";
        };
      };
    };
    style = builtins.readFile ./dotfiles/waybar.css;
  };
}
