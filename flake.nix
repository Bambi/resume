{
  description = "Resume flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = (import nixpkgs { inherit system; });
    pythonEnv = pkgs.python3.withPackages (ps: with ps; [ jinja2 ]);
    buildDeps = [ pkgs.texliveFull pythonEnv ];
  in {
    devShells.default = pkgs.mkShell {
      buildInputs = buildDeps;
      shellHook = ''
      '';
    };
    packages.default = pkgs.stdenv.mkDerivation {
      name = "cv";
      src = ./.;
      buildPhase = ''
        mkdir $out
        patchShebangs generate
        ./generate cv/cv.json template.tex $out/cv.tex
        XDG_CACHE_HOME="$(mktemp -d)" xelatex -output-directory=$out $out/cv.tex
      '';
      nativeBuildInputs = buildDeps;
    };
  });
}
