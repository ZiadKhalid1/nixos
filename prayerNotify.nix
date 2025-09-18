{
  config,
  pkgs,
  lib,
  ...
}:

let
  prayerNotifyDir = "${config.home.homeDirectory}/.local/share/prayer-notify";
in
{
  options.services.prayerNotify.enable = lib.mkEnableOption "Enable dynamic prayer time notifications using bilal";

  config = lib.mkIf config.services.prayerNotify.enable {
    home.packages = with pkgs; [ libnotify ];

    # Template systemd user service to send a notification
    systemd.user.services."prayer-notify@" = {
      Unit.Description = "Prayer Notification for %i";
      Service = {
        Type = "oneshot";
        ExecStart = "${prayerNotifyDir}/prayer_notify.sh %i";
      };
    };

    # Service to schedule all prayer times
    systemd.user.services.prayer-scheduler = {
      Unit = {
        Description = "Schedule Daily Prayer Notifications";
        After = [
          "default.target"
          "suspend.target"
        ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${prayerNotifyDir}/schedule_prayers.sh";
      };
    };

    # Timer that runs the scheduling script every boot/resume
    systemd.user.timers.prayer-scheduler = {
      Unit.Description = "Prayer Scheduler Timer";
      Timer = {
        OnBootSec = "2min";
        OnUnitActiveSec = "30min";
        Persistent = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

    home.file."${prayerNotifyDir}/prayer_notify.sh" = {
      text = ''
        #!/usr/bin/env bash
        notify-send "🕌 Prayer Time" "$1"
      '';
      executable = true;
    };

    home.file."${prayerNotifyDir}/schedule_prayers.sh" = {
      text = ''
        #!/usr/bin/env bash

        MARKER="$HOME/.cache/prayer_schedule_last_run"
        today=$(date +%F)

        if [[ -f "$MARKER" && "$(cat "$MARKER")" == "$today" ]]; then
          exit 0
        fi

        mkdir -p "$(dirname "$MARKER")"
        echo "$today" > "$MARKER"

        prayer_output=$(bilal all)

        echo "$prayer_output" | grep -E '^(Fajr|Sherook|Dohr|Asr|Mghreb|Ishaa|Midnight|Last third of night)' | while read -r line; do
          prayer_name=$(echo "$line" | cut -d':' -f1 | sed 's/ /_/g')
          time_str=$(echo "$line" | cut -d':' -f2- | xargs)
          time_24h=$(date -d "$time_str" +%H:%M 2>/dev/null)
          [ -z "$time_24h" ] && continue

          full_time="$today $time_24h"

          systemd-run --user \
            --on-calendar="$full_time" \
            --unit="prayer-notify@$prayer_name" \
            --description="Notify for $prayer_name" \
            prayer-notify@$prayer_name.service
        done
      '';
      executable = true;
    };
  };
}
