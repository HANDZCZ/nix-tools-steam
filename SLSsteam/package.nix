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
  fetchpatch2,

  # Set to off by default, since upstream removed the feature
  parental-bypass-patch ? false,
  ...
}:

let
  branch = "main";
  rev = "c61443a826a3cf58b76da97c62b33bc5db9800b1";
  hash = "sha256-kjIYUivUuOuw6ISfmkJ9T3n/WWW+74zxXG2yIKYUq3Y=";
in stdenv.mkDerivation (finalAttrs: {
  pname = "SLSsteam";
  version = "git-${lib.sources.shortRev rev}";

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "AceSLS";
    repo = "SLSsteam";
  };

  patches = lib.optional parental-bypass-patch (fetchpatch2 {
    # revert the commit that removed the feature
    # related issue: https://github.com/AceSLS/SLSsteam/issues/166
    name = "Add-parental-settings-bypass.patch";
    url = "https://github.com/AceSLS/SLSsteam/commit/188ad060f8e924faf59e34a7365fbf141181f80b.patch?full_index=1";
    hash = "sha256-Y8jHzbbdrhc99NnhjllopXuRSVkd+CRyXk37YEQ8fls=";
    revert = true;
  });

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

    patchShebangs ./embed-version.sh ./embed-config.sh
    substituteInPlace ./embed-version.sh \
      --replace-fail "\$BRANCH" ${branch} \
      --replace-fail "\$LAST_COMMIT_HASH" ${rev}
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
