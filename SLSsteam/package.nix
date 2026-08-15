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
  rev = "01a3b1ed08bc8f33fc25ee12d2b6e191a9963b38";
  hash = "sha256-GFRGB8n84MuixVcyKnLRfGKO0YajxOjiEH/a5lixg1Q=";
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
    substituteInPlace ./src/log.cpp \
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
