{ config, pkgs, lib, ... }:

let
  prayerNotifyDir = "${config.home.homeDirectory}/.local/share/prayer-notify";
in
{
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
      After = [ "default.target" "suspend.target" ];
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

  # Prayer notification script
  home.file."${prayerNotifyDir}/prayer_notify.sh" = {
    text = ''
      #!/usr/bin/env bash
      PRAYER_NAME="$1"
      ${lib.getExe pkgs.libnotify} -u critical "Prayer Time" "$PRAYER_NAME"
    '';
    executable = true;
  };

  # Prayer scheduling script
  home.file."${prayerNotifyDir}/schedule_prayers.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      MARKER="$HOME/.cache/prayer_schedule_last_run"
      today=$(date +%F)

      # Only run once per day
      if [[ -f "$MARKER" && "$(cat "$MARKER")" == "$today" ]]; then
        exit 0
      fi

      mkdir -p "$(dirname "$MARKER")"
      echo "$today" > "$MARKER"

      # Cancel any existing scheduled timers
      systemctl --user list-timers --all | grep prayer-notify@ | awk '{print $1}' | while read -r timer; do
        systemctl --user stop "$timer" 2>/dev/null || true
      done

      # Get prayer times and schedule notifications
      ${lib.getExe pkgs.bilal} all | grep -E '^(Fajr|Sherook|Dohr|Asr|Mghreb|Ishaa)' | while read -r line; do
        prayer_name=$(echo "$line" | cut -d':' -f1 | xargs)
        time_str=$(echo "$line" | cut -d':' -f2- | xargs)
        time_24h=$(date -d "$time_str" +%H:%M 2>/dev/null) || continue

        full_time="$today $time_24h"
        current_time=$(date +%s)
        prayer_time=$(date -d "$full_time" +%s 2>/dev/null) || continue

        # Only schedule future prayers
        if [[ "$prayer_time" -gt "$current_time" ]]; then
          systemd-run --user \
            --on-calendar="$full_time" \
            --unit="prayer-notify-$prayer_name" \
            --description="Notify for $prayer_name prayer" \
            -- "${prayerNotifyDir}/prayer_notify.sh" "$prayer_name"
        fi
      done
    '';
    executable = true;
  };
}
