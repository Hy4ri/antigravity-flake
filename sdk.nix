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
  version = (builtins.fromJSON (builtins.readFile ./version.json)).sdk.version;
  system = stdenv.hostPlatform.system;
  isDarwin = stdenv.hostPlatform.isDarwin;

  # Platform-specific wheel paths and hashes
  platformAttrs = {
    x86_64-linux = {
      url = "https://files.pythonhosted.org/packages/df/70/812e0ef107fa1b71c3079eab7162928b0695ce59646e19ea32bfb2a21ab7/google_antigravity-0.1.0-py3-none-manylinux_2_17_x86_64.whl";
      hash = "sha256-KRsHLAwp34brbDyID8Vgb5E74GKQBmXGvUgkZtbUhz0=";
    };
    aarch64-linux = {
      url = "https://files.pythonhosted.org/packages/21/6b/ba0147caab068ab7a3f76ed88b0f831aed859efdeded4f9e4dd3bf006ca8/google_antigravity-0.1.0-py3-none-manylinux_2_17_aarch64.whl";
      hash = "sha256-elb8OkifDEfGpv1DnTUZm4N6Hk6tqmRyYojAJnFbJP0=";
    };
    aarch64-darwin = {
      url = "https://files.pythonhosted.org/packages/59/28/1008e2d5ee2a2209a7bc3821cde154417ac47f9e4c64f3e9931cbf8d088e/google_antigravity-0.1.0-py3-none-macosx_11_0_arm64.whl";
      hash = "sha256-BmtKZOfyCJntsQAorx0c8RNhb9LA/L8zdAGDQ/m5Bns=";
    };
  };

  attrs = platformAttrs.${system} or (throw "Unsupported system: ${system}");
in

buildPythonPackage rec {
  pname = "google-antigravity";
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
