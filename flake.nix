{
  description = "Lisp implementation of paren-matcher";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:/numtide/flake-utils";
    cl-nix-lite.url = "github:hraban/cl-nix-lite";
    nix-lol.url = "github:ChristopherSegale/nix-let-over-lambda";
    paren-matcher = {
      url = "github:ChristopherSegale/paren-matcher";
      flake = false;
    };
  };
  outputs = inputs @ { self, nixpkgs, cl-nix-lite, flake-utils, nix-lol, paren-matcher }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend cl-nix-lite.overlays.default;
        name = "paren-matcher";
        version = "1.0";
        inherit (pkgs) lispPackagesLite;
        inherit (lispPackagesLite) lispDerivation;
        lol = nix-lol.packages.${system}.default;
      in
        {
          packages = {
            # This is how you would create a derivation using SBCL (the default)
            default = lispDerivation {
              inherit name version;
              lispSystem = name;
              lispDependencies = [
                lol
                lispPackagesLite.cffi
              ];
              src = paren-matcher;
              dontStrip = true;
              meta = {
                license = pkgs.lib.licenses.mit;
              };
            };
          };
          apps.default = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/${name}";
          };
        });
  }
