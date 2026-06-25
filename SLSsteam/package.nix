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
  rev = "6655cb8cc17b6a38afa87b730b8fd29648b6c9fc";
  hash = "sha256-oAS8PwhlItu1yVuK8w0KUSYOubriNPKpU+pgZ2h5MNs=";
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

  patches = [
    ./dont-build-ticket-grabber.patch
    ./replace-notify-send-with-variable.patch
  ];

  postPatch = ''
    substituteInPlace ./src/log.hpp \
      --replace-fail "@@notify-send@@" ${lib.getExe libnotify}
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
