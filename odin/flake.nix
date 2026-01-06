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
        binaryName ? projectName
      }: rec {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            odin
            gnumake
            packages.init-proj
          ] // dependencies;
        };
        packages = {
          ${projectName} = pkgs.stdenv.mkDerivation rec {
            pname = projectName;
            version = "0.1";
            src = ./.;
            nativeBuildInputs = [];
            buildInputs = [];
            meta = {
              inherit description;
              homepage = "";
              license = lib.licenses.gpl3Only;
            };
          };
          default = packages.${projectName};
          init-proj = pkgs.writeShellScriptBin "init-proj" ''
            git init
            git add -A
            cat > makefile <<EOF
            PREFIX ?= /usr/local
            BINDIR ?= $(PREFIX)/bin
            MANDIR ?= $(PREFIX)/share/man

            build:
              odin build ${sourceDir} -out:${binaryName}
            
            debug:
              odin build ${sourceDir} -debug -out:${binaryName}

            install: build
              install -Dm755 ${binaryName} "$(DESTDIR)$(BINDIR)/${binaryName}"
            EOF
          '';
        };
      }) info;
    };
}
