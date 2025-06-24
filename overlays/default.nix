self: super: {
  bilal = self.callPackage ../pkgs/bilal.nix { };

  next-prayer = self.writeShellScriptBin "next-prayer" ''
    ${self.gnused}/bin/sed -E ':a;N;$!ba;s/\n/ /;s/^([[:alpha:]]+) \((.*)\) [[:alpha:]]+ \((.*)\)/\1: \2 (\3)/' <(${self.bilal}/bin/bilal next ; ${self.bilal}/bin/bilal current)
  '';

  gtklock-dpms-module = self.callPackage ../pkgs/gtklock-dpms-module.nix { };
  gtklock-runshell-module = self.callPackage ../pkgs/gtklock-runshell-module.nix { };

  gtklock-powerbar-module = super.gtklock-powerbar-module.overrideAttrs (oldAttrs: {
    postPatch = ''
      substituteInPlace source.c \
        --replace-fail "systemctl" "${self.systemd}/bin/systemctl"
    '';
  });
}

