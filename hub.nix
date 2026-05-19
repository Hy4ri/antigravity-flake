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
}:

let
  version = (builtins.fromJSON (builtins.readFile ./version.json)).hub.version;
  system = stdenv.hostPlatform.system;
  isDarwin = stdenv.hostPlatform.isDarwin;

  platformAttrs = {
    x86_64-linux = {
      arch = "linux-x64";
      filename = "Antigravity.tar.gz";
      extractDir = "Antigravity-x64";
      hash = "15s29lhd2h0il07ixk2qmmqd6rpsxc62ngnwnyrqzgm5h2s9rg0l";
    };
    aarch64-linux = {
      arch = "linux-arm";
      filename = "Antigravity.tar.gz";
      extractDir = "Antigravity-arm64";
      hash = "1q3ihlla4zqa9a48sggm181pys581n8nhzvfg7q9vni0zi4mzps2";
    };
    x86_64-darwin = {
      arch = "darwin-x64";
      filename = "Antigravity.dmg";
      extractDir = "";
      hash = "19i0gdg877ry4p5a5g7snm0xrgqr9kv0z0ai7m2mcrl6h4dmc5kl";
    };
    aarch64-darwin = {
      arch = "darwin-arm";
      filename = "Antigravity.dmg";
      extractDir = "";
      hash = "1pagpzk97h9p4n4w1vkn3gpjvhpql456n9w7z6392hfww05kcv7r";
    };
  };

  attrs = platformAttrs.${system} or (throw "Unsupported system: ${system}");
  url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}/${attrs.arch}/${attrs.filename}";

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
    stdenv.cc.cc
  ];
in

stdenv.mkDerivation {
  pname = "antigravity-hub";
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
    cp -r "Antigravity.app" $out/Applications/
    runHook postInstall
  '' else ''
    runHook preInstall

    mkdir -p "$out/opt/antigravity-hub"
    cp -r "${attrs.extractDir}"/* "$out/opt/antigravity-hub/"

    # Make CLI symlink/wrapper
    mkdir -p $out/bin
    makeWrapper "$out/opt/antigravity-hub/antigravity" "$out/bin/antigravity" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}

    # Desktop Launcher
    mkdir -p $out/share/applications
    cat > "$out/share/applications/antigravity.desktop" << EOF
[Desktop Entry]
Name=Antigravity Hub
Exec=$out/bin/antigravity
Icon=antigravity
Type=Application
Categories=Development;
Comment=Google Antigravity Desktop Hub
EOF

    runHook postInstall
  '';

  meta = {
    description = "Google Antigravity Hub";
    homepage = "https://antigravity.google";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "antigravity";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
