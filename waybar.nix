{
  next-prayer,
  pkgs,
  lib,
  ...
}:
{
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
          tooltip-format = "<span size='9pt' font='Fira Mono'>{calendar}</span>";
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
          exec = "${next-prayer}/bin/next-prayer";
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
