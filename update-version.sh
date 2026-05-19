#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/version.json"

show_help() {
  echo "Google Antigravity Nix Flake Updater"
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --cli <version>   Update CLI version and recalculate all hashes"
  echo "  --hub <version>   Update Hub version and recalculate all hashes"
  echo "  --ide <version>   Update IDE version and recalculate all hashes"
  echo "  --sdk <version>   Update SDK version and recalculate all hashes"
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

# Fill in current versions if not overridden
[[ -z "$CLI_VER" ]] && CLI_VER=$(get_current_val ".cli.version")
[[ -z "$HUB_VER" ]] && HUB_VER=$(get_current_val ".hub.version")
[[ -z "$IDE_VER" ]] && IDE_VER=$(get_current_val ".ide.version")
[[ -z "$SDK_VER" ]] && SDK_VER=$(get_current_val ".sdk.version")

echo "------------------------------------------------"
echo "Targeting Versions:"
echo "  CLI: $CLI_VER"
echo "  Hub: $HUB_VER"
echo "  IDE: $IDE_VER"
echo "  SDK: $SDK_VER"
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

# 2. Fetch Hub Hashes
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

# 3. Fetch IDE Hashes
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

# 4. Fetch SDK Hashes
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

# 5. Write to version.json
echo ""
echo "Writing updated versions and hashes to version.json..."
jq -n \
  --arg cliv "$CLI_VER" --arg cli_x "$cli_x86_64_linux" --arg cli_a "$cli_aarch64_linux" --arg cli_mx "$cli_x86_64_darwin" --arg cli_ma "$cli_aarch64_darwin" \
  --arg hubv "$HUB_VER" --arg hub_x "$hub_x86_64_linux" --arg hub_a "$hub_aarch64_linux" --arg hub_mx "$hub_x86_64_darwin" --arg hub_ma "$hub_aarch64_darwin" \
  --arg idev "$IDE_VER" --arg ide_x "$ide_x86_64_linux" --arg ide_a "$ide_aarch64_linux" --arg ide_mx "$ide_x86_64_darwin" --arg ide_ma "$ide_aarch64_darwin" \
  --arg sdkv "$SDK_VER" \
  --arg sdk_x_url "$sdk_x86_64_linux_url" --arg sdk_x "$sdk_x86_64_linux" \
  --arg sdk_a_url "$sdk_aarch64_linux_url" --arg sdk_a "$sdk_aarch64_linux" \
  --arg sdk_ma_url "$sdk_aarch64_darwin_url" --arg sdk_ma "$sdk_aarch64_darwin" \
  '{
    "cli": {
      "version": $cliv,
      "hashes": {
        "x86_64-linux": $cli_x,
        "aarch64-linux": $cli_a,
        "x86_64-darwin": $cli_mx,
        "aarch64-darwin": $cli_ma
      }
    },
    "hub": {
      "version": $hubv,
      "hashes": {
        "x86_64-linux": $hub_x,
        "aarch64-linux": $hub_a,
        "x86_64-darwin": $hub_mx,
        "aarch64-darwin": $hub_ma
      }
    },
    "ide": {
      "version": $idev,
      "hashes": {
        "x86_64-linux": $ide_x,
        "aarch64-linux": $ide_a,
        "x86_64-darwin": $ide_mx,
        "aarch64-darwin": $ide_ma
      }
    },
    "sdk": {
      "version": $sdkv,
      "urls": {
        "x86_64-linux": $sdk_x_url,
        "aarch64-linux": $sdk_a_url,
        "aarch64-darwin": $sdk_ma_url
      },
      "hashes": {
        "x86_64-linux": $sdk_x,
        "aarch64-linux": $sdk_a,
        "aarch64-darwin": $sdk_ma
      }
    }
  }' > "$VERSION_FILE"

echo "------------------------------------------------"
echo "Success! version.json has been updated."
echo "------------------------------------------------"
