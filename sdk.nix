{
  lib,
  stdenv,
  fetchurl,
  buildPythonPackage,
  autoPatchelfHook,
  absl-py,
  google-genai,
  mcp,
  pydantic,
  uvicorn,
  websockets,
  protobuf,
}:

let
  sdkData = (builtins.fromJSON (builtins.readFile ./version.json)).sdk;
  version = sdkData.version;
  system = stdenv.hostPlatform.system;
  isDarwin = stdenv.hostPlatform.isDarwin;

  # Platform-specific wheel paths and hashes
  platformAttrs = {
    x86_64-linux = {
      url = sdkData.urls.x86_64-linux;
      hash = sdkData.hashes.x86_64-linux;
    };
    aarch64-linux = {
      url = sdkData.urls.aarch64-linux;
      hash = sdkData.hashes.aarch64-linux;
    };
    aarch64-darwin = {
      url = sdkData.urls.aarch64-darwin;
      hash = sdkData.hashes.aarch64-darwin;
    };
  };

  attrs = platformAttrs.${system} or (throw "Unsupported system: ${system}");
in

buildPythonPackage rec {
  pname = "antigravity-sdk";
  inherit version;
  format = "wheel";
  dontCheckRuntimeDeps = true;

  src = fetchurl {
    url = attrs.url;
    hash = attrs.hash;
  };

  # On Linux, patch the Go 'localharness' executable packaged inside the Python wheel
  nativeBuildInputs = lib.optionals (!isDarwin) [
    autoPatchelfHook
  ];

  # Make stdenv.cc.cc available for autoPatchelfHook
  buildInputs = lib.optionals (!isDarwin) [
    stdenv.cc.cc
  ];

  propagatedBuildInputs = [
    absl-py
    google-genai
    mcp
    pydantic
    uvicorn
    websockets
    protobuf
  ];

  meta = {
    description = "Google Antigravity SDK for building AI agents";
    homepage = "https://github.com/Google-Antigravity/antigravity-sdk-python";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
