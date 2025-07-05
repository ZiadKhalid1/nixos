{
  pkgs,
  catppuccin,
  lib,
  ...
}:
let
  hasNixSearchTV = pkgs ? nix-search-tv;
  compress = pkgs.writeShellApplication {
    name = "compress";
    runtimeInputs = [ pkgs.ffmpeg ];
    text = builtins.readFile ./scripts/compress.sh;
  };
in
{
  imports = [
    ./sway.nix
    "${catppuccin}/modules/home-manager"
  ];
  home.packages = with pkgs; [
    nil
    clang-tools
    clang
    zathura
    (pkgs.callPackage ./pkgs/pomodoro-cli.nix { })
    sway-audio-idle-inhibit
    nix-search-tv
    compress
    man-pages
    man-pages-posix
  ];
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
  home.file.".config/nix-search-tv/config.json" = lib.mkIf hasNixSearchTV {
    text = builtins.toJSON {
      indexes = [
        "nixpkgs"
        "home-manager"
        "nur"
        "nixos"
      ];
      update_interval = "168h";
      enable_waiting_message = true;
      experimental = {
        render_docs_indexes = {
          nvf = "https://notashelf.github.io/nvf/options.html";
        };
      };
    };
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command_timeout = 1300;
      scan_timeout = 50;
      format = lib.concatStrings [
        "$all"
      ];
      character = {
        success_symbol = "[](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
    };
  };
  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
  };
  programs = {
    firefox.enable = true;
    vim.enable = true;
    neovim.enable = true;
    lazygit.enable = true;
  };
  programs.bat.enable = true;
  programs.rofi = {
    enable = true;
    #extraConfig = builtins.readFile ./rofi.css;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        log_filter = "^$";
      };
    };
  };
  programs.mpv = {
    enable = true;
  };
  programs.fish = {
    enable = true;
    shellAliases = {
      ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
      cat = "bat";
      update = "sudo nixos-rebuild switch";
    };
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

  programs.eza = {
    enable = true;
    colors = "auto";
    git = true;
    icons = "always";
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrains Mono:size=16";
      };
      colors = {
        alpha = 0.5;
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
    helix.useItalics = true;
    lazygit.accent = "blue";
    cursors = {
      enable = true;
      accent = "dark";
    };
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
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        }
        {
          name = "c";
          scope = "source.c";
          injection-regex = "c";
          file-types = [ "c" ];
          comment-token = "//";
          block-comment-tokens = {
            start = "/*";
            end = "*/";
          };
          auto-format = true;
          formatter.command = "${pkgs.clang-tools}/bin/clang-format";
          language-servers = [ "clangd" ];
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
      ];
    };

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
