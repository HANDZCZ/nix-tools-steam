{
  lib,
  python3Packages,
  fetchFromGitHub,
  ...
}:

python3Packages.buildPythonPackage rec {
  pname = "just_playback";
  version = "0.1.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cheofusi";
    repo = "just_playback";
    rev = "v${version}";
    hash = "sha256-GtOAAJXG/VGp/Z6PiIdGEhFqVR9+P911lrq4ltDj2WU=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    tinytag
    cffi
  ];

  meta = {
    description = "Small library for playing audio files in python";
    homepage = "https://github.com/cheofusi/just_playback";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
