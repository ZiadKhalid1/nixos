{
  rustPlatform,
  fetchurl,
  pkg-config,
  alsa-lib,
}:

rustPlatform.buildRustPackage rec {
  pname = "pomodoro-cli";
  version = "1.2.5";

  src = fetchurl {
    url = "https://github.com/jkallio/pomodoro-cli/archive/refs/tags/v.${version}.tar.gz";
    sha256 = "sha256-pubbQED/uoOk0EmkTAds8jK1F8ss1qtmDZ6MMWk2zIY=";
  };

  cargoHash = "sha256-hT4WPLOSiFEIivVJPa7RWFk9ZzNpaYmPHRdn/lIY43o=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib ];
  doCheck = false;
}
