with import <nixpkgs> { };

mkShell {
  packages = [
    nil
    nixd
    nixfmt-rfc-style
  ];
}
