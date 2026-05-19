# Google Antigravity Nix Flake

A clean, multi-platform Nix Flake for packaging the complete Google Antigravity AI engineering suite: the CLI, Desktop Hub, Desktop IDE, and Python SDK.

## Exposed Packages

This flake packages and exposes four primary targets supporting both Linux (`x86_64-linux`, `aarch64-linux`) and macOS (`x86_64-darwin`, `aarch64-darwin`):

1. **`antigravity-cli`** (default) - The Go-based Antigravity command-line utility.
2. **`antigravity-hub`** - The Antigravity Desktop Hub (Electron application).
3. **`antigravity-ide`** - The Antigravity Desktop IDE (Electron-based development environment).
4. **`antigravity-sdk`** - The Python SDK containing precompiled, auto-patched localharness binaries for agent interaction.

---

## Quick Start (No Installation)

You can run any part of the Antigravity suite immediately without modifying your system configuration:

### Run the CLI
```bash
nix run github:Hy4ri/antigravity-flake
# Or explicitly:
nix run github:Hy4ri/antigravity-flake#antigravity-cli
```

### Run the Desktop Hub
```bash
nix run github:Hy4ri/antigravity-flake#antigravity-hub
```

### Run the Desktop IDE
```bash
nix run github:Hy4ri/antigravity-flake#antigravity-ide
```

---

## Installation & Integration

### 1. Declaring packages in NixOS / Home Manager
Add `antigravity-flake` to your flake inputs:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  antigravity.url = "github:Hy4ri/antigravity-flake";
};
```

Then add the packages to your system or home packages:

```nix
environment.systemPackages = [
  inputs.antigravity.packages.${pkgs.system}.antigravity-cli
  inputs.antigravity.packages.${pkgs.system}.antigravity-hub
  inputs.antigravity.packages.${pkgs.system}.antigravity-ide
];
```

### 2. Using the Python SDK in a DevShell
If you are developing Python agents, you can easily load the precompiled and auto-patched Python SDK into a nix development shell:

```nix
devShells.default = pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (ps: [
      inputs.antigravity.packages.${pkgs.system}.antigravity-sdk
    ]))
  ];
};
```

### 3. Using Overlays
To globally inject these packages into your nixpkgs instance, apply the overlay:

```nix
nixpkgs.overlays = [
  inputs.antigravity.overlays.default
];
```

---

## Automatic Hash & Version Maintenance

The version hashes are declaratively managed inside `version.json`. When new updates are released by Google, run the included `update-version.sh` utility to automatically download the new binaries, recalculate cryptographic Nix hashes, and update the catalog in-place:

```bash
nix develop
./update-version.sh --cli <new-version> --hub <new-version> --ide <new-version> --sdk <new-version>
```

Alternatively, pass individual flags to update only specific packages.

---

## License
Proprietary binaries downloaded and packaged under the Google Antigravity License Terms.
