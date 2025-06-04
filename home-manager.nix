{ pkgs, ... }: {

  imports = [
    ./sway.nix

      "${builtins.fetchTarball "https://github.com/catppuccin/nix/archive/main.tar.gz"}/modules/home-manager"
  ];
  home.pointerCursor = {
       name = "Adwaita";
       package = pkgs.adwaita-icon-theme;
       size = 24;
       x11 = {
         enable = true;
         defaultCursor = "Adwaita";
       };
       #sway.enable = true;
  };
  home.packages = with pkgs; [
    nil
    nixd
    clang-tools
    clang
    (pkgs.callPackage ./zed-editor-bin.nix { })
  ];
    programs = {
      firefox.enable = true;
      fish.enable = true;
      helix.enable = true;
      vim.enable = true;
      neovim.enable = true;
    };

    programs.bash = {
      initExtra = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };

    programs.foot = {
      enable = true;
      settings = {
        main = {
	      font ="Fira Code:size=16";
	  };
	};
    };
    services.cliphist.enable = true;
    services.cliphist.allowImages = true;
    services.cliphist.systemdTarget = "sway-session.target";
    services.gnome-keyring = {
      enable = true;
    };

    catppuccin = {
  	  flavor = "mocha";
  	  enable = true;
     gtk.enable = true;
    };
    gtk.enable = true;
    programs.git = {
        enable = true;
        delta.enable = true;
        userEmail = "ziadk1433@gmail.com";
        userName = "Ziad Khaled";
    };

    home.stateVersion = "24.11";
}
