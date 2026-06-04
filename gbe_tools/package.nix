{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
  extraPythonPackages ? [],
  makeWrapper,
  ...
}:

let
  rev = "8a084deae9621b0180597b1d104de74c50e49b2e";
  hash = "sha256-m+6zYZV1e7ii10ql7edYxBZY5Yo5mbpt8UyKaGsfYLY=";

  pythonOv = python3.override {
    packageOverrides = final: prev: {
      # steam needs old protobuf version
      protobuf = final.protobuf4;
      # use steam package source from the tool
      steam = prev.steam.overrideAttrs (prev: {
        version = "1.6.1";
        src = fetchFromGitHub {
          owner = "detiam";
          repo = "steam_websocket";
          rev = "b8239912e6a190f490aede529c08b5049096bdc8";
          hash = "sha256-j+mCcRtwv5WSbWJFV4WKp76kxkRjllfbZei05s+tyUs=";
        };
        # gives urllib3<2 error, but it works with newer version anyway
        dontCheckRuntimeDeps = true;
      });
    };
  };

  pythonEnv = pythonOv.withPackages (pypkgs: with pypkgs; [
      steam
      wsproto # this is needed by steam
      requests
      certifi
    ] ++ extraPythonPackages
  );
in stdenv.mkDerivation (finalAttrs: {
  pname = "gbe-tools";
  version = "git-${rev}";

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "Detanup01";
    repo = "gbe_fork_tools";
  };

  patches = [
    # prevents it from trying to write to /nix/store
    ./fix_backup_dir_location.diff
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cd generate_emu_config_old

    mkdir -p $out/bin
    mkdir -p $out/libexec/gbe_fork_tools

    cp -r * $out/libexec/gbe_fork_tools/

    makeWrapper ${lib.getExe pythonEnv} $out/bin/gbe-generate-emu-config \
      --add-flags "$out/libexec/gbe_fork_tools/generate_emu_config.py" \
      --set PYTHONPATH "$out/libexec/gbe_fork_tools"

    runHook postInstall
  '';

  meta = {
    description = "Tools for GBE Fork";
    homepage = "https://github.com/Detanup01/gbe_fork_tools";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "gbe-generate-emu-config";
  };
})
