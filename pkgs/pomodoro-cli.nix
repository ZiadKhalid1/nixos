{ pkgs ? import <nixpkgs> {} }:

let
  # Fetch only required assets from GitHub
  assets = pkgs.stdenv.mkDerivation {
    name = "pomodoro-cli-assets";
    
    dingMp3 = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/jkallio/pomodoro-cli/b76315eb8b1fb27486d45a25905d0ad375c900ab/assets/ding.mp3";
      sha256 = "sha256-HA6mTN3PP7ncmNTAcMEUw6hMEeWJ9Yvb+hmi3rYMgZY=";
    };
    
    iconPng = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/jkallio/pomodoro-cli/b76315eb8b1fb27486d45a25905d0ad375c900ab/assets/icon.png";
      sha256 = "sha256-WOynBGvyLvhCbPPTEXU3yMPPtL9v5mJ7CtIb6HJUGnI=";
    };
    
    dontUnpack = true;
    
    installPhase = ''
      mkdir -p $out
      cp $dingMp3 $out/ding.mp3
      cp $iconPng $out/icon.png
    '';
  };
in
pkgs.writeShellScriptBin "pomodoro-cli" ''
  # pomodoro-cli - A command-line Pomodoro timer
  # Version: 1.2.5 (Bash port)

  set -euo pipefail

  export PATH="${pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.jq
    pkgs.libnotify
    pkgs.pulseaudio
    pkgs.ncurses
    pkgs.gawk
  ]}:$PATH"

  VERSION="1.2.5"
  PROGRAM_NAME="pomodoro-cli"
  ASSETS_DIR="${assets}"

  # Default values
  DEFAULT_DURATION=1500  # 25 minutes in seconds

  # State file location
  get_state_file() {
      local cache_dir
      if [[ -n "''${XDG_CACHE_HOME:-}" ]]; then
          cache_dir="$XDG_CACHE_HOME"
      elif [[ -d "$HOME/.cache" ]]; then
          cache_dir="$HOME/.cache"
      else
          cache_dir="."
      fi
      echo "''${cache_dir}/pomodoro-cli-info.json"
  }

  # Config directory
  get_config_dir() {
      local config_dir
      if [[ -n "''${XDG_CONFIG_HOME:-}" ]]; then
          config_dir="$XDG_CONFIG_HOME"
      elif [[ -d "$HOME/.config" ]]; then
          config_dir="$HOME/.config"
      else
          config_dir="."
      fi
      echo "''${config_dir}/pomodoro-cli"
  }

  STATE_FILE="$(get_state_file)"
  CONFIG_DIR="$(get_config_dir)"

  # ============================================================================
  # Duration Parsing Functions
  # ============================================================================

  # Parse duration string to seconds
  parse_duration() {
      local input="$1"
      local total_seconds=0
      
      # Remove leading/trailing whitespace
      input="$(echo "$input" | xargs)"
      
      # Check if it's a digital format (contains : but no letters)
      if [[ "$input" =~ ^[0-9:]+$ ]]; then
          # Digital format: MM:SS or HH:MM:SS
          IFS=':' read -ra parts <<< "$input"
          local num_parts="''${#parts[@]}"
          
          if [[ "$num_parts" -eq 1 ]]; then
              total_seconds=$((parts[0] * 60))
          elif [[ "$num_parts" -eq 2 ]]; then
              total_seconds=$(( (parts[0] * 60) + parts[1] ))
          elif [[ "$num_parts" -eq 3 ]]; then
              total_seconds=$(( (parts[0] * 3600) + (parts[1] * 60) + parts[2] ))
          else
              echo "Error: Invalid duration format" >&2
              return 1
          fi
      elif [[ "$input" =~ ^[0-9]+$ ]]; then
          total_seconds=$((input * 60))
      else
          # Segmented format: 1h 30m 10s
          local remaining="$input"
          
          if [[ "$remaining" =~ ([0-9]+)[[:space:]]*(hours?|hrs?|h)[[:space:]]* ]]; then
              total_seconds=$((total_seconds + BASH_REMATCH[1] * 3600))
              remaining="''${remaining//''${BASH_REMATCH[0]}/}"
          fi
          
          if [[ "$remaining" =~ ([0-9]+)[[:space:]]*(minutes?|mins?|m)[[:space:]]* ]]; then
              total_seconds=$((total_seconds + BASH_REMATCH[1] * 60))
              remaining="''${remaining//''${BASH_REMATCH[0]}/}"
          fi
          
          if [[ "$remaining" =~ ([0-9]+)[[:space:]]*(seconds?|secs?|s) ]]; then
              total_seconds=$((total_seconds + BASH_REMATCH[1]))
          fi
          
          if [[ "$total_seconds" -eq 0 ]] && [[ "$input" =~ ^[0-9]+$ ]]; then
              total_seconds=$((input * 60))
          fi
      fi
      
      if [[ "$total_seconds" -le 0 ]]; then
          echo "Error: Invalid or zero duration" >&2
          return 1
      fi
      
      echo "$total_seconds"
  }

  # ============================================================================
  # Time Formatting Functions
  # ============================================================================

  format_digital() {
      local seconds="$1"
      local abs_seconds="''${seconds#-}"
      local prefix=""
      [[ "$seconds" -lt 0 ]] && prefix="-"
      
      local hours=$((abs_seconds / 3600))
      local minutes=$(( (abs_seconds % 3600) / 60 ))
      local secs=$((abs_seconds % 60))
      
      if [[ "$hours" -gt 0 ]]; then
          printf "%s%02d:%02d:%02d" "$prefix" "$hours" "$minutes" "$secs"
      else
          printf "%s%02d:%02d" "$prefix" "$minutes" "$secs"
      fi
  }

  format_segmented() {
      local seconds="$1"
      local abs_seconds="''${seconds#-}"
      local prefix=""
      [[ "$seconds" -lt 0 ]] && prefix="-"
      
      local hours=$((abs_seconds / 3600))
      local minutes=$(( (abs_seconds % 3600) / 60 ))
      local secs=$((abs_seconds % 60))
      
      local result="$prefix"
      [[ "$hours" -gt 0 ]] && result+="''${hours}h "
      [[ "$minutes" -gt 0 ]] && result+="''${minutes}m "
      result+="''${secs}s"
      
      echo "$result"
  }

  format_time() {
      local seconds="$1"
      local format="''${2:-digital}"
      
      case "$format" in
          digital)
              format_digital "$seconds"
              ;;
          segmented)
              format_segmented "$seconds"
              ;;
          seconds)
              echo "$seconds"
              ;;
          *)
              format_digital "$seconds"
              ;;
      esac
  }

  # ============================================================================
  # State Management Functions
  # ============================================================================

  create_default_state() {
      cat <<EOFSTATE
  {
    "state": "Finished",
    "start_time": 0,
    "pause_time": 0,
    "duration": $DEFAULT_DURATION,
    "message": "",
    "silent": false,
    "notify": false,
    "wait": false,
    "lock_screen": false
  }
  EOFSTATE
  }

  read_state() {
      if [[ -f "$STATE_FILE" ]]; then
          cat "$STATE_FILE"
      else
          create_default_state
      fi
  }

  write_state() {
      local state="$1"
      mkdir -p "$(dirname "$STATE_FILE")"
      echo "$state" > "$STATE_FILE"
  }

  get_state_value() {
      local state="$1"
      local key="$2"
      echo "$state" | jq -r ".$key"
  }

  set_state_value() {
      local state="$1"
      local key="$2"
      local value="$3"
      local value_type="''${4:-string}"
      
      if [[ "$value_type" == "raw" ]]; then
          echo "$state" | jq ".$key = $value"
      else
          echo "$state" | jq ".$key = \"$value\""
      fi
  }

  # ============================================================================
  # Timer Calculation Functions
  # ============================================================================

  calc_time_elapsed() {
      local state="$1"
      local timer_state
      timer_state=$(get_state_value "$state" "state")
      local start_time
      start_time=$(get_state_value "$state" "start_time")
      local pause_time
      pause_time=$(get_state_value "$state" "pause_time")
      local duration
      duration=$(get_state_value "$state" "duration")
      local now
      now=$(date +%s)
      
      case "$timer_state" in
          Running)
              echo $((now - start_time))
              ;;
          Paused)
              echo $((pause_time - start_time))
              ;;
          Finished)
              echo "$duration"
              ;;
      esac
  }

  calc_time_left() {
      local state="$1"
      local duration
      duration=$(get_state_value "$state" "duration")
      local elapsed
      elapsed=$(calc_time_elapsed "$state")
      echo $((duration - elapsed))
  }

  calc_percentage() {
      local state="$1"
      local duration
      duration=$(get_state_value "$state" "duration")
      local time_left
      time_left=$(calc_time_left "$state")
      
      if [[ "$duration" -eq 0 ]]; then
          echo "0"
      else
          echo "$((time_left * 100 / duration))"
      fi
  }

  # ============================================================================
  # Action Functions
  # ============================================================================

  play_alarm() {
      local custom_alarm="''${CONFIG_DIR}/alarm.mp3"
      local default_alarm="''${ASSETS_DIR}/ding.mp3"
      
      local alarm_file
      if [[ -f "$custom_alarm" ]]; then
          alarm_file="$custom_alarm"
      elif [[ -f "$default_alarm" ]]; then
          alarm_file="$default_alarm"
      else
          echo "Warning: No alarm sound file found" >&2
          return 0
      fi
      
      if command -v paplay &>/dev/null; then
          paplay "$alarm_file" &>/dev/null &
      elif command -v mpv &>/dev/null; then
          mpv --no-video "$alarm_file" &>/dev/null &
      elif command -v ffplay &>/dev/null; then
          ffplay -nodisp -autoexit "$alarm_file" &>/dev/null &
      elif command -v aplay &>/dev/null; then
          aplay "$alarm_file" &>/dev/null &
      else
          echo "Warning: No audio player found" >&2
      fi
  }

  send_notification() {
      local message="''${1:-Time is up!}"
      local custom_icon="''${CONFIG_DIR}/icon.png"
      local default_icon="''${ASSETS_DIR}/icon.png"
      
      local icon_arg=""
      if [[ -f "$custom_icon" ]]; then
          icon_arg="-i $custom_icon"
      elif [[ -f "$default_icon" ]]; then
          icon_arg="-i $default_icon"
      else
          icon_arg="-i dialog-warning"
      fi
      
      if command -v notify-send &>/dev/null; then
          notify-send $icon_arg "Pomodoro Timer" "$message"
      else
          echo "Warning: notify-send not found" >&2
      fi
  }

  lock_screen() {
      if command -v xdg-screensaver &>/dev/null; then
          xdg-screensaver lock
      elif command -v gnome-screensaver-command &>/dev/null; then
          gnome-screensaver-command -l
      elif command -v dm-tool &>/dev/null; then
          dm-tool lock
      elif command -v loginctl &>/dev/null; then
          loginctl lock-session
      else
          echo "Warning: No screen locker found" >&2
      fi
  }

  trigger_alarm() {
      local state="$1"
      local silent
      silent=$(get_state_value "$state" "silent")
      local notify
      notify=$(get_state_value "$state" "notify")
      local do_lock_screen
      do_lock_screen=$(get_state_value "$state" "lock_screen")
      local message
      message=$(get_state_value "$state" "message")
      
      # Set state to Finished FIRST to prevent duplicate triggers from parallel calls
      state=$(set_state_value "$state" "state" "Finished")
      write_state "$state"
      
      # Output to stderr so it doesn't interfere with JSON output
      echo "Time is up!" >&2
      
      if [[ "$notify" == "true" ]]; then
          if [[ -n "$message" && "$message" != "null" ]]; then
              send_notification "Time is up! - $message"
          else
              send_notification "Time is up!"
          fi
      fi
      
      if [[ "$silent" != "true" ]]; then
          play_alarm
      fi
      
      if [[ "$do_lock_screen" == "true" ]]; then
          lock_screen
      fi
  }

  # ============================================================================
  # Progress Bar (for --wait mode)
  # ============================================================================

  show_progress_bar() {
      local state="$1"
      local duration
      duration=$(get_state_value "$state" "duration")
      
      tput civis 2>/dev/null || true
      
      trap 'tput cnorm 2>/dev/null || true; exit' INT TERM
      
      while true; do
          state=$(read_state)
          local timer_state
          timer_state=$(get_state_value "$state" "state")
          
          if [[ "$timer_state" == "Finished" ]]; then
              break
          fi
          
          local time_left
          time_left=$(calc_time_left "$state")
          
          if [[ "$time_left" -le 0 ]]; then
              trigger_alarm "$state"
              break
          fi
          
          local percentage
          percentage=$(calc_percentage "$state")
          local filled=$((25 - (percentage * 25 / 100)))
          local empty=$((25 - filled))
          
          local bar="|"
          for ((i=0; i<filled; i++)); do bar+="#"; done
          for ((i=0; i<empty; i++)); do bar+="-"; done
          bar+="| $(format_digital "$time_left")"
          
          if [[ "$timer_state" == "Paused" ]]; then
              bar+=" (Paused)"
          fi
          
          printf "\r\033[K%s" "$bar"
          
          sleep 1
      done
      
      tput cnorm 2>/dev/null || true
      echo ""
  }

  # ============================================================================
  # Commands
  # ============================================================================

  cmd_start() {
      local duration=""
      local add=""
      local message=""
      local notify=false
      local silent=false
      local wait=false
      local resume=false
      local lock_screen=false
      
      while [[ $# -gt 0 ]]; do
          case "$1" in
              -d|--duration)
                  if [[ -z "''${2:-}" || "$2" == -* ]]; then
                      echo "Error: --duration requires a value" >&2
                      return 1
                  fi
                  duration="$2"
                  shift 2
                  ;;
              -a|--add)
                  if [[ -z "''${2:-}" || "$2" == -* ]]; then
                      echo "Error: --add requires a value" >&2
                      return 1
                  fi
                  add="$2"
                  shift 2
                  ;;
              -m|--message)
                  if [[ -z "''${2:-}" || "$2" == -* ]]; then
                      echo "Error: --message requires a value" >&2
                      return 1
                  fi
                  message="$2"
                  shift 2
                  ;;
              --notify)
                  notify=true
                  shift
                  ;;
              --silent)
                  silent=true
                  shift
                  ;;
              --wait)
                  wait=true
                  shift
                  ;;
              --resume)
                  resume=true
                  shift
                  ;;
              --lock-screen)
                  lock_screen=true
                  wait=true
                  shift
                  ;;
              *)
                  echo "Unknown option: $1" >&2
                  return 1
                  ;;
          esac
      done
      
      local state
      state=$(read_state)
      local timer_state
      timer_state=$(get_state_value "$state" "state")
      local now
      now=$(date +%s)
      
      if [[ "$resume" == "true" ]]; then
          if [[ "$timer_state" != "Paused" ]]; then
              echo "Error: Timer is not paused" >&2
              return 1
          fi
          
          local pause_time
          pause_time=$(get_state_value "$state" "pause_time")
          local start_time
          start_time=$(get_state_value "$state" "start_time")
          local paused_elapsed=$((pause_time - start_time))
          local new_start_time=$((now - paused_elapsed))
          
          state=$(set_state_value "$state" "start_time" "$new_start_time" "raw")
          state=$(set_state_value "$state" "pause_time" "$new_start_time" "raw")
          state=$(set_state_value "$state" "state" "Running")
          
          write_state "$state"
          echo "Timer resumed"
          
      elif [[ -n "$add" ]]; then
          local add_seconds
          add_seconds=$(parse_duration "$add")
          
          # If timer is running or paused, add time to it
          # Otherwise, start a new timer with add as the duration (matches Rust behavior)
          if [[ "$timer_state" == "Running" || "$timer_state" == "Paused" ]]; then
              local current_duration
              current_duration=$(get_state_value "$state" "duration")
              local new_duration=$((current_duration + add_seconds))
              
              state=$(set_state_value "$state" "duration" "$new_duration" "raw")
              
              if [[ -n "$message" ]]; then
                  state=$(set_state_value "$state" "message" "$message")
              fi
              
              write_state "$state"
              echo "Added $(format_segmented "$add_seconds") to timer"
          else
              # No timer running - start a new timer with add as duration
              state=$(cat <<EOFSTATE
  {
    "state": "Running",
    "start_time": $now,
    "pause_time": $now,
    "duration": $add_seconds,
    "message": "$message",
    "silent": $silent,
    "notify": $notify,
    "wait": $wait,
    "lock_screen": $lock_screen
  }
  EOFSTATE
  )
              write_state "$state"
              echo "Timer started for $(format_segmented "$add_seconds")"
          fi
          
      else
          local duration_seconds=$DEFAULT_DURATION
          if [[ -n "$duration" ]]; then
              duration_seconds=$(parse_duration "$duration")
          fi
          
          state=$(cat <<EOFSTATE
  {
    "state": "Running",
    "start_time": $now,
    "pause_time": $now,
    "duration": $duration_seconds,
    "message": "$message",
    "silent": $silent,
    "notify": $notify,
    "wait": $wait,
    "lock_screen": $lock_screen
  }
  EOFSTATE
  )
          
          write_state "$state"
          echo "Timer started for $(format_segmented "$duration_seconds")"
      fi
      
      if [[ "$wait" == "true" || "$lock_screen" == "true" ]]; then
          state=$(read_state)
          show_progress_bar "$state"
      fi
  }

  cmd_stop() {
      local state
      state=$(read_state)
      
      state=$(set_state_value "$state" "state" "Finished")
      write_state "$state"
      
      echo "Timer stopped"
  }

  cmd_pause() {
      local state
      state=$(read_state)
      local timer_state
      timer_state=$(get_state_value "$state" "state")
      local now
      now=$(date +%s)
      
      case "$timer_state" in
          Running)
              state=$(set_state_value "$state" "state" "Paused")
              state=$(set_state_value "$state" "pause_time" "$now" "raw")
              write_state "$state"
              echo "Timer paused"
              ;;
          Paused)
              local pause_time
              pause_time=$(get_state_value "$state" "pause_time")
              local start_time
              start_time=$(get_state_value "$state" "start_time")
              local paused_elapsed=$((pause_time - start_time))
              local new_start_time=$((now - paused_elapsed))
              
              state=$(set_state_value "$state" "start_time" "$new_start_time" "raw")
              state=$(set_state_value "$state" "pause_time" "$new_start_time" "raw")
              state=$(set_state_value "$state" "state" "Running")
              write_state "$state"
              echo "Timer resumed"
              ;;
          Finished)
              echo "No timer running"
              ;;
      esac
  }

  cmd_status() {
      local format="human"
      local time_format="digital"
      
      while [[ $# -gt 0 ]]; do
          case "$1" in
              -f|--format)
                  if [[ -z "''${2:-}" || "$2" == -* ]]; then
                      echo "Error: --format requires a value (human, json)" >&2
                      return 1
                  fi
                  format="$2"
                  shift 2
                  ;;
              -t|--time-format)
                  if [[ -z "''${2:-}" || "$2" == -* ]]; then
                      echo "Error: --time-format requires a value (digital, segmented, seconds)" >&2
                      return 1
                  fi
                  time_format="$2"
                  shift 2
                  ;;
              *)
                  echo "Unknown option: $1" >&2
                  return 1
                  ;;
          esac
      done
      
      local state
      state=$(read_state)
      local timer_state
      timer_state=$(get_state_value "$state" "state")
      local wait_mode
      wait_mode=$(get_state_value "$state" "wait")
      
      if [[ "$timer_state" == "Running" && "$wait_mode" != "true" ]]; then
          local time_left
          time_left=$(calc_time_left "$state")
          if [[ "$time_left" -lt 0 ]]; then
              trigger_alarm "$state"
              state=$(read_state)
              timer_state="Finished"
          fi
      fi
      
      local time_left
      time_left=$(calc_time_left "$state")
      local time_elapsed
      time_elapsed=$(calc_time_elapsed "$state")
      local message
      message=$(get_state_value "$state" "message")
      local duration
      duration=$(get_state_value "$state" "duration")
      
      local display_time_left=$time_left
      [[ "$display_time_left" -lt 0 ]] && display_time_left=0
      
      # Build human readable text (matches Rust get_human_readable)
      # Only adds state suffix when message is present
      get_human_readable_text() {
          local time_str
          time_str=$(format_time "$display_time_left" "$time_format")
          
          if [[ -n "$message" && "$message" != "null" && "$message" != "" ]]; then
              case "$timer_state" in
                  Running) echo "$time_str - $message" ;;
                  Paused) echo "$time_str - Paused" ;;
                  Finished) echo "$time_str - Time is up!" ;;
              esac
          else
              echo "$time_str"
          fi
      }
      
      if [[ "$format" == "json" ]]; then
          local text
          text=$(get_human_readable_text)
          
          # Use printf to create actual newlines (not escaped)
          local tooltip
          tooltip=$(printf '%s\nLeft: %s\nElapsed: %s ' "$timer_state" "$(format_time "$display_time_left" "$time_format")" "$(format_time "$time_elapsed" "$time_format")")
          
          local class
          case "$timer_state" in
              Running) class="running" ;;
              Paused) class="paused" ;;
              Finished) class="finished" ;;
          esac
          
          local percentage
          if [[ "$duration" -gt 0 ]]; then
              # Use awk for floating point like Rust
              percentage=$(awk "BEGIN {printf \"%.1f\", ($display_time_left / $duration) * 100}")
          else
              percentage="0.0"
          fi
          
          jq -c -n \
              --arg text "$text" \
              --arg tooltip "$tooltip" \
              --arg class "$class" \
              --argjson percentage "$percentage" \
              '{text: $text, tooltip: $tooltip, class: $class, percentage: $percentage}'
      else
          get_human_readable_text
      fi
  }

  cmd_help() {
      cat <<EOFHELP
  $PROGRAM_NAME $VERSION - A command-line Pomodoro timer

  USAGE:
      $PROGRAM_NAME <COMMAND> [OPTIONS]

  COMMANDS:
      start       Start a new timer or modify existing one
      stop        Stop the timer
      pause       Toggle pause/resume
      status      Get timer status
      help        Show this help message
      version     Show version

  START OPTIONS:
      -d, --duration <DURATION>   Duration (e.g., "25m", "10:30", "1h 30m")
      -a, --add <DURATION>        Add time to running timer
      -m, --message <MESSAGE>     Custom message
      --notify                    Enable desktop notification
      --silent                    Disable alarm sound
      --wait                      Block and show progress bar
      --resume                    Resume paused timer
      --lock-screen               Lock screen when done (implies --wait)

  STATUS OPTIONS:
      -f, --format <FORMAT>       Output format: human (default), json
      -t, --time-format <FORMAT>  Time format: digital (default), segmented, seconds

  DURATION FORMATS:
      10          10 minutes
      10:30       10 minutes 30 seconds
      1:30:00     1 hour 30 minutes
      1h 30m 10s  1 hour 30 minutes 10 seconds
      30m         30 minutes

  EXAMPLES:
      $PROGRAM_NAME start -d 25m
      $PROGRAM_NAME start -d "1h 30m" -m "Deep work"
      $PROGRAM_NAME start -a 5m
      $PROGRAM_NAME pause
      $PROGRAM_NAME status -f json
      $PROGRAM_NAME stop
  EOFHELP
  }

  cmd_version() {
      echo "$PROGRAM_NAME $VERSION"
  }

  # ============================================================================
  # Main
  # ============================================================================

  main() {
      local command="''${1:-help}"
      shift || true
      
      case "$command" in
          start)
              cmd_start "$@"
              ;;
          stop)
              cmd_stop "$@"
              ;;
          pause)
              cmd_pause "$@"
              ;;
          status)
              cmd_status "$@"
              ;;
          help|--help|-h)
              cmd_help
              ;;
          version|--version|-V)
              cmd_version
              ;;
          *)
              echo "Unknown command: $command" >&2
              echo "Run '$PROGRAM_NAME help' for usage" >&2
              exit 1
              ;;
      esac
  }

  main "$@"
''
