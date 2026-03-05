rec {
  description = "Description for the project";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = { system, pkgs, lib, ... }: let info = {
        projectName = null;
        dependencies = with pkgs; [];
      }; in ({
        projectName,
        dependencies ? [],
        sourceDir ? ".",
        version ? "0.1",
        binaryName ? projectName
      }: rec {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            odin
            gnumake
            packages.init-proj
          ] ++ dependencies;
        };
        packages = {
          ${projectName} = pkgs.stdenv.mkDerivation rec {
            pname = projectName;
            inherit version;
            src = ./.;

            nativeBuildInputs = with pkgs; [ odin ] ++ dependencies;
            buildInputs = [];

            DESTDIR = placeholder "out";
            PREFIX = "";

            meta = {
              inherit description;
              homepage = "";
              license = lib.licenses.gpl3Only;
            };
          };
          default = packages.${projectName};
          init-proj = pkgs.writeShellScriptBin "init-proj" ''
            git init
            mkdir ${sourceDir} -p
            touch ${sourceDir}/main.odin
            cat <<EOF > makefile
            PREFIX ?= /usr/local
            BINDIR ?= \$(PREFIX)/bin
            MANDIR ?= \$(PREFIX)/share/man

            build:
            	odin build ${sourceDir} -out:${binaryName}
            
            debug:
            	odin build ${sourceDir} -debug -out:${binaryName}

            install: build
            	install -Dm755 ${binaryName} "\$(DESTDIR)\$(BINDIR)/${binaryName}"
            EOF
            git add -A
          '';
        };
      }) info;
    };
}
