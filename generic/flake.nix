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
          # You can set the module name as well
          # moduleName = "github.com/example/${projectName}";
        };
      in
        ({
          projectName,
          moduleName ? projectName,
        }: rec {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              packages.init-proj
            ];
          };
          packages = {
            ${projectName} = pkgs.stdenv.mkDerivation rec {
              name = projectName;
              pname = name;
              version = "0.1";
              src = ./.;
              nativeBuildInputs = [];
              buildInputs = [];
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
              git add -A
            '';
          };
        })
        info;
    };
}
