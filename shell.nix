{
  pkgs ? import <nixpkgs> {},
  use-bwrap ? false
}:

let
  lib = pkgs.lib;
  packages = builtins.attrValues (import ./packages.nix { inherit pkgs; }).apps;
in pkgs.mkShell {
  packages = with pkgs; []
    ++ lib.optional use-bwrap pkgs.bubblewrap
    ++ packages;

  shellHook = lib.optionalString use-bwrap /* bash */ ''
    WORKDIR="$(pwd)/bwrap-workdir";
    mkdir -p $WORKDIR/{home,bwrap-tmp,work}
    mkdir -p $WORKDIR/bwrap-tmp/home

    echo "Entering bubblewrap!"
    cd "$WORKDIR/work"
    exec bwrap --ro-bind / / \
      --overlay-src /home \
      --overlay "$WORKDIR/home" "$WORKDIR/bwrap-tmp/home" /home \
      --bind "$WORKDIR/work" "$WORKDIR/work" \
      --dev /dev \
      $SHELL
  '';
}

