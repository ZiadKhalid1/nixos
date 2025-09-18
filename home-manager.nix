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
    "${catppuccin}/modules/home-manager"
  ];

  home.packages = with pkgs; [
    nil
    gimp
    thunderbird-bin
    clang-tools
    clang
    zathura
    (pkgs.callPackage ./pkgs/pomodoro-cli.nix { })
    nix-search-tv
    compress
    man-pages
    man-pages-posix
    teams-for-linux
    kooha
  ];

  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
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

  programs.starship = {
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

  programs.nix-your-shell = {
    enable = true;
  };

  programs = {
    firefox.enable = true;
    vim.enable = true;
    neovim.enable = true;
    lazygit.enable = true;
    bat.enable = true;
    rofi.enable = true;
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
  };

  # programs.zsh = {
  #   enable = true;
  #   enableCompletion = true;
  #   syntaxHighlighting.enable = true;
  #   autosuggestion = {
  #     enable = true;
  #   };
  #   history.size = 10000;
  #   history.ignoreAllDups = true;
  #   history.path = "$HOME/.zsh_history";
  #   history.ignorePatterns = [
  #     "rm *"
  #     "pkill *"
  #     "cp *"
  #   ];
  # };

  home.shellAliases = {
    ll = "ls -l";
    edit = "sudo -e";
    update = "sudo nixos-rebuild switch";
    update-gnome = "sudo nixos-rebuild switch";
    update-sway = "sudo nixos-rebuild switch --specialisation sway";
    ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
    cat = "bat";
  };
  programs.bash.enable = true;

  programs.eza = {
    enable = true;
    colors = "auto";
    git = true;
    icons = "always";
  };

  services.gnome-keyring = {
    enable = true;
  };

  catppuccin = {
    flavor = "mocha";
    enable = true;
    rofi.enable = true;
    helix.useItalics = true;
    accent = "blue";
    cursors = {
      enable = true;
      accent = "dark";
    };
    gtk = {
      icon.enable = true;
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "blue" ];
      };
    };
  };

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
