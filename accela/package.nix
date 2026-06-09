{
  stdenv,
  lib,
  fetchurl,
  appimageTools,
  python3,
  extraPythonPackages ? [],
  dotnet-runtime_9,
  p7zip,
  makeWrapper,
  pkgs,
  ...
}:

let
  pname = "accela";
  version = "20260512201930";
  hash = "sha256-Zu7ES0ecHIiUEcHZJZ+fBNqXIlz9BCBtWgmvBhd6eSY=";

  pythonEnv = python3.withPackages (pypkgs: with pypkgs; [
      pyqt6
      urllib3
      (pkgs.callPackage ../steam/package-solsticegamestudios.nix {})
      cryptography
      zstandard
      numpy
      (pkgs.callPackage ./just_playback-package.nix {})
      psutil
      pillow
      urwid # should be different version
    ] ++ extraPythonPackages
  );

  appImage = fetchurl {
    inherit hash;
    url = "https://github.com/HANDZCZ/nix-tools-steam/releases/download/Accela-v${version}/Accela-v${version}.7z";

    nativeBuildInputs = [ p7zip ];

    downloadToTemp = true;
    postFetch = ''
      7z e "$downloadedFile" "bin/ACCELA.AppImage"
      install -Dm 444 "ACCELA.AppImage" "$out"
    '';
  };

  appimageContents = appimageTools.extract {
    inherit pname version;
    src = appImage;
  };
in stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  src = appimageContents;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    dotnet-runtime_9
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/libexec/accela

    cp -r ./bin/src/* $out/libexec/accela

    makeWrapper ${lib.getExe pythonEnv} $out/bin/accela \
      --add-flags "$out/libexec/accela/main.py" \
      --set PYTHONPATH "$out/libexec/accela" \
      --prefix PATH : ${lib.makeBinPath finalAttrs.buildInputs}

    runHook postInstall
  '';

  meta = {
    description = "ACCELA extracted AppImage package for Enter The Wired";
    homepage = "https://github.com/ciscosweater/enter-the-wired";
    license = lib.licenses.mit;
    mainProgram = "accela";
  };
})

