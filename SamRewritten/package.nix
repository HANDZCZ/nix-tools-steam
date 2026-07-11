{
  lib,
  fetchFromGitHub,
  rustPlatform,
  glib,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libadwaita,

  use-adwaita ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "SamRewritten";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "PaulCombal";
    repo = "SamRewritten";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WYwuYNbapD0cIifQALtfgMNqXs5KMvaCsQqUdifJwf8=";
  };

  cargoHash = "sha256-dh4WPk6rU/HsUVJTMrMPsqKXpOmb/0LUAsGTbmdI6Ts=";

  dontWrapGApps = true;

  buildFeatures = []
    ++ lib.optional use-adwaita "adwaita";

  checkFlags = [
    # In sandbox we can't connect to steam and run these tests
    "--skip=backend::tests::tests::"
  ];

  nativeBuildInputs = [
    glib
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
  ]
    ++ lib.optional use-adwaita libadwaita;

  postInstall = ''
    # Copy icons
    install -Dm644 "assets/icon_64.png" "$out/share/icons/hicolor/64x64/apps/samrewritten.png"
    install -Dm644 "assets/icon_256.png" "$out/share/icons/hicolor/256x256/apps/samrewritten.png"

    # Copy desktop entry and fix exec
    substituteInPlace "package/samrewritten.desktop" \
      --replace-fail "Exec=/usr/bin/samrewritten" "Exec=samrewritten"
    install -Dm644 "package/samrewritten.desktop" -t "$out/share/applications/"

    # Copy schemas needed for gtk
    install -Dm644 "assets/org.samrewritten.SamRewritten.gschema.xml" -t "$out/share/glib-2.0/schemas/"
    install -Dm644 "assets/gschemas.compiled" -t "$out/share/glib-2.0/schemas/"

    # Copy translations
    for mo in locale/*/LC_MESSAGES/samrewritten.mo; do
      [ -e "$mo" ] || continue
      install -Dm644 "$mo" "$out/share/$mo"
    done
  '';

  postFixup = ''
    wrapProgram $out/bin/samrewritten \
      --set SAM_LOCALE_DIR_FALLBACK "$out/share/locale" \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "A modern Steam achievements manager";
    homepage = "https://github.com/PaulCombal/SamRewritten";
    changelog = "https://github.com/PaulCombal/SamRewritten/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "samrewritten";
  };
})

