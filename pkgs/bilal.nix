{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "bilal";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "azzamsa";
    repo = "bilal";
    rev = "v${version}";
    sha256 = "sha256-O/2L1kMuN4eHXZLyawj2cX/O0IUS9E/DmStZsFHt7BI=";
  };

  cargoHash = "sha256-rvt/yZ0RXzOcHDUu8z3J7SeZpm4F352TTvKVitj5XNE=";

}
