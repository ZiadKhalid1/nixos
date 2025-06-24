{
  lib,
  stdenv,
  makeWrapper,
  bash,
  curl,
  jq,
  openssl,
  netcat,
  git,
  xdg-utils,
  coreutils,
}:

stdenv.mkDerivation rec {
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
}
