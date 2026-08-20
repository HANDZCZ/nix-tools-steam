{
  lib,
  python3Packages,
  fetchFromGitHub,
  ...
}:

let
  rev = "1373e885f26bb636225443787f54d4082283e5f3";
  hash = "sha256-tJ/iLuDe3y3v1wcCsHzQoVhcpT7GC+zUh2ZXbhevI7k=";

  new-vdf = python3Packages.vdf.overridePythonAttrs (final: prev: {
    version = "4.0";
    patches = [];
    src = fetchFromGitHub {
      owner = "solsticegamestudios";
      repo = "vdf";
      rev = "v${final.version}";
      hash = "sha256-MGhzIAy5uLulb57oz6OZ7pHFweHIDxi0WyjnPfGsA/k=";
    };
  });
in python3Packages.buildPythonPackage (finalAttrs: {
  pname = "steam";
  version = "2.0.0a1.post1+g${lib.sources.shortRev rev}";
  pyproject = true;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "solsticegamestudios";
    repo = "steam";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pycryptodomex
    requests
    cachetools
    new-vdf
    gevent
    protobuf5
    gevent-eventemitter
    wsproto
    zstandard
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "version=__version__" "version='${finalAttrs.version}'"
  '';

  meta = {
    description = "Python package for interacting with Steam";
    homepage = "https://github.com/solsticegamestudios/steam";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
