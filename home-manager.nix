{
  pkgs,
  catppuccin,
  lib,
  ...
}:
{
  imports = [
    ./sway.nix
    "${catppuccin}/modules/home-manager"
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
    #(pkgs.callPackage ./pkgs/zed-editor-bin.nix { })
    zathura
  ];
  programs = {
    firefox.enable = true;
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
    swaync.font = "FiraCodeNerd";
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

  xdg.configFile."bilal/config.toml".text = ''
    latitude = 27.180134
    longitude = 31.189283
    madhab = "Shafi"
    method = "Egyptian"
    time_format = "12H"
  '';

  programs.helix = {
    enable = true;
    settings = {
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    extraPackages = [
      pkgs.nil
      pkgs.nixd
    ];
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      }
    ];

  };

  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-fhs;
    extensions = [
      "nix"
      "toml"
    ];
    userSettings = {
      auto-update = false;
      vim_mode = true;
      languages = {
        Nix = {
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
        };
      };
    };
    extraPackages = [
      pkgs.nil
      pkgs.nixd
      pkgs.nixfmt-rfc-style
    ];
  };
  home.stateVersion = "25.11";
}
