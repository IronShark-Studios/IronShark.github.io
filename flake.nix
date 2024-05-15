  {
    description = "Personal website using Hugo, and Blowfish";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      flake-utils.url = "github:numtide/flake-utils";
      hugo-theme = {
        url = "github:nunocoracao/blowfish";
        flake = false;
      };
    };

    outputs = { self, nixpkgs, flake-utils, hugo-theme }:
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          {
            packages.website = pkgs.stdenv.mkDerivation rec {
              pname = "personal-website";
              version = "2024-05-15";
              src = ./.;
              nativeBuildInputs = [
                pkgs.hugo
              ];
              configurePhase = ''
                mkdir -p "themes/blowfish"
                cp -r ${hugo-theme}/* "themes/blowfish"
              '';
              buildPhase = "${pkgs.hugo}/bin/hugo";
              installPhase = "cp -r public $out";
            };

            defaultPackage = self.packages.${system}.website;

            devShell = pkgs.mkShell {
              packages = [
                pkgs.hugo
              ];
              shellHook = ''
                mkdir -p themes
                ln -sn "${hugo-theme}" "themes/blowfish"
              '';
            };
          }
      );
  }
