{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  lib,
  openssl,
  curl,
  dbus,
  luajit_2_1,
  fetchpatch2,

  # Set to off by default, since upstream removed the feature
  parental-bypass-patch ? false,
  ...
}:

let
  branch = "main";
  rev = "4dec48344c51c8180a23d914e5522a9ab0ed70f5";
  hash = "sha256-lNs5Vm8eR3+10Jt4V/8J2y/InWnlqXCfnWAn0uNjOKY=";
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
    dbus
    luajit_2_1
  ];

  postPatch = ''
    patchShebangs ./embed-version.sh ./embed-config.sh
    substituteInPlace ./embed-version.sh \
      --replace-fail "\$BRANCH" ${branch} \
      --replace-fail "\$LAST_COMMIT_HASH" ${rev}
  '';

  installPhase = ''
    runHook preInstall

    install -D bin/SLSsteam.so -t $out/lib/

    runHook postInstall
  '';
 
  passthru = let
    pkg = finalAttrs.finalPackage;
  in {
    LD_AUDIT = "${pkg}/lib/SLSsteam.so";
  };

  meta = {
    description = "Steamclient Modification for Linux";
    homepage = "https://github.com/AceSLS/SLSsteam";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
})
