# Google Antigravity Nix Flake

[![CLI Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.cli.version&label=CLI&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)
[![Hub Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.hub.version&label=Hub&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)
[![IDE Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.ide.version&label=IDE&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)
[![SDK Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.sdk.version&label=SDK&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)

A clean, multi-platform Nix Flake for packaging the complete Google Antigravity AI engineering suite: the CLI, Desktop Hub, Desktop IDE, and Python SDK.

## Exposed Packages

This flake packages and exposes five primary targets supporting both Linux (`x86_64-linux`, `aarch64-linux`) and macOS (`x86_64-darwin`, `aarch64-darwin`):

1. **`antigravity-cli`** (default) ![CLI Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.cli.version&label=CLI&prefix=v&color=blue) - The Go-based Antigravity command-line utility (provides command `agy`).
2. **`antigravity`** ![Hub Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.hub.version&label=Hub&prefix=v&color=blue) - The Antigravity Desktop Hub (provides command `antigravity`).
3. **`antigravity-ide`** ![IDE Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.ide.version&label=IDE&prefix=v&color=blue) - The Antigravity Desktop IDE (provides command `antigravity-ide`).
4. **`antigravity-fhs`** ![IDE Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.ide.version&label=IDE&prefix=v&color=blue) - Wrapped IDE launched in a FHS compatible environment (provides conflicting command `antigravity-ide`, making it mutually exclusive/uninstallable together with the standard IDE package).
5. **`antigravity-sdk`** ![SDK Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.sdk.version&label=SDK&prefix=v&color=blue) - The Python SDK containing precompiled, auto-patched localharness binaries for agent interaction.

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
nix run github:Hy4ri/antigravity-flake#antigravity
```

### Run the Desktop IDE
```bash
nix run github:Hy4ri/antigravity-flake#antigravity-ide
# Or run with the FHS wrapper (Linux only):
nix run github:Hy4ri/antigravity-flake#antigravity-fhs
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
  inputs.antigravity.packages.${pkgs.system}.antigravity
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

## License
Proprietary binaries downloaded and packaged under the Google Antigravity License Terms.
