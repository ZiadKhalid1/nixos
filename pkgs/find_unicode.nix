{
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "find_unicode";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "pierrechevalier83";
    repo = "${pname}";
    rev = "c0227e614d14724c68ed451325f24dc16597fa65"; # v0.4.0
    sha256 = "sha256-+BGMfsEPksF4kAQ6PWDrduQ/dp2m3nQwrYrx9Mo8uNY=";
  };

  cargoHash = "sha256-MDULrFaI+MvHwgl25H+F5DnIyt4AI9r9m8YeN1XB4Jk=";

  cargoBuildFlags = [ "--bins" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 target/release/fu $out/bin/fu
    install -Dm755 target/release/gen_data $out/bin/gen_data
    runHook postInstall
  '';
}
