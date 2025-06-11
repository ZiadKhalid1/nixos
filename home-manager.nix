{ pkgs, catppuccin, lib, ... }:
let
  sources = import ./npins;
in

{
  imports = [
    ./sway.nix
    (sources.catppuccin + "/modules/home-manager")
  ];
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
  };
  home.packages = with pkgs; [
    nil

    clang-tools
    clang
    (pkgs.callPackage ./zed-editor-bin.nix { })
  ];
  programs = {
    firefox.enable = true;
    helix.enable = true;
    vim.enable = true;
    neovim.enable = true;
  };
  programs.rofi = {
    enable = true;
    #extraConfig = builtins.readFile ./rofi.css;
    plugins = with pkgs; [
      rofi-screenshot
      rofi-bluetooth
      rofi-power-menu
    ];
  };

  programs.mpv = {
    enable = true;
    config = {
      profile = [ " gpu-hq" ];
    };
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "hydro";
        src = pkgs.fishPlugins.hydro.src;
      }
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
    ];
  };
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ "$(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm)" != "fish" && -z "$BASH_EXECUTION_STRING" ]]; then
        if shopt -q login_shell; then
          LOGIN_OPTION="--login"
        else
          LOGIN_OPTION=""
        fi
        exec fish $LOGIN_OPTION
      fi
    '';
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Fira Code:size=16";
      };
    };
  };
  services.cliphist.enable = true;
  services.cliphist.allowImages = true;
  services.cliphist.systemdTargets = "sway-session.target";
  services.gnome-keyring = {
    enable = true;
  };

   catppuccin = {
     flavor = "mocha";
     enable = true;
     rofi.enable = true;
     gtk = {
       enable = true;
       accent = "blue";
       icon.enable = true;
       icon.accent = "blue";
     };
   };
  gtk.enable = true;
  programs.git = {
    enable = true;
    delta.enable = true;
    userEmail = "ziadk1433@gmail.com";
    userName = "Ziad Khaled";
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
  # programs.zed-editor = {
  #   enable = true;
  #   extensions = [
  #     "catppuccin"
  #     "nix"
  #   ];
  #   settings = {
  #     auto-update = false;
  #     vim_mode = true;
  #   };
  # };
  home.stateVersion = "25.11";
}
