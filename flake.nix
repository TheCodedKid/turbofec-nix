{
  description = "TurboFEC — LTE forward error correction encoders and decoders (convolutional + turbo codes)";

  inputs = {
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      # Overlay: adds `turbofec` to any nixpkgs instance it is applied to.
      overlay = final: prev: {
        turbofec = final.callPackage ./nix/turbofec.nix { };
      };
    in
    {
      overlays.default = overlay;
    }
    // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
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
          packages = with pkgs; [ gdb clang-tools ];
          shellHook = ''
            echo "turbofec dev shell — run: autoreconf -i && ./configure && make && make check"
          '';
        };

        formatter = pkgs.nixfmt;
      });
}
