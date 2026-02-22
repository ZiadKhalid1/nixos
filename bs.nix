{
  writeShellScriptBin,
  nixos-rebuild,
  ...
}:
writeShellScriptBin "bs" ''
  ${nixos-rebuild}/bin/nixos-rebuild switch \
    -I "nixos-config=/home/ziad/nixos/default.nix" \
    "$@"
''
