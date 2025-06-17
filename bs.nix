{
  writeShellScriptBin,
  nixos-rebuild,
  sources ? import ./npins,
  ...
}:
writeShellScriptBin "bs" ''
  ${nixos-rebuild}/bin/nixos-rebuild switch \
    -I "nixos=${sources.nixpkgs}" \
    -I "nixpkgs=${sources.nixpkgs}" \
    -I "home-manager=${sources.home-manager}" \
    -I "nixos-hardware=${sources.nixos-hardware}" \
    -I "nixos-config=/home/ziad/nixos/default.nix" \
    "$@"
''
