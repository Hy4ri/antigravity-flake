{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  undmg,
  # Electron dynamic linking dependencies for Linux
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libgbm,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libxkbcommon,
  libXrandr,
  libXrender,
  libXt,
  libXtst,
  libxcb,
  libuuid,
  libxml2,
  nspr,
  nss,
  pango,
  systemd,
  wayland,
  vulkan-loader,
  libpulseaudio,
  libsecret,
  libnotify,
  xdg-utils,
  libxkbfile,
  webkitgtk_4_1,
  libsoup_3,
}:

let
  ideData = (builtins.fromJSON (builtins.readFile ./version.json)).ide;
  version = ideData.version;
  system = stdenv.hostPlatform.system;
  isDarwin = stdenv.hostPlatform.isDarwin;

  platformAttrs = {
    x86_64-linux = {
      arch = "linux-x64";
      filename = "Antigravity%20IDE.tar.gz";
      hash = ideData.hashes.x86_64-linux;
    };
    aarch64-linux = {
      arch = "linux-arm";
      filename = "Antigravity%20IDE.tar.gz";
      hash = ideData.hashes.aarch64-linux;
    };
    x86_64-darwin = {
      arch = "darwin-x64";
      filename = "Antigravity%20IDE.dmg";
      hash = ideData.hashes.x86_64-darwin;
    };
    aarch64-darwin = {
      arch = "darwin-arm";
      filename = "Antigravity%20IDE.dmg";
      hash = ideData.hashes.aarch64-darwin;
    };
  };

  attrs = platformAttrs.${system} or (throw "Unsupported system: ${system}");
  url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${version}/${attrs.arch}/${attrs.filename}";

  runtimeLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libgbm
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libxkbcommon
    libXrandr
    libXrender
    libXt
    libXtst
    libxcb
    libuuid
    libxml2
    nspr
    nss
    pango
    systemd
    wayland
    vulkan-loader
    libpulseaudio
    libsecret
    libnotify
    libxkbfile
    webkitgtk_4_1
    libsoup_3
    stdenv.cc.cc
  ];
in

stdenv.mkDerivation {
  pname = "antigravity-ide";
  inherit version;

  src = fetchurl {
    inherit url;
    sha256 = attrs.hash;
  };

  nativeBuildInputs = if isDarwin then [
    undmg
  ] else [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = lib.optionals (!isDarwin) runtimeLibs;

  sourceRoot = if isDarwin then "." else null;

  unpackPhase = lib.optionalString (!isDarwin) ''
    runHook preUnpack
    tar -xzf $src
    runHook postUnpack
  '';

  installPhase = if isDarwin then ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r "Antigravity IDE.app" $out/Applications/
    runHook postInstall
  '' else ''
    runHook preInstall

    mkdir -p "$out/opt/antigravity"
    cp -r "Antigravity IDE"/* "$out/opt/antigravity/"

    # Make CLI symlink/wrapper
    mkdir -p $out/bin
    makeWrapper "$out/opt/antigravity/antigravity-ide" "$out/bin/antigravity-ide" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}

    # Desktop Launcher
    mkdir -p $out/share/applications
    cat > "$out/share/applications/antigravity-ide.desktop" << EOF
[Desktop Entry]
Name=Antigravity IDE
Exec=$out/bin/antigravity-ide
Icon=antigravity-ide
Type=Application
Categories=Development;
Comment=Google Antigravity Desktop IDE
EOF

    runHook postInstall
  '';

  meta = {
    description = "Google Antigravity IDE";
    homepage = "https://antigravity.google";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "antigravity-ide";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
