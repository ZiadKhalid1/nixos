# Custom package overlay with all packages inlined
self: super: {
  # ═══════════════════════════════════════════════════════════════════════════
  # GTKLock Runshell Module - Display custom commands on lock screen
  # ═══════════════════════════════════════════════════════════════════════════
  gtklock-runshell-module = self.stdenv.mkDerivation {
    pname = "gtklock-runshell-module";
    version = "4.0.0";

    src = self.fetchFromGitLab {
      owner = "wef";
      repo = "gtklock-runshell-module";
      rev = "main";
      sha256 = "sha256-VhgsgVqNipJ9CfxM/P4cXUZY1fhiY57cgqtWhCh4bwQ=";
    };

    nativeBuildInputs = [
      self.meson
      self.ninja
      self.pkg-config
    ];

    buildInputs = [
      self.gtklock
      self.gtk3
    ];
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Bilal - Islamic prayer times CLI
  # ═══════════════════════════════════════════════════════════════════════════
  bilal = self.rustPlatform.buildRustPackage rec {
    pname = "bilal";
    version = "1.8.0";

    src = self.fetchFromGitHub {
      owner = "azzamsa";
      repo = "bilal";
      rev = "v${version}";
      sha256 = "sha256-O/2L1kMuN4eHXZLyawj2cX/O0IUS9E/DmStZsFHt7BI=";
    };

    cargoHash = "sha256-rvt/yZ0RXzOcHDUu8z3J7SeZpm4F352TTvKVitj5XNE=";

    meta.mainProgram = "bilal";
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Next Prayer - Display script for waybar/gtklock
  # ═══════════════════════════════════════════════════════════════════════════
  next-prayer = self.writeShellScriptBin "next-prayer" ''
    ${self.gnused}/bin/sed -E ':a;N;$!ba;s/\n/ /;s/^([[:alpha:]]+) \((.*)\) [[:alpha:]]+ \((.*)\)/\1: \2 (\3)/' <(${self.bilal}/bin/bilal next ; ${self.bilal}/bin/bilal current)
  '';

  # ═══════════════════════════════════════════════════════════════════════════
  # Find Unicode - Unicode character search tool
  # ═══════════════════════════════════════════════════════════════════════════
  find_unicode = self.rustPlatform.buildRustPackage rec {
    pname = "find_unicode";
    version = "0.4.0";

    src = self.fetchFromGitHub {
      owner = "pierrechevalier83";
      repo = "find_unicode";
      rev = "3afc33a7056f6fadd3e1d1d216d89a2f78e3ed67";
      sha256 = "sha256-hfTOUrFSlqOEzh2X3SnRx4UkmgCNDDfOjUT9325XSP8=";
    };

    cargoHash = "sha256-b+fRwdEI97Cljlz6r4sukPvkb9/x6UBKEhUDmLONh2w=";

    cargoBuildFlags = [ "--bins" ];

    # Let buildRustPackage handle installation automatically
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Git Helper - AI-powered git commit message generator
  # ═══════════════════════════════════════════════════════════════════════════
  git-helper = let
    inherit (self) lib stdenv makeWrapper bash curl jq openssl netcat git xdg-utils coreutils;
  in stdenv.mkDerivation rec {
    pname = "git-helper";
    version = "1.0.0";

    src = ../scripts/git-helper.sh;

    unpackPhase = ''
      cp $src git-helper.sh
    '';

    nativeBuildInputs = [ makeWrapper ];

    buildInputs = [
      bash
      curl
      jq
      openssl
      netcat
      git
      xdg-utils
      coreutils
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp git-helper.sh $out/bin/git-helper
      chmod +x $out/bin/git-helper

      wrapProgram $out/bin/git-helper \
        --prefix PATH : ${lib.makeBinPath buildInputs}

      runHook postInstall
    '';

    meta = with lib; {
      description = "AI-powered git commit message generator using OpenRouter";
      longDescription = ''
        A bash script that uses OpenRouter's API to generate conventional commit
        messages based on staged git changes. Supports OAuth PKCE flow for
        authentication and caches API keys locally.
      '';
      maintainers = [ ];
      platforms = platforms.unix;
    };
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Pomodoro CLI - Pomodoro timer CLI
  # ═══════════════════════════════════════════════════════════════════════════
  pomodoro-cli = self.rustPlatform.buildRustPackage rec {
    pname = "pomodoro-cli";
    version = "1.2.5";

    src = self.fetchurl {
      url = "https://github.com/jkallio/pomodoro-cli/archive/refs/tags/v.${version}.tar.gz";
      sha256 = "sha256-pubbQED/uoOk0EmkTAds8jK1F8ss1qtmDZ6MMWk2zIY=";
    };

    cargoHash = "sha256-hT4WPLOSiFEIivVJPa7RWFk9ZzNpaYmPHRdn/lIY43o=";

    nativeBuildInputs = [ self.pkg-config ];
    buildInputs = [ self.alsa-lib ];
    doCheck = false;
  };

  # ═══════════════════════════════════════════════════════════════════════════
  # Quran Companion - Desktop Quran reader and player
  # ═══════════════════════════════════════════════════════════════════════════
  quran-companion = let
    inherit (self) lib appimageTools fetchurl;
    version = "1.3.3";
    pname = "quran-companion";

    src = fetchurl {
      url = "https://github.com/0xzer0x/quran-companion/releases/download/v${version}/Quran_Companion-${version}-x86_64.AppImage";
      hash = "sha256-XdtI941h1dfLJ8iGl2nJuiIM8zHTdH6aot+Oba6T6xo=";
    };
    appimageContents = appimageTools.extract {
      inherit pname version src;
    };
  in appimageTools.wrapType2 rec {
    inherit pname version src;
    extraPkgs = pkgs: with pkgs; [ zstd ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/usr/share/applications/io.github._0xzer0x.qurancompanion.desktop $out/share/applications/${pname}.desktop
    '';

    meta = {
      description = "Free and open-source desktop Quran reader and player";
      homepage = "https://github.com/0xzer0x/quran-companion";
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = pname;
    };
  };
}
