{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:

let
  cliData = (builtins.fromJSON (builtins.readFile ./version.json)).cli;
  version = cliData.version;
  system = stdenv.hostPlatform.system;
  isDarwin = stdenv.hostPlatform.isDarwin;

  # Platform-specific naming and hashes
  platformAttrs = {
    x86_64-linux = {
      arch = "linux-x64";
      filename = "cli_linux_x64.tar.gz";
      hash = cliData.hashes.x86_64-linux;
    };
    aarch64-linux = {
      arch = "linux-arm";
      filename = "cli_linux_arm64.tar.gz";
      hash = cliData.hashes.aarch64-linux;
    };
    x86_64-darwin = {
      arch = "darwin-x64";
      filename = "cli_mac_x64.tar.gz";
      hash = cliData.hashes.x86_64-darwin;
    };
    aarch64-darwin = {
      arch = "darwin-arm";
      filename = "cli_mac_arm64.tar.gz";
      hash = cliData.hashes.aarch64-darwin;
    };
  };

  attrs = platformAttrs.${system} or (throw "Unsupported system: ${system}");
  url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${version}/${attrs.arch}/${attrs.filename}";
in

stdenv.mkDerivation {
  pname = "antigravity-cli";
  inherit version;

  src = fetchurl {
    inherit url;
    sha256 = attrs.hash;
  };

  nativeBuildInputs = lib.optionals (!isDarwin) [
    autoPatchelfHook
  ] ++ [
    makeWrapper
  ];

  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 antigravity $out/bin/.agy-wrapped
    makeWrapper $out/bin/.agy-wrapped $out/bin/agy \
      --set SSH_CONNECTION "127.0.0.1 12345 127.0.0.1 22"
    runHook postInstall
  '';

  meta = {
    description = "Google Antigravity CLI";
    homepage = "https://antigravity.google";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "agy";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
