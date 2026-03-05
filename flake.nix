{
  description = "A collection of flake templates";
  outputs = {self}: {
    templates =
      builtins.mapAttrs (name: value: {
        path = ./${name};
        description = value;
      }) {
        generic = "Set up for adding your own stuff";
        go = "Golang template";
        go-qt = "miQT template";
        ocaml = "OCaml template (nix managed)";
        odin = "Odin template";
      };
    defaultTemplate = self.templates.generic;
  };
}
