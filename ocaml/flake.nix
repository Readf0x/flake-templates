rec {
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        system,
        pkgs,
        ...
      }: let
        info = {
          projectName = null; # Don't forget to change this!
        };
      in
        (
          {projectName}: rec {
            devShells.default = pkgs.mkShell {
              packages = with pkgs;
              with ocamlPackages; [
                ocaml
                ocaml-lsp
                ocamlformat
                odoc
                dune_3
                utop
                packages.init-script
              ];
            };
            packages = {
              ${projectName} = pkgs.ocamlPackages.buildDunePackage rec {
                name = projectName;
                pname = name;
                version = "0.1";

                src = ./.;

                meta = {
                  inherit description;
                  # homepage = "";
                  # license = lib.licenses.;
                  # maintainers = with lib.maintainers; [  ];
                };
              };
              default = packages.${projectName};
              init-script = pkgs.writeShellScriptBin "init-proj" ''
                git init
                dune init proj ${projectName} .
                echo "version = `ocamlformat --version`" > .ocamlformat
              '';
            };
          }
        )
        info;
    };
}
