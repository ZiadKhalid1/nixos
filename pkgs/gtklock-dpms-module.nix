{
  stdenv,
  fetchFromSourcehut,
  meson,
  ninja,
  pkg-config,
  gtk3,
  gtklock,
  wlr-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation rec {
  pname = "gtklock-dpms-module";
  version = "4.0.0";

  src = fetchFromSourcehut {
    owner = "~aperezdc";
    repo = pname;
    rev = "main";
    sha256 = "sha256-tiENkrgwKMfw+cCWizHTwOIkCfZ9jnONL6rkokyuxOw="; # replace after first build
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    gtklock
    gtk3
    wlr-protocols
  ];

  dontUseMesonInstall = true;
  #
  installPhase = ''
    runHook preInstall

    install -Dm755 libgtklock-dpms.so "$out/lib/gtklock/dpms-module.so"

    runHook postInstall
  '';
}
