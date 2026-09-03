{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  lib,
  openssl,
  curl,
  libnotify,
  luajit_2_1,
  ...
}:

let
  rev = "bbe1e3f42710eb520e59ae3cf7b02205aa00ade7";
  hash = "sha256-iD2xoF8NPxhNGXiOoWqDNEFNFYoESQdRdem8wHdHpJ0=";
in stdenv.mkDerivation (finalAttrs: {
  pname = "SLSsteam";
  version = "git-${lib.sources.shortRev rev}";

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
    luajit_2_1
  ];

  postPatch = ''
    substituteInPlace ./src/log.cpp \
      --replace-fail "notify-send" ${lib.getExe libnotify}
    substituteInPlace ./src/curl.cpp \
      --replace-fail "/bin/curl" ${lib.getExe curl}
  '';

  installPhase = ''
    runHook preInstall

    install -D bin/SLSsteam.so bin/library-inject.so -t $out/lib/

    runHook postInstall
  '';
 
  passthru = let
    pkg = finalAttrs.finalPackage;
  in {
    LD_AUDIT = "${pkg}/lib/library-inject.so:${pkg}/lib/SLSsteam.so";
  };

  meta = {
    description = "Steamclient Modification for Linux";
    homepage = "https://github.com/AceSLS/SLSsteam";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
})
