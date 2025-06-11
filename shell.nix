let
  # Import pinned repositories
  sources = import ./npins;
  # Grab nixpkgs from there
  pkgs = import sources.nixpkgs { config.allowUnfree = true; };
  # Grab home-manager as well
  home-manager = import sources.home-manager { };
in
# Create a shell
pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.npins # grab the latest version of niv
  ];
  packages = with pkgs; [
    npins
    nixd
    nil
    nixfmt-rfc-style
    (callPackage ./bs.nix { })
  ];
  NIX_PATH =
    "nixos=${sources.nixpkgs}:nixpkgs=${sources.nixpkgs}:home-manager=${sources.home-manager}:nixos-config=/home/ziad/nixos/default.nix";
}
