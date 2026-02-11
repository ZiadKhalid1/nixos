let
  pkgs = import <nixpkgs> { config.allowUnfree = true; };
in
# Create a shell
pkgs.mkShell {
  packages = with pkgs; [
    (callPackage ./bs.nix { })
  ];
  NIX_PATH = "nixos-config=/home/ziad/nixos/default.nix";
}
