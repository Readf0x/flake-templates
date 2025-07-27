{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {

      generic = {
        path = ./generic;
        description = "Set up for adding your own stuff";
      };

      go = {
        path = ./go;
        description = "Golang template";
      };

      go-qt = {
        path = ./go-qt;
        description = "miQT template";
      };

      node = {
        path = ./node;
        description = "Node.js template";
      };

    };

    defaultTemplate = self.templates.generic;
  };
}
