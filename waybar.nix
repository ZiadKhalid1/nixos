{ ... }: {
  home.file.waybar-conf = {
    enable = true;
    source = ./waybar-config.json;
    target = ".config/waybar/config";
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    # systemd.target = "sway-session.target";
    # settings = builtins.fromJSON (builtins.readFile ./waybar-config);
    style = builtins.readFile ./waybar.css;
  };
}
