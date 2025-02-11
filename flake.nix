{
  description = "Ollama with Llama 3.2 3B model";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ollama-models.url = "github:josh/ollama-models-nix";
  };

  outputs = { self, nixpkgs, flake-utils, ollama-models }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Create the Ollama package with the Llama model
        ollama-with-model = ollama-models.packages.${system}.ollama.override {
          models = [ "deepseek-r1:7b" "deepseek-r1:8b" ];
        };

        # Create a wrapper script that runs ollama serve
        startScript = pkgs.writeShellScriptBin "start-ollama" ''
          OLLAMA_HOST="0.0.0.0:6060" ${ollama-with-model}/bin/ollama serve
        '';

      in {
        packages = {
          default = startScript;
          ollama = ollama-with-model;
        };

        apps.default = {
          type = "app";
          program = "${startScript}/bin/start-ollama";
        };

        devShells.default =
          pkgs.mkShell { buildInputs = [ ollama-with-model ]; };
      });
}
