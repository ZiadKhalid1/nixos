{ ... }: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    # systemd.target = "sway-session.target";

    style = builtins.readFile ./waybar.css;
  };
}
