{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}:

let
  version = (builtins.fromJSON (builtins.readFile ./version.json)).cli.version;
  system = stdenv.hostPlatform.system;
  isDarwin = stdenv.hostPlatform.isDarwin;

  # Platform-specific naming and hashes
  platformAttrs = {
    x86_64-linux = {
      arch = "linux-x64";
      filename = "cli_linux_x64.tar.gz";
      hash = "1dlyx6vpzw0zsl50v0hwrrsx88jf65bq0g2ddjhc9bsgax0662bh";
    };
    aarch64-linux = {
      arch = "linux-arm";
      filename = "cli_linux_arm64.tar.gz";
      hash = "119a0x9acj5qv3jfpx6n9d1g6lbqrkmccvlaimv00sw3q6b7rp7l";
    };
    x86_64-darwin = {
      arch = "darwin-x64";
      filename = "cli_mac_x64.tar.gz";
      hash = "0lzvnfgpszs2ly0v3y7dfk8xfi2w2p969mxdwcl6dgzhvhjiljkl";
    };
    aarch64-darwin = {
      arch = "darwin-arm";
      filename = "cli_mac_arm64.tar.gz";
      hash = "02ij9qvrsp8s1q07kxmdhak3k4g8crcdf7hn7fcfy8bswaszghk5";
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
    install -Dm755 antigravity $out/bin/antigravity
    runHook postInstall
  '';

  meta = {
    description = "Google Antigravity CLI";
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
