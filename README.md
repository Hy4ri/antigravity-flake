# Google Antigravity Nix Flake

[![CLI Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.cli.version&label=CLI&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)
[![Hub Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.hub.version&label=Hub&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)
[![IDE Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.ide.version&label=IDE&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)
[![SDK Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2FHy4ri%2Fantigravity-flake%2Fmain%2Fversion.json&query=%24.sdk.version&label=SDK&prefix=v&color=blue)](https://github.com/Hy4ri/antigravity-flake)

Run and install the Google Antigravity tools on NixOS, Home Manager, nix-darwin, or any system with Nix: the CLI, the desktop Hub, the desktop IDE, and the Python SDK.

The flake is updated automatically every day.

## Packages

| Package | What it is | Command |
|---|---|---|
| `antigravity-cli` (default) | Command-line tool | `agy` |
| `antigravity` | Desktop Hub | `antigravity` |
| `antigravity-ide` | Desktop IDE | `antigravity-ide` |
| `antigravity-fhs` | Desktop IDE in an FHS environment, so extensions with their own binaries work without Nix patches. Linux only. | `antigravity-ide` |
| `antigravity-sdk` | Python SDK, with its bundled binaries patched for Nix | Python library |

> `antigravity-ide` and `antigravity-fhs` give the same command. **Install only one of them.** If IDE extensions do not work, use `antigravity-fhs`.

Platforms: Linux (`x86_64`, `aarch64`) and macOS (Intel, Apple Silicon).

## Try it without installing

You need Nix with [flakes enabled](https://wiki.nixos.org/wiki/Flakes).

```bash
nix run github:Hy4ri/antigravity-flake                   # CLI
nix run github:Hy4ri/antigravity-flake#antigravity       # desktop Hub
nix run github:Hy4ri/antigravity-flake#antigravity-ide   # desktop IDE
nix run github:Hy4ri/antigravity-flake#antigravity-fhs   # desktop IDE, FHS (Linux only)
```

## Install

There are **two ways** to install. **Pick one.** They give the same result.

| Option | Use it when |
|---|---|
| **A. Overlay** | You want to write `pkgs.antigravity-cli`, like any other nixpkgs package. |
| **B. Direct package** | You do not want to use overlays. |

### Step 1: Add the flake input (needed for both options)

In your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    antigravity.url = "github:Hy4ri/antigravity-flake";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # lets your modules use `inputs`
      modules = [ ./configuration.nix ];
    };
  };
}
```

> Already have a flake? Add only the `antigravity.url` line, and make sure `inputs` reaches your modules (`specialArgs` for NixOS and nix-darwin, `extraSpecialArgs` for Home Manager).

### Step 2, Option A: Overlay

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.antigravity.overlays.default ];
  nixpkgs.config.allowUnfree = true; # required: the apps are marked unfree

  environment.systemPackages = [
    pkgs.antigravity-cli
    pkgs.antigravity
    pkgs.antigravity-ide # or pkgs.antigravity-fhs, not both
  ];
}
```

For Home Manager, keep the two `nixpkgs` lines and use `home.packages` instead.

Want only some packages in `pkgs`? Use the single overlays instead of `overlays.default`: `antigravity-cli`, `antigravity`, `antigravity-ide`, `antigravity-fhs`, `antigravity-sdk`.

### Step 2, Option B: Direct package

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
let
  antigravity = inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.systemPackages = [
    antigravity.antigravity-cli
    antigravity.antigravity
    antigravity.antigravity-ide # or antigravity.antigravity-fhs, not both
  ];
}
```

You do not need `allowUnfree` for this option. For Home Manager, put the same packages in `home.packages`.

### Step 3: Rebuild

```bash
sudo nixos-rebuild switch --flake .#myhost
```

## Use the Python SDK

The SDK is a Python library, so you add it to a Python environment, not to `systemPackages`. Example dev shell in your project's `flake.nix`:

```nix
devShells.x86_64-linux.default = pkgs.mkShell {
  packages = [
    (pkgs.python3.withPackages (ps: [
      inputs.antigravity.packages.x86_64-linux.antigravity-sdk
    ]))
  ];
};
```

With the overlay, `antigravity-sdk` is also in the Python package set, so `pkgs.python3.withPackages (ps: [ ps.antigravity-sdk ])` works too.

## Updates

A GitHub Action checks for new releases every day, tests the build, and commits the new versions. To get them, update your lock file:

```bash
nix flake update antigravity
```

Maintainers can update by hand: `nix develop`, then `./update-version.sh`.

## License

The Antigravity apps are proprietary software by Google, under the Google Antigravity license terms; Nix marks them as unfree. The SDK is Apache-2.0. This flake only downloads and packages the official releases.

## Support

If this flake helps you, you can support my work on [GitHub Sponsors](https://github.com/sponsors/hy4ri) or [Ko-fi](https://ko-fi.com/m_5_7). A star on the repo also helps.
