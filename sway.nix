{ config, lib, pkgs, ... }: {

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
    extraConfig = "# Brightness
    bindsym XF86MonBrightnessDown exec light -U 10
    bindsym XF86MonBrightnessUp exec light -A 10

    # Volume
    bindsym XF86AudioRaiseVolume exec '${pactl} set-sink-volume @DEFAULT_SINK@ +5%'
    bindsym XF86AudioLowerVolume exec '${pactl} set-sink-volume @DEFAULT_SINK@ -5%'
    bindsym XF86AudioMute exec '${pactl} set-sink-mute @DEFAULT_SINK@ toggle'";
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
        { command = "${lib.getExe pkgs.swaybg} -i ${builtins.fetchurl "https://upload.wikimedia.org/wikipedia/commons/0/07/Sway_Wallpaper_Blue_1920x1080.png"}"; always = true; }
      ];
    };
  };
}
