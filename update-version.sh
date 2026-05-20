#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/version.json"

show_help() {
  echo "Google Antigravity Nix Flake Updater"
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --cli <version>   Update CLI version and recalculate its hashes"
  echo "  --hub <version>   Update Hub version and recalculate its hashes"
  echo "  --ide <version>   Update IDE version and recalculate its hashes"
  echo "  --sdk <version>   Update SDK version and recalculate its hashes"
  echo "  -h, --help        Show this help message"
}

# Parse arguments
CLI_VER=""
HUB_VER=""
IDE_VER=""
SDK_VER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cli)
      CLI_VER="$2"
      shift 2
      ;;
    --hub)
      HUB_VER="$2"
      shift 2
      ;;
    --ide)
      IDE_VER="$2"
      shift 2
      ;;
    --sdk)
      SDK_VER="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

if [[ -z "$CLI_VER" && -z "$HUB_VER" && -z "$IDE_VER" && -z "$SDK_VER" ]]; then
  echo "Error: You must specify at least one package to update."
  show_help
  exit 1
fi

# Load current version.json
if [[ ! -f "$VERSION_FILE" ]]; then
  echo "Error: version.json not found in $SCRIPT_DIR"
  exit 1
fi

get_current_val() {
  local jq_path="$1"
  jq -r "$jq_path" "$VERSION_FILE"
}

echo "------------------------------------------------"
echo "Components to update:"
[[ -n "$CLI_VER" ]] && echo "  CLI: $CLI_VER" || echo "  CLI: (skipped)"
[[ -n "$HUB_VER" ]] && echo "  Hub: $HUB_VER" || echo "  Hub: (skipped)"
[[ -n "$IDE_VER" ]] && echo "  IDE: $IDE_VER" || echo "  IDE: (skipped)"
[[ -n "$SDK_VER" ]] && echo "  SDK: $SDK_VER" || echo "  SDK: (skipped)"
echo "------------------------------------------------"

# Functions to prefetch and get Nix hash
prefetch_nix_base32() {
  local url="$1"
  local name="$2"
  nix-prefetch-url --name "$name" "$url"
}

prefetch_sri_hash() {
  local url="$1"
  local sha256_hash
  sha256_hash=$(nix-prefetch-url --type sha256 "$url" 2>/dev/null)
  nix hash convert --hash-algo sha256 --to sri "$sha256_hash"
}

# 1. Fetch CLI Hashes
if [[ -n "$CLI_VER" ]]; then
  echo ""
  echo "=== CLI Hashes ==="
  cli_x86_64_linux=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-cli/${CLI_VER}/linux-x64/cli_linux_x64.tar.gz" "cli_linux_x64.tar.gz")
  echo "  x86_64-linux: $cli_x86_64_linux"
  cli_aarch64_linux=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-cli/${CLI_VER}/linux-arm/cli_linux_arm64.tar.gz" "cli_linux_arm64.tar.gz")
  echo "  aarch64-linux: $cli_aarch64_linux"
  cli_x86_64_darwin=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-cli/${CLI_VER}/darwin-x64/cli_mac_x64.tar.gz" "cli_mac_x64.tar.gz")
  echo "  x86_64-darwin: $cli_x86_64_darwin"
  cli_aarch64_darwin=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-cli/${CLI_VER}/darwin-arm/cli_mac_arm64.tar.gz" "cli_mac_arm64.tar.gz")
  echo "  aarch64-darwin: $cli_aarch64_darwin"
fi

# 2. Fetch Hub Hashes
if [[ -n "$HUB_VER" ]]; then
  echo ""
  echo "=== Hub Hashes ==="
  hub_x86_64_linux=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-hub/${HUB_VER}/linux-x64/Antigravity.tar.gz" "Antigravity_x64.tar.gz")
  echo "  x86_64-linux: $hub_x86_64_linux"
  hub_aarch64_linux=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-hub/${HUB_VER}/linux-arm/Antigravity.tar.gz" "Antigravity_arm.tar.gz")
  echo "  aarch64-linux: $hub_aarch64_linux"
  hub_x86_64_darwin=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-hub/${HUB_VER}/darwin-x64/Antigravity.dmg" "Antigravity_x64.dmg")
  echo "  x86_64-darwin: $hub_x86_64_darwin"
  hub_aarch64_darwin=$(prefetch_nix_base32 "https://storage.googleapis.com/antigravity-public/antigravity-hub/${HUB_VER}/darwin-arm/Antigravity.dmg" "Antigravity_arm.dmg")
  echo "  aarch64-darwin: $hub_aarch64_darwin"
fi

# 3. Fetch IDE Hashes
if [[ -n "$IDE_VER" ]]; then
  echo ""
  echo "=== IDE Hashes ==="
  ide_x86_64_linux=$(prefetch_nix_base32 "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VER}/linux-x64/Antigravity%20IDE.tar.gz" "Antigravity_IDE_x64.tar.gz")
  echo "  x86_64-linux: $ide_x86_64_linux"
  ide_aarch64_linux=$(prefetch_nix_base32 "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VER}/linux-arm/Antigravity%20IDE.tar.gz" "Antigravity_IDE_arm.tar.gz")
  echo "  aarch64-linux: $ide_aarch64_linux"
  ide_x86_64_darwin=$(prefetch_nix_base32 "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VER}/darwin-x64/Antigravity%20IDE.dmg" "Antigravity_IDE_x64.dmg")
  echo "  x86_64-darwin: $ide_x86_64_darwin"
  ide_aarch64_darwin=$(prefetch_nix_base32 "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VER}/darwin-arm/Antigravity%20IDE.dmg" "Antigravity_IDE_arm.dmg")
  echo "  aarch64-darwin: $ide_aarch64_darwin"
