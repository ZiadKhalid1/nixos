{
  pkgs ? import <nixpkgs> { },
}:

let
  rustNightly = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
in

pkgs.stdenv.mkDerivation rec {
  pname = "bilal";
  version = "1.10.0";

  src = pkgs.fetchFromGitHub {
    owner = "azzamsa";
    repo = "bilal";
    rev = "v${version}";
    sha256 = "sha256-X5Z+DLFT3IoFzXlAwjMkzDkpT69YIJx+g8Dvw5F7HdE=";
  };

  nativeBuildInputs = [
    rustNightly
    pkgs.cargo
  ];

  buildPhase = ''
    cargo build --release
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp target/release/bilal $out/bin/
  '';

  meta = with pkgs.lib; {
    description = "Command line prayer time notifier written in Rust";
    homepage = "https://github.com/azzamsa/bilal";
    license = licenses.mit;
  };
}
