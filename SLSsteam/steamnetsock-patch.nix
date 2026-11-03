{
  stdenv,
  lib,
  fetchFromGitHub,
  ...
}:

let
  rev = "4cbf251ae5b7884f100f96b833d5ad722b9762d6";
  hash = "sha256-70/O/4hAfgQG2ZYNarDg2uoDC8R/ofSwM8LfoRLhW2k=";
in stdenv.mkDerivation (finalAttrs: {
  pname = "steamnetsock-patch";
  version = "git-${lib.sources.shortRev rev}";

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "yesyes0649";
    repo = "steamnetsock-patch";
  };

  buildPhase = ''
    $CC -O3 -shared -fPIC -o fix.so steamclient_audit.c -ldl -o steamnetsock-patch.so
  '';

  installPhase = ''
    install -D steamnetsock-patch.so -t $out/lib
  '';

  passthru = let
    pkg = finalAttrs.finalPackage;
  in {
    LD_AUDIT = "${pkg}/lib/steamnetsock-patch.so";
  };

  meta = {
    description = "Patch to fix multiplayer in a small number of games when using SLSsteam's FakeAppIds feature";
    homepage = "https://github.com/yesyes0649/steamnetsock-patch";
    platforms = lib.platforms.linux;
  };
})