fi

# 4. Fetch SDK Hashes
if [[ -n "$SDK_VER" ]]; then
  echo ""
  echo "=== SDK Hashes ==="
  sdk_json=$(curl -s "https://pypi.org/pypi/google-antigravity/json")
  if [ -z "$sdk_json" ]; then
    echo "Error: Failed to fetch SDK releases from PyPI."
    exit 1
  fi

  sdk_x86_64_linux_url=$(echo "$sdk_json" | jq -r --arg v "$SDK_VER" '.releases[$v][] | select(.filename | endswith("manylinux_2_17_x86_64.whl")) | .url')
  sdk_aarch64_linux_url=$(echo "$sdk_json" | jq -r --arg v "$SDK_VER" '.releases[$v][] | select(.filename | endswith("manylinux_2_17_aarch64.whl")) | .url')
  sdk_aarch64_darwin_url=$(echo "$sdk_json" | jq -r --arg v "$SDK_VER" '.releases[$v][] | select(.filename | endswith("macosx_11_0_arm64.whl")) | .url')

  if [[ -z "$sdk_x86_64_linux_url" || "$sdk_x86_64_linux_url" == "null" ]]; then
    echo "Error: Failed to find wheel URL for x86_64-linux for version $SDK_VER"
    exit 1
  fi
  if [[ -z "$sdk_aarch64_linux_url" || "$sdk_aarch64_linux_url" == "null" ]]; then
    echo "Error: Failed to find wheel URL for aarch64-linux for version $SDK_VER"
    exit 1
  fi
  if [[ -z "$sdk_aarch64_darwin_url" || "$sdk_aarch64_darwin_url" == "null" ]]; then
    echo "Error: Failed to find wheel URL for aarch64-darwin for version $SDK_VER"
    exit 1
  fi

  sdk_x86_64_linux=$(prefetch_sri_hash "$sdk_x86_64_linux_url")
  echo "  x86_64-linux: $sdk_x86_64_linux"
  sdk_aarch64_linux=$(prefetch_sri_hash "$sdk_aarch64_linux_url")
  echo "  aarch64-linux: $sdk_aarch64_linux"
  sdk_aarch64_darwin=$(prefetch_sri_hash "$sdk_aarch64_darwin_url")
  echo "  aarch64-darwin: $sdk_aarch64_darwin"
fi

# 5. Selectively update version.json
echo ""
echo "Updating version.json..."

UPDATED=$(<"$VERSION_FILE")

if [[ -n "$CLI_VER" ]]; then
  UPDATED=$(echo "$UPDATED" | jq \
    --arg v "$CLI_VER" \
    --arg x "$cli_x86_64_linux" --arg a "$cli_aarch64_linux" \
    --arg mx "$cli_x86_64_darwin" --arg ma "$cli_aarch64_darwin" \
    '.cli = { version: $v, hashes: { "x86_64-linux": $x, "aarch64-linux": $a, "x86_64-darwin": $mx, "aarch64-darwin": $ma } }')
fi

if [[ -n "$HUB_VER" ]]; then
  UPDATED=$(echo "$UPDATED" | jq \
    --arg v "$HUB_VER" \
    --arg x "$hub_x86_64_linux" --arg a "$hub_aarch64_linux" \
    --arg mx "$hub_x86_64_darwin" --arg ma "$hub_aarch64_darwin" \
    '.hub = { version: $v, hashes: { "x86_64-linux": $x, "aarch64-linux": $a, "x86_64-darwin": $mx, "aarch64-darwin": $ma } }')
fi

if [[ -n "$IDE_VER" ]]; then
  UPDATED=$(echo "$UPDATED" | jq \
    --arg v "$IDE_VER" \
    --arg x "$ide_x86_64_linux" --arg a "$ide_aarch64_linux" \
    --arg mx "$ide_x86_64_darwin" --arg ma "$ide_aarch64_darwin" \
    '.ide = { version: $v, hashes: { "x86_64-linux": $x, "aarch64-linux": $a, "x86_64-darwin": $mx, "aarch64-darwin": $ma } }')
fi

if [[ -n "$SDK_VER" ]]; then
  UPDATED=$(echo "$UPDATED" | jq \
    --arg v "$SDK_VER" \
    --arg xu "$sdk_x86_64_linux_url" --arg xh "$sdk_x86_64_linux" \
    --arg au "$sdk_aarch64_linux_url" --arg ah "$sdk_aarch64_linux" \
    --arg mau "$sdk_aarch64_darwin_url" --arg mah "$sdk_aarch64_darwin" \
    '.sdk = { version: $v, urls: { "x86_64-linux": $xu, "aarch64-linux": $au, "aarch64-darwin": $mau }, hashes: { "x86_64-linux": $xh, "aarch64-linux": $ah, "aarch64-darwin": $mah } }')
fi

echo "$UPDATED" > "$VERSION_FILE"

echo "------------------------------------------------"
echo "Success! version.json has been updated."
echo "------------------------------------------------"
