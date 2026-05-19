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
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
      antigravity = pkgs.callPackage ./ide.nix {};
      antigravity-fhs = if isLinux then pkgs.buildFHSEnv {
        name = "antigravity";
        targetPkgs = pkgs: with pkgs; [
          glibc
          stdenv.cc.cc
          zlib
          openssl
          curl
          icu
          libunwind
          libuuid
          lttng-ust
          krb5

          glib
          nspr
          nss
          dbus
          at-spi2-atk
          cups
          expat
          libxkbcommon
          libx11
          libxcomposite
          libxdamage
          libxcb
          libxext
          libxfixes
          libxrandr
          cairo
          pango
          alsa-lib
          libgbm
          udev
        ];

        extraBwrapArgs = [
          "--bind-try /etc/nixos/ /etc/nixos/"
          "--ro-bind-try /etc/xdg/ /etc/xdg/"
        ];

        extraInstallCommands = ''
          ln -s "${antigravity}/share" "$out/"
        '';

        runScript = "${antigravity}/bin/antigravity";

        dieWithParent = false;

        meta = antigravity.meta // {
          description = "Wrapped variant of antigravity which launches in a FHS compatible environment, should allow for easy usage of extensions without nix-specific modifications";
        };
      } else null;
    in {
      antigravity-cli = pkgs.callPackage ./cli.nix {};
      antigravity-hub = pkgs.callPackage ./hub.nix {};
      inherit antigravity;
      antigravity-sdk = pkgs.python3Packages.callPackage ./sdk.nix {};
      default = self.packages.${system}.antigravity-cli;
    } // (if isLinux then { inherit antigravity-fhs; } else {}));

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

      antigravity = final: prev: {
        antigravity = final.callPackage ./ide.nix {};
      };

      antigravity-fhs = final: prev: {
        antigravity-fhs = if prev.stdenv.hostPlatform.isLinux then final.buildFHSEnv {
          name = "antigravity";
          targetPkgs = pkgs: with pkgs; [
            glibc
            stdenv.cc.cc
            zlib
            openssl
            curl
            icu
            libunwind
            libuuid
            lttng-ust
            krb5

            glib
            nspr
            nss
            dbus
            at-spi2-atk
            cups
            expat
            libxkbcommon
            libx11
            libxcomposite
            libxdamage
            libxcb
            libxext
            libxfixes
            libxrandr
            cairo
            pango
            alsa-lib
            libgbm
            udev
          ];

          extraBwrapArgs = [
            "--bind-try /etc/nixos/ /etc/nixos/"
            "--ro-bind-try /etc/xdg/ /etc/xdg/"
          ];

          extraInstallCommands = ''
            ln -s "${final.antigravity}/share" "$out/"
          '';

          runScript = "${final.antigravity}/bin/antigravity";

          dieWithParent = false;

          meta = final.antigravity.meta // {
            description = "Wrapped variant of antigravity which launches in a FHS compatible environment, should allow for easy usage of extensions without nix-specific modifications";
          };
        } else null;
      };

      antigravity-sdk = final: prev: {
        python3 = prev.python3.override {
          packageOverrides = python-final: python-prev: {
            antigravity-sdk = python-final.callPackage ./sdk.nix {};
          };
        };
        python3Packages = final.python3.pkgs;
        antigravity-sdk = final.python3Packages.antigravity-sdk;
      };

      default = final: prev:
        self.overlays.antigravity-cli final prev
        // self.overlays.antigravity-hub final prev
        // self.overlays.antigravity final prev
        // self.overlays.antigravity-sdk final prev
        // (if prev.stdenv.hostPlatform.isLinux then self.overlays.antigravity-fhs final prev else {});
    };
  };
}
