{ writeShellScriptBin, nixos-rebuild, sources ? import ./npins , ... }:
writeShellScriptBin "bs" ''
  ${nixos-rebuild}/bin/nixos-rebuild switch -I nixpkgs=${sources.nixpkgs} -I home-manager=${sources.home-manager} -I nixos-config=${./.} "$@"
''
