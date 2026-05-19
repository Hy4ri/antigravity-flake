{
  description = "Google Antigravity Nix Flake - CLI, Hub, IDE, and SDK packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      antigravity-cli = pkgs.callPackage ./cli.nix {};
      antigravity-hub = pkgs.callPackage ./hub.nix {};
      antigravity-ide = pkgs.callPackage ./ide.nix {};
      antigravity-sdk = pkgs.python3Packages.callPackage ./sdk.nix {};
      default = self.packages.${system}.antigravity-cli;
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          curl
          coreutils
          nix
          jq
        ];
        shellHook = ''
          echo "=== Google Antigravity Development Shell ==="
          echo "Available tools:"
          echo "  - ./update-version.sh: Update Antigravity packages and compute Nix hashes"
        '';
      };
    });

    overlays = {
      antigravity-cli = final: prev: {
        antigravity-cli = final.callPackage ./cli.nix {};
      };

      antigravity-hub = final: prev: {
        antigravity-hub = final.callPackage ./hub.nix {};
      };

      antigravity-ide = final: prev: {
        antigravity-ide = final.callPackage ./ide.nix {};
      };

      antigravity-sdk = final: prev: {
        antigravity-sdk = final.python3Packages.callPackage ./sdk.nix {};
      };

      default = final: prev:
        self.overlays.antigravity-cli final prev
        // self.overlays.antigravity-hub final prev
        // self.overlays.antigravity-ide final prev
        // self.overlays.antigravity-sdk final prev;
    };
  };
}
