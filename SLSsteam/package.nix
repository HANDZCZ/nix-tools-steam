{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  lib,
  openssl,
  curl,
  ...
}:

let
  rev = "981da676e76f72b1ed3c387f192509ac9a1b91e4";
  hash = "sha256-gDNHztsHGFAmbbj7Gcu8vWcFU5+4c1EeGU4lhb7Hnqo=";
in stdenv.mkDerivation (finalAttrs: {
  pname = "SLSsteam";
  version = "git-${rev}";

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "AceSLS";
    repo = "SLSsteam";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
    curl
  ];

  patches = [
    ./dont-build-ticket-grabber.patch
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp bin/SLSsteam.so $out/lib/
    cp bin/library-inject.so $out/lib/

    runHook postInstall
  '';

  meta = {
    description = "Steamclient Modification for Linux";
    homepage = "https://github.com/AceSLS/SLSsteam";
    license = lib.licenses.agpl3Only;
  };
})
