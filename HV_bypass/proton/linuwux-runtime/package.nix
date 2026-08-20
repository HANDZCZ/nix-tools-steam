{
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  binutils,
  gnused,
  coreutils,
  lib,
  ...
}:

let
  rev = "650bd349451d06159b94599384d0d0cdd64d7228";
  hash = "sha256-4EafSVGVAaQdL8ca6g9AqZZww9+KoJQgURM5Et/ogYU=";
in stdenv.mkDerivation (finalAttrs: {
  pname = "linuwux-runtime";
  version = "git-${lib.sources.shortRev rev}";

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "brcly";
    repo = "linuwux-runtime";
  };

  patches = [
    ./Remove-check-for-strings-command.patch
    (fetchpatch2 {
      name = "Fix-SEGVs-during-loader-startup.diff";
      url = "https://github.com/brcly/linuwux-runtime/commit/98a7cab53150e423a2786a5b0df0107a6145a671.diff?full_index=1";
      hash = "sha256-QQNzXBDdUSaWap4/RLNeLGTb4Ogf929+joMmSblQ9Nc=";
    })
  ];

  postPatch = ''
    patchShebangs src/linuwux.sh
    substituteInPlace src/linuwux.sh \
      --replace-fail "\''${HOME}/.local/lib/liblinuwux.so" "$out/lib/liblinuwux.so" \
      --replace-fail "strings" "${binutils}/bin/strings" \
      --replace-fail "sed" "${gnused}/bin/sed" \
      --replace-fail "head" "${coreutils}/bin/head" \
      --replace-fail "~/.local/bin/linuwux" "linuwux"
  '';

  buildPhase = ''
    runHook preBuild

    local -a sources=(src/*.c src/modules/*.c)

    $CC -std=gnu11 -O2 -fPIC -fvisibility=hidden -shared -Wall \
      -DLINUWUX_VERSION=\"${finalAttrs.version}\" \
      -o liblinuwux.so "''${sources[@]}" -ldl

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D liblinuwux.so -t $out/lib/
    install -Dm755 src/linuwux.sh $out/bin/linuwux

    runHook postInstall
  '';

  meta = {
    description = "Runtime library for DenuvOwO / Reflex under GE-Proton and CachyOS Proton";
    homepage = "https://github.com/brcly/linuwux-runtime";
    changelog = "https://github.com/brcly/linuwux-runtime/releases";
    mainProgram = "linuwux";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
  };
})

