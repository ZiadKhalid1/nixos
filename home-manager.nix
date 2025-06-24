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
    zathura
    (pkgs.callPackage ./pkgs/pomodoro-cli.nix { })
    sway-audio-idle-inhibit
    nix-search-tv
    compress
  ];

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
    firefox.enable = true;
    vim.enable = true;
    neovim.enable = true;
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
      ls = "eza --color=always --group-directories-first --icons";
      ll = "eza -la --icons --octal-permissions --group-directories-first";
      l = "eza -bGF --header --git --color=always --group-directories-first --icons";
      llm = "eza -lbGd --header --git --sort=modified --color=always --group-directories-first --icons";
      la = "eza --long --all --group --group-directories-first";
      lx = "eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons";
      lS = "eza -1 --color=always --group-directories-first --icons";
      lt = "eza --tree --level=2 --color=always --group-directories-first --icons";
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

  programs.eza = {
    enable = true;
    colors = "auto";
    enableFishIntegration = true;
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
      grammer = [
        {
          name = "c";
          source = {
            git = "https://github.com/tree-sitter/tree-sitter-c";
            rev = "7175a6dd5fc1cee660dce6fe23f6043d75af424a";
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
