{
  description = "TurboFEC — LTE forward error correction encoders and decoders (convolutional + turbo codes)";

  inputs = {
    # Pinned by explicit revision (not a moving branch) for reproducibility.
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/331800de5053fcebacf6813adb5db9c9dca22a0c.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    {
      overlays.default = final: prev: {
        turbofec = (final.callPackage ./pkgs/turbofec.nix { }).overrideAttrs (_: {
          src = self;
        });
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        packages = {
          inherit (pkgs) turbofec;
          default = pkgs.turbofec;
        };

        devShells.default = pkgs.mkShell {
          name = "turbofec-dev";
          inputsFrom = [ pkgs.turbofec ];
          packages = with pkgs; [
            gdb
            clang-tools
          ];
          shellHook = ''
            echo "turbofec dev shell — run: autoreconf -i && ./configure && make && make check"
          '';
        };

        formatter = pkgs.nixfmt;
      }
    );
}
