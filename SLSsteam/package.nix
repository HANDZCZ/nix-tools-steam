{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  lib,
  openssl,
  curl,
  libnotify,
  ...
}:

let
  rev = "c09357dabe9547d49f8416b6d2d948f674cbc4b9";
  hash = "sha256-Kq1g3BaHa0KtBZ/dj2QqIlLXfKhQGvJeSwXfPeHElHM=";
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
    libnotify
  ];

  postPatch = ''
    substituteInPlace ./src/log.hpp \
      --replace-fail "notify-send" ${lib.getExe libnotify}
    substituteInPlace ./src/curl.cpp \
      --replace-fail "/bin/curl" ${lib.getExe curl}
  '';


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
