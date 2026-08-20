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
  rev = "65b6ee1ba262fa47eca538cf9892503dc205d65b";
  hash = "sha256-kwuUKqjRSTaOyYVe5ENmczFcga8krq5+/nqbjz5EujE=";
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
