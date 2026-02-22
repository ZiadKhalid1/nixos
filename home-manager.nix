{
  pkgs,
  rolling,
  lib,
  config,
  ...
}:
let
  hasNixSearchTV = pkgs ? nix-search-tv;
  compress = pkgs.writeShellApplication {
    name = "compress";
    runtimeInputs = [ pkgs.ffmpeg ];
    text = builtins.readFile ./scripts/compress.sh;
  };
  signal-desktop-wrapped = pkgs.writeShellScriptBin "signal-desktop" ''
    exec ${rolling.signal-desktop-bin}/bin/signal-desktop --password-store="gnome-libsecret" "$@"
  '';
in

{
  xdg.desktopEntries.signal-desktop = {
    name = "Signal";
    exec = "signal-desktop";
    icon = "${rolling.signal-desktop-bin}/share/icons/hicolor/512x512/apps/signal-desktop.png";
    comment = "Private messenger";
    genericName = "Private Messenger";
  };

  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = "org.gnome.Geary.desktop";
    "x-scheme-handler/terminal" = "foot.desktop";
  };

  home.packages = with pkgs; [
    opencode
    codeblocksFull
    snapper-gui
    standardnotes
    qtspim
    obs-studio
    mcp-nixos
    ente-auth
    gimp
    clang
    ente-desktop
    nix-search-tv
    compress
    man-pages
    man-pages-posix
    teams-for-linux
    kooha
    rolling.gemini-cli
    evince
    zoom-us
    jetbrains.clion
    telegram-desktop
    xournalpp
    obsidian
    discord
    signal-desktop-wrapped
    octaveFull
    octavePackages.control
  ];

  dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        user-themes.extensionUuid
        athantimes.extensionUuid
      ];
    };
  };

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

  programs = {
    uv.enable = true;
    mcfly.enable = true;
    chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };
    starship = {
      enable = true;
      settings = {
        command_timeout = 1300;
        scan_timeout = 50;
        format = lib.concatStrings [
          "$all"
        ];
        character = {
          success_symbol = "[](bold green) ";
          error_symbol = "[✗](bold red) ";
        };
      };
    };
    nix-your-shell = {
      enable = true;
    };
    firefox.enable = true;
    claude-code.enable = true;
    lazygit.enable = true;
    bat.enable = true;
    rofi = {
      enable = true;
      package = pkgs.rofi;
      font = lib.mkForce "Inter 14";
      terminal = "${pkgs.foot}/bin/foot";
      location = "center";
      extraConfig = {
        show-icons = true;
        icon-theme = "Papirus-Dark";
        display-drun = " Apps";
        display-window = " Windows";
        display-clipboard = " Clipboard";
        drun-display-format = "{name}";
        hover-select = true;
        me-select-entry = "";
        me-accept-entry = "MousePrimary";
        kb-cancel = "Escape,Super+v";
      };
      theme =
        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            border-radius = mkLiteral "12px";
          };
          window = {
            width = mkLiteral "680px";
            padding = mkLiteral "0px";
            border = mkLiteral "2px solid";
            border-radius = mkLiteral "16px";
          };
          mainbox = {
            padding = mkLiteral "12px";
            spacing = mkLiteral "12px";
          };
          inputbar = {
            padding = mkLiteral "10px 16px";
            spacing = mkLiteral "10px";
            border-radius = mkLiteral "10px";
            children = map mkLiteral [ "icon-search" "entry" ];
          };
          "icon-search" = {
            expand = false;
            filename = "search";
            size = mkLiteral "20px";
            vertical-align = mkLiteral "0.5";
          };
          entry = {
            placeholder = "Search...";
            placeholder-color = mkLiteral "inherit";
          };
          listbox = {
            spacing = mkLiteral "8px";
          };
          listview = {
            lines = 8;
            columns = 1;
            fixed-height = true;
            spacing = mkLiteral "4px";
            scrollbar = false;
          };
          element = {
            padding = mkLiteral "8px 14px";
            spacing = mkLiteral "12px";
            border-radius = mkLiteral "10px";
          };
          "element-icon" = {
            size = mkLiteral "28px";
            vertical-align = mkLiteral "0.5";
          };
          "element-text" = {
            vertical-align = mkLiteral "0.5";
          };
        };
    };
    mpv.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global = {
          log_filter = "^$";
        };
      };
    };
    bash.enable = true;
    eza = {
      enable = true;
      colors = "auto";
      git = true;
      icons = "always";
    };
    git = {
      enable = true;
      settings = {
        user = {
          email = "ziadk1433@gmail.com";
          name = "Ziad Khaled";
        };
      };
    };
    helix = {
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
    zed-editor = {
      enable = true;
      package = pkgs.zed-editor-fhs;
      extensions = [
        "catppuccin"
        "nix"
        "toml"
      ];
      userSettings = {
        theme = {
          mode = "dark";
          dark = "Catppuccin Mocha";
          light = "Catppuccin Mocha";
        };
        buffer_font_family = "JetBrains Mono";
        buffer_font_size = 16;
        ui_font_family = "JetBrains Mono";
        ui_font_size = 16;
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
        pkgs.clang-tools
      ];
    };
  };

  home.shellAliases = {
    ll = "ls -l";
    edit = "sudo -e";
    ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
    cat = "bat";
    build-sway = "systemd-inhibit --what=idle sudo nixos-rebuild switch --specialisation sway";
    build = "systemd-inhibit --what=idle sudo nixos-rebuild switch";
    nix-uns = "nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz -p";
  };

  services.gnome-keyring = {
    enable = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  stylix.targets.firefox.enable = false;
  stylix.targets.zed.enable = false;
  # stylix.targets.waybar.enable = false;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    configFile."xfce4/helpers.rc".text = ''
      TerminalEmulator=foot
    '';
  };

  xdg.configFile."bilal/config.toml".text = ''
    latitude = 27.180134
    longitude = 31.189283
    madhab = "Shafi"
    method = "Egyptian"
    time_format = "12H"
  '';

  home.stateVersion = "25.11";
}
