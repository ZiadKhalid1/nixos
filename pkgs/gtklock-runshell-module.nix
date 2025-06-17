{
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  gtk3,
  gtklock,
}:

stdenv.mkDerivation {
  pname = "gtklock-runshell-module";
  version = "4.0.0"; # or use latest commit date

  src = fetchFromGitLab {
    owner = "wef";
    repo = "gtklock-runshell-module";
    rev = "main"; # or use a pinned commit hash
    sha256 = "sha256-VhgsgVqNipJ9CfxM/P4cXUZY1fhiY57cgqtWhCh4bwQ="; # replace with real hash after first build
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];
  buildInputs = [
    gtklock
    gtk3
  ];

}
