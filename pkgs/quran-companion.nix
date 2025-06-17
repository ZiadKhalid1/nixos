{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "1.3.3";
  pname = "quran-companion";

  src = fetchurl {
    url = "https://github.com/0xzer0x/quran-companion/releases/download/v${version}/Quran_Companion-${version}-x86_64.AppImage";
    hash = "sha256-XdtI941h1dfLJ8iGl2nJuiIM8zHTdH6aot+Oba6T6xo=";
  };
  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;
  extraPkgs =
    pkgs: with pkgs; [
      zstd
    ];

  # cp ${appimageContents}sr/share/icons/hicolor/256x256/apps/io.github._0xzer0x.qurancompanion.png $out/share/applications/${pname}.deskto
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp  ${appimageContents}/usr/share/applications/io.github._0xzer0x.qurancompanion.desktop $out/share/applications/${pname}.desktop
  '';

  meta = {
    description = "Free and open-source desktop Quran reader and player";
    homepage = "https://github.com/0xzer0x/quran-companion";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname; # This ensures Exec substitution works
  };
}
